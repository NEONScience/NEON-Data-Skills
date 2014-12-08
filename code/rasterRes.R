#testing Raster resolution

testData= seq(302,by=2,len=40)

#create matrix
imageMatrix<- matrix(d, nrow=10,ncol=4)

#createRaster
imageMatrixR<-raster(e,crs=("+proj=utm +zone=11 +datum=WGS84+ellps=WGS84"))


res(imageMatrixR)=c(1,1)


#define extents of the data using metadata and matrix attributes

#remember that the X extent is related to the number of COLUMNS as opposed to rows
rasExt <- extent(0,4,0,10)
extent(imageMatrixR) <- rasExt
