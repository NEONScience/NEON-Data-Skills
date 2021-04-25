library(rGEDI)
library(rhdf5)
wd <- "~/Downloads/" # This will depend on your local environment
setwd(wd)

#unlink(paste0(wd, "NEON_GEDI_subset.h5"))


# read-in-data ------------------------------------------------------------


f_full=paste0(wd, "GEDI01_B_2019206022612_O03482_T00370_02_003_01.h5")

# View the list of groups and datasets in the GEDI package, and save a table of that list
#View(h5ls(f_full, all=T))
t=h5ls(f_full, all=T)



# Read-chm-and-subset-shot-numbers ----------------------------------------


### Crop full dataset to NEON footprint
# First, load in NEON data for cropping
chm <- raster(paste0(wd, "/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif"))
# Project CHM to WGS84
chm_WGS = projectRaster(chm, crs=CRS("+init=epsg:4326"))


# read in GEDI and get footprint centers
gedilevel1b<-readLevel1B(level1Bpath = file.path(wd, "GEDI01_B_2019206022612_O03482_T00370_02_003_01.h5"))
level1bGeo<-getLevel1BGeo(level1b=gedilevel1b,select=c("elevation_bin0"))
head(level1bGeo)

# drop any shots with missing latitude/longitude values
level1bGeo = level1bGeo[!is.na(level1bGeo$latitude_bin0)&
                          !is.na(level1bGeo$longitude_bin0),]

# Convert the GEDI data.frame into an 'sf' object
level1bGeo_spdf<-st_as_sf(level1bGeo,
                          coords = c("longitude_bin0", "latitude_bin0"),
                          crs=CRS("+init=epsg:4326"))


# Could also crop to AOP footprint here if you have the shapefile??
# crop to the CHM that is in WGS84
level1bGeo_NEON=st_crop(level1bGeo_spdf, chm_WGS)


# find-most-common-beam-to-copy -------------------------------------------

shot_vec=level1bGeo_NEON$shot_number
level1b <- gedilevel1b@h5
groups_id <- grep("BEAM\\d{4}$", gsub("/", "", hdf5r::list.groups(level1b,recursive = F)), value = T)

beam_list=NULL
for(sn in 1:length(shot_vec)) {
  #print(shot_vec[sn])
  i=NULL
  for (k in groups_id) {
    gid <- max(level1b[[paste0(k, "/shot_number")]][] ==
                 shot_vec[sn])
    if (gid == 1) {
      i = k
    }
  }
  #print(i)
  beam_list=c(beam_list,i)
}
table(beam_list)
main_beam=names(sort(table(beam_list), decreasing=TRUE)[1])
# This is the beam with the most 'hits' in the area of interest (AOP footprint or LiDAR tile)
main_beam

#View(t)
#View(level1bGeo_NEON)


# Extract-wfs-from-main-beam-NEON -----------------------------------------

# use shot_vec to extract shots of interest
# loop through shots
level1b=gedilevel1b@h5
new_wf_vec=NULL
new_start=1
new_start_vec=NULL

# find which NEON shots (shot_vec) come from the main beam
shot_number_i <- level1b[[paste0(main_beam, "/shot_number")]][]
shots_from_main_beam = shot_vec[shot_vec %in% shot_number_i]
for(shot in 1:length(shot_vec)){
  # first, get shot start, which will be NA if the shot is not from the main_beam
  shot_wf_start=level1b[[paste0(i, "/rx_sample_start_index")]][which(shot_number_i %in% shots_from_main_beam)][shot]
  if(!is.na(shot_wf_start)){ #if that shot is from the main_beam..
    new_start_vec=c(new_start_vec,new_start) #add to new_start_vec position
    #get wf_length from GEDI dataset
    shot_wf_length=level1b[[paste0(i, "/rx_sample_count")]][which(shot_number_i %in% shots_from_main_beam)][shot]
    #pull waveform data from GEDI dataset
    waveform <- level1b[[paste0(i, "/rxwaveform")]][shot_wf_start:( shot_wf_start + shot_wf_length - 1)]
    #append waveform vector
    new_wf_vec=c(new_wf_vec, waveform)
    #make index for new start position
    new_start=length(new_wf_vec)+1
  }
}

# values to overwrite in new H5:
# shot_number (1:length(new_start_vec))
# /rx_sample_start_index --> new_start_vec
# rxwaveform --> new_wf_vec

## use /rx_sample_start_index to find start of waveform data
## level1b[[paste0(i, "/rx_sample_start_index")]][which(shot_number_i %in% shot_vec)]
## use /rx_sample_count to find end of waveform data
## level1b[[paste0(i, "/rx_sample_count")]][which(shot_number_i %in% shot_vec)]
## get waveform data for each shot
## rxwaveform_i <- level1b[[paste0(i, "/rxwaveform")]][rx_sample_start_index_n[shot_number_id]:(rx_sample_start_index_n[shot_number_id] + rx_sample_count[shot_number_id] - 1)]
## append waveform data into single vector
## make new /rx_sample_start_index for subset H5 as cumulative sum of subset /rx_sample_count
##


# make-subset-file-add-groups ---------------------------------------------

# First, create a name for the new file
f <- paste0(wd, "NEON_GEDI_subset.h5")

# create hdf5 file
h5createFile(f)

# Find all groups with main_beam in the name
group_list=unique(t$group)
group_list=group_list[which(grepl(main_beam, unique(t$group)))]

# make all of the groups contained in the original GEDI dataset
for(g in 1:length(group_list)){
  h5createGroup(f, group_list[g])
  ## copy attributes
  a <- h5readAttributes(f_full,group_list[g])
  if(length(a)>0){
    fid <- H5Fopen(f)
    obj <- H5Gopen(fid, group_list[g])
    
    for(i in 1:length(names(a))){
      h5writeAttribute(attr = a[[i]], h5obj=obj, name=names(a[i]))
    }
    h5closeAll()
  }
}
#View(h5ls(f, all=T))
#unlink(paste0(wd, "NEON_GEDI_subset.h5"))



# define-datasets-of-interest ---------------------------------------------

#View(h5ls(f, all=T))
select="shot_number"
d=select
for(d in select){
  #print(d)
  d_name=paste(main_beam,d,sep="/")
  print(d_name)
  
  # Read the associated attributes (if any)
  a=h5readAttributes(f_full,paste0(main_beam,"/",d))
  
  fid <- H5Fopen(f)
  h5locobj <- H5Gopen(fid,"/")
  
  h5write((1:length(new_start_vec)), file=f, name=d_name)
  
  ## Write Attributes after data
  if(length(a)>0){
    fid <- H5Fopen(f)
    obj <- H5Dopen(fid,d_name)
    
    for(i in 1:length(names(a))){
      h5writeAttribute(attr = a[[i]], h5obj=obj, name=names(a[i]))
    }
  }
  
  h5closeAll()
  
}

#View(h5ls(f, all=T))

#View(h5ls(f, all=T))
select="rx_sample_start_index"
d=select
for(d in select){
  #print(d)
  d_name=paste(main_beam,d,sep="/")
  print(d_name)
  
  dat=new_start_vec
  
  # Read the associated attributes (if any)
  a=h5readAttributes(f_full,paste0(main_beam,"/",d))
  
  # Assign the attributes (if any) to the dataset
  attributes(dat)=a
  
  # Finally, write the dataset to the HDF5 file
  h5write(obj=dat,file=f,
          name=paste0(main_beam,"/1",d),
          write.attributes=T)
  h5closeAll()
  
  
}

#View(h5ls(f, all=T))


#View(h5ls(f, all=T))
select="rxwaveform"
d=select
for(d in select){
  #print(d)
  d_name=paste(main_beam,d,sep="/")
  print(d_name)
  
  dat=new_wf_vec
  
  # Read the associated attributes (if any)
  a=h5readAttributes(f_full,paste0(main_beam,"/",d))
  
  # Assign the attributes (if any) to the dataset
  attributes(dat)=a
  
  # Finally, write the dataset to the HDF5 file
  h5write(obj=dat,file=f,
          name=paste0(main_beam,"/1",d),
          write.attributes=T)
  h5closeAll()
  
}

#View(h5ls(f, all=T))

# values to overwrite in new H5:
# shot_number (1:length(new_start_vec))
# /rx_sample_start_index --> new_start_vec
# rxwaveform --> new_wf_vec

## Data layers used in getLevel1BWF and getLevel1BGeo
select = unique(
  c(
    "geolocation/latitude_bin0",
    "geolocation/latitude_lastbin",
    "geolocation/longitude_bin0",
    "geolocation/longitude_lastbin",
    "geolocation/shot_number",
    "geolocation/elevation_bin0",
    "geolocation/elevation_lastbin",
    "rx_sample_count"#,
    #"rx_sample_start_index",
    #"rxwaveform"
  )
)

## loop through required datasets

for(d in select){
  #print(d)
  d_name=paste(main_beam,d,sep="/")
  print(d_name)
  
  # Read the inividual dataset within the Coordinate_System group
  dat=h5read(f_full,paste0(main_beam,"/",d))
  dat=dat[shot_number_i %in% shots_from_main_beam]
  #shot_vec[shot_vec %in% shot_number_i]
  
  # Read the associated attributes (if any)
  a=h5readAttributes(f_full,paste0(main_beam,"/",d))
  
  # Assign the attributes (if any) to the dataset
  attributes(dat)=a
  
  # Finally, write the dataset to the HDF5 file
  h5write(obj=dat,file=f,
          name=paste0(main_beam,"/",d),
          write.attributes=T)
  
  h5closeAll()
  
}
