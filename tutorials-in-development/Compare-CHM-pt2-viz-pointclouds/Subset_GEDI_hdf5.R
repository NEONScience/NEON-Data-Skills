library(rGEDI)
library(rhdf5)
wd <- "~/Downloads/" # This will depend on your local environment
setwd(wd)

#unlink(paste0(wd, "NEON_GEDI_subset.h5"))


# read-in-data ------------------------------------------------------------


f_full=paste0(wd, "GEDI01_B_2019206022612_O03482_T00370_02_003_01.h5")

# View the list of groups and datasets in the GEDI package, and save a table of that list
View(h5ls(f_full, all=T))
t=h5ls(f_full, all=T)


# make-subset-file-add-groups ---------------------------------------------

# First, create a name for the new file
f <- paste0(wd, "NEON_GEDI_subset.h5")

# create hdf5 file
h5createFile(f)

# make all of the groups contained in the original GEDI dataset
for(g in 2:length(unique(t$group))){
  h5createGroup(f, unique(t$group)[g])
  ## copy attributes
  a <- h5readAttributes(f_full,unique(t$group)[g])
  if(length(a)>0){
  fid <- H5Fopen(f)
  obj <- H5Gopen(fid, unique(t$group)[g])
  
  for(i in 1:length(names(a))){
    h5writeAttribute(attr = a[[i]], h5obj=obj, name=names(a[i]))
  }
  h5closeAll()
  }
}
#View(h5ls(f, all=T))
#unlink(paste0(wd, "NEON_GEDI_subset.h5"))


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


# define-datasets-of-interest ---------------------------------------------

roundDown <- function(x) 10^floor(log10(x))

View(h5ls(f, all=T))
select="shot_number"
d=select
for(d in select){
  #print(d)
  d_name=paste(main_beam,d,sep="/")
  print(d_name)
  
  # Read the inividual dataset within the Coordinate_System group
  dat=h5read(f_full,paste0(main_beam,"/",d), bit64conversion='bit64')
  dat2=as.character(dat)
  dat3=substr(dat2,14,nchar(dat2[1]))
  dat4=as.integer(dat3)
  
  # Read the associated attributes (if any)
  a=h5readAttributes(f_full,paste0(main_beam,"/",d))
  
  fid <- H5Fopen(f)
  h5locobj <- H5Gopen(fid,"/")
  
  #https://www.rdocumentation.org/packages/rhdf5/versions/2.16.0/topics/h5createDataset
  h5createDataset(file=f, dataset=d_name, H5type="H5T_STD_U64LE", dims = c(length(dat)))
  
  #h5write(dat, file=f, name=d_name)
  
  fid <- H5Fopen(f)
  h5locobj <- H5Gopen(fid,"/")
  
  # Write the dataset to the HDF5 file
  h5writeDataset.integer(dat4, h5loc=h5locobj,
          name=d_name)
  
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

View(h5ls(f, all=T))


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
    "rx_sample_count",
    "rx_sample_start_index",
    "rxwaveform"
  )
)

## loop through required datasets

for(d in select){
  #print(d)
  d_name=paste(main_beam,d,sep="/")
  print(d_name)
  
  # Read the inividual dataset within the Coordinate_System group
  dat=h5read(f_full,paste0(main_beam,"/",d),bit64conversion='bit64')
  
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
