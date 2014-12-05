library("rhdf5")
library("devtools")
library("plotly")


#setup plotly credentials
set_credentials_file("leahawasser", "tpdjz2b8pu")
l <- plotly(username="leahawasser", key="tpdjz2b8pu")

#REAL WORLD DATA EXAMPLE
#r load file (make sure the path is correct!!)
#MAC f <- "/Users/law/Documents/GitHub_Lwasser/NEON_HigherEd/data/fiuTestFile.hdf5"
f <- '/Users/lwasser/Documents/GitHub/NEON_HigherEd/data/NEON_TowerDataD3_D10.hdf5'
h5ls(f,all=T)

# HDF5 allows us to quickly extract parts of a dataset or even groups.
# extract temperature data from one site (Ordway Swisher, Florida) and plot it

temp <- h5read(f,"/Domain_03/Ord/min_1/boom_1/temperature")
#view the header and the first 6 rows of the dataset


set_credentials_file("leahawasser", "tpdjz2b8pu")
p <- plotly(username="leahawasser", key="tpdjz2b8pu")

head(temp)
plot(temp$mean,type='l')
response = p$plotly(temp$mean,type='l')
browseURL(response$url)



library(plotly)
or=temp

py <- plotly(username="leahawasser", key="tpdjz2b8pu")

#or$A <- temp$mean
#fit the dates
temp$date <- as.POSIXct(temp$date ,format = "%Y-%m-%d %H:%M:%S", tz = "EST")

orange <- qplot (date,mean,data=temp,geom="line", title="hello",
                 main="Mean Temperature - Ordway Swisher", xlab="Date", 
                 ylab="Mean Temperature (Degrees C)")

orange2<-orange + theme(axis.title=element_text(face="bold.italic", 
                                  size="24", color="brown"))
orange2

out <- py$ggplotly(orange)

plotly_url <- out$response$url


##############################################
#End plot one
#############################################




