## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----required libraries--------------------------------------------------
library(hazer)
library(jpeg)
library(data.table)

## ----read example, fig.show='hold', fig.height=5, fig.width=6.5----------
#read the path to the example image
jpeg_file <- system.file(package = 'hazer', 'pointreyes.jpg')

# read the image as an array
rgb_array <- jpeg::readJPEG(jpeg_file)

# plot the RGB array on the active device panel
par(mar=c(0,0,3,0))
plotRGBArray(rgb_array, bty = 'n', main = 'Point Reyes National Seashore')


## ----histogram, fig.show='hold', fig.height=5, fig.width=6.5-------------
# color channels can be extracted from the matrix
red_vector <- rgb_array[,,1]
green_vector <- rgb_array[,,2]
blue_vector <- rgb_array[,,3]

# plotting 
par(mar=c(5,4,4,2))
plot(density(red_vector), col = 'red', lwd = 2, main = 'Density function of the RGB channels', ylim = c(0,5))
lines(density(green_vector), col = 'green', lwd = 2)
lines(density(blue_vector), col = 'blue', lwd = 2)


## ----brightness, fig.show='hold', fig.height=5, fig.width=6.5------------
#extracting the brightness matrix
brightness_mat <- getBrightness(rgb_array)

# unlike the RGB array which has 3 dimensions, the brithness matrix has only two 
# dimensions and can be shown as a grayscale image,
# we can do this using the same plotRGBArray function
par(mar=c(0,0,3,0))
plotRGBArray(brightness_mat, bty = 'n', main = 'Brightness matrix')

# each pixel in the brightness image is the maximum of the  R, G and B color channel

# to extract a single brighness value for the image, depending on our needs 
#  we can perform some statistics or we can just use the mean of this matrix

# the main quantiles
quantile(brightness_mat)

#  here, I can show the histogram
par(mar=c(5,4,4,2))
hist(brightness_mat)


## ----darkness, fig.show='hold', fig.height=5, fig.width=6.5--------------
#extracting the darkness matrix
darkness_mat <- getDarkness(rgb_array)

# the darkness matrix has also two dimensions and can be shown as a grayscale image
par(mar=c(0,0,3,0))
plotRGBArray(darkness_mat, bty = 'n', main = 'Darkness matrix')

# each pixel in the darkness image is the minimum of the  R, G and B color channel

# similarly, we can do some basic statistics

# the main quantiles
quantile(darkness_mat)

#  and the histogram
par(mar=c(5,4,4,2))
hist(darkness_mat)

## ----contrast, fig.show='hold', fig.height=5, fig.width=6.5--------------
#extracting the contrast matrix
contrast_mat <- getContrast(rgb_array)

# the contrast matrix has also two dimensions and can be shown as a grayscale image
par(mar=c(0,0,3,0))

plotRGBArray(contrast_mat, bty = 'n', main = 'Contrast matrix')

# each pixel in the contrast image is the difference between the darkness and brightness matrices

# the main quantiles
quantile(contrast_mat)

#  and the histogram
par(mar=c(5,4,4,2))
hist(contrast_mat)

## ----haze, fig.show='hold', fig.height=5, fig.width=6.5------------------
#extracting the haze matrix
haze_degree <- getHazeFactor(rgb_array)

print(haze_degree)
# note that the values might be slightly differnt due to rounding errors on different platforms

## ---- eval=FALSE---------------------------------------------------------
## 
## # set up the input image
## # images_dir <- '/path/to/image/directory/'
## 
## # get a list of all .jpg files in the directory
## pointreyes_images <- dir(path = images_dir,
##                          pattern = '*.jpg',
##                          ignore.case = TRUE,
##                          full.names = TRUE)
## 
## 
## 
## ## 1) using a for loop
## # number of images
## n <- length(pointreyes_images)
## 
## # an empty matrix to fill with haze and A0 values
## haze_mat <- data.table()
## 
## pb <- txtProgressBar(0, n, style = 3)
## 
## for(i in 1:n) {
##   image_path <- pointreyes_images[i]
##   img <- jpeg::readJPEG(image_path)
##   haze <- getHazeFactor(img)
## 
##   haze_mat <- rbind(haze_mat,
##                     data.table(file = image_path,
##                                haze = haze[1],
##                                A0 = haze[2]))
## 
##   setTxtProgressBar(pb, i)
## }
## 
## 
## haze_mat[haze>0.4,foggy:=TRUE]
## haze_mat[haze<=0.4,foggy:=FALSE]
## 
## haze_mat
## 
## # move the foggy images to a new directory
## foggy_dir <-   '/path/to/foggy/images/directory/'
## 
## file.copy(haze_mat[foggy==TRUE,file], to = foggy_dir)
## file.remove(haze_mat[foggy==TRUE,file])
## 
## ## 2) using the apply functions
## # loading all the images as a list of arrays
## img_list <- lapply(pointreyes_images, FUN = jpeg::readJPEG)
## 
## # getting the haze value for the list
## haze_list <- t(sapply(img_list, FUN = getHazeFactor))
## 
## 

