library(devtools)
library(plotly)
library(dplyr)
library(ggplot2)
library(rhdf5)

f <- '/Users/lwasser/Documents/GitHub/NEON_HigherEd/data/NEON_TowerDataD3_D10.hdf5'
## Get names of elements in our file
fiu_struct <- h5ls(f,all=T)
## Concatenate the second element.
g <- paste(fiu_struct[2,1:2],collapse="/")
## Check out what that element is
print(g)
## Now view the metadata
h5readAttributes(f,g)

# Set the path string
s <- "/Domain_03/Ord/min_1"
### Grab the paths
paths <- fiu_struct %>% filter(grepl(s,group), grepl("DATA",otype)) %>% group_by(group) %>% summarise(path = paste(group,name,sep="/"))
ord_temp <- data.frame()
for(i in paths$path){
  boom <-  strsplit(i,"/")[[1]][5]
  dat <- h5read(f,i)
  dat$boom <- rep(boom,dim(dat)[1])
  ord_temp <- rbind(ord_temp,dat)
}
### Dates aren't dates though, so let's fix that
ord_temp$date <- as.POSIXct(ord_temp$date,format = "%Y-%m-%d %H:%M:%S", tz = "EST")
## Now we can make our plot!
testing<- ggplot(ord_temp,aes(x=date,y=mean,group=boom,colour=boom))+geom_path()+ylab("Mean Temperature - Degrees C") + xlab("Date")+theme_bw()+ggtitle("3 Days of temperature data at NEON Site: Ordway Swisher")+scale_colour_discrete(name="Tower Levels")

finalPlot<-testing + scale_colour_discrete(name="Tower Levels",
                         breaks=c("boom_1", "boom_2", "boom_3", "boom_5", "tower_top"),
                         labels=c("Tower Bottom", "Boom 2", "Boom 3", "Boom 5", "Tower Top"))
finalPlot

#plot in plotly

py <- plotly(username="leahawasser", key="tpdjz2b8pu")
out <- py$ggplotly(finalPlot)

plotly_url <- out$response$url