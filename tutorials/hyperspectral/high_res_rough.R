wd="~/Desktop/Hyperspectral_Tutorial/" #This will depend on your local environment
setwd(wd)
high_res=stack("2019_SJER_4_257000_4112000_image.tif")
high_res
plot(high_res)
plotRGB(high_res,
        r=1,g=2,b=3, scale=300, 
        stretch = "Lin")
e=drawExtent()


hsiStack_crop=crop(hsiStack,e)
plotRGB(hsiStack_crop,
        r=1,g=2,b=3, scale=300, 
        stretch = "Lin")
high_res_crop=crop(high_res,e)
plotRGB(high_res_crop,
        r=1,g=2,b=3, scale=300, 
        stretch = "Lin")
