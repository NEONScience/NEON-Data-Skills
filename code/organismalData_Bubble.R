#viz of data...

library(maps)
map("state", interior = FALSE)
map("state", boundary = FALSE, col="gray", add = TRUE)


http://flowingdata.com/2010/11/23/how-to-make-bubble-charts/
  
  
crime <- read.csv("http://datasets.flowingdata.com/crimeRatesByState2005.tsv", header=TRUE, sep="\t")
symbols(crime$murder, crime$burglary, circles=crime$population)

radius <- sqrt( crime$population/ pi )
symbols(crime$murder, crime$burglary, circles=radius)
symbols(crime$murder, crime$burglary, circles=radius, inches=0.35, fg="white", bg="red", xlab="Murder Rate", ylab="Burglary Rate")
