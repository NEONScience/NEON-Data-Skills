library(rGEDI)

extent(chm)
chm_WGS = projectRaster(chm, crs=CRS("+init=epsg:4326"))
plot(chm_WGS)
base_WGS = st_transform(base_crop, crs=CRS("+init=epsg:4326"))
plot(base_WGS, add=T)

# Study area boundary box coordinates
# entire Tile
ul_lat<- extent(chm_WGS)[4]
lr_lat<- extent(chm_WGS)[3]
ul_lon<- extent(chm_WGS)[1]
lr_lon<- extent(chm_WGS)[2]

# ul_lat<- -44.0654
# lr_lat<- -44.17246
# ul_lon<- -13.76913
# lr_lon<- -13.67646

e=drawExtent()

ul_lat<- e[4]
lr_lat<- e[3]
ul_lon<- e[1]
lr_lon<- e[2]


# Specifying the date range
daterange=c("2019-07-01","2020-05-22")

# Get path to GEDI data
gLevel1B<-gedifinder(product="GEDI01_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001",daterange=daterange)
gLevel2A<-gedifinder(product="GEDI02_A",ul_lat, ul_lon, lr_lat, lr_lon,version="001",daterange=daterange)
gLevel2B<-gedifinder(product="GEDI02_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001",daterange=daterange)

# Set output dir for downloading the files
outdir=getwd()

# Downloading GEDI data
gediDownload(filepath=gLevel1B,outdir=outdir)
gediDownload(filepath=gLevel2A,outdir=outdir)
gediDownload(filepath=gLevel2B,outdir=outdir)

#** Herein, we are using only a GEDI sample dataset for this tutorial.
# downloading zip file
zipfile = file.path(outdir, "examples.zip")
download.file("https://github.com/carlos-alberto-silva/rGEDI/releases/download/datasets/examples.zip",destfile=zipfile)

# unzip file
unzip(zipfile, exdir=outdir)