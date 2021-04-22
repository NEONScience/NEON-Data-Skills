d=WREF_GEDI_footprints[[7]]@data
#for(shot_n in 2:length(WREF_GEDI_footprints)){
for(shot_n in 8:14){  
  # First, plot the NEON AOP LiDAR clipped to the GEDI footprint
  # We save the plot as an object 'p' which gives the (x,y) offset for the lower
  # left corner of the plot. The 'rgl' package offsets all (x,y) locations 
  # to this point, so we will need to subtract these values from any other 
  # (x,y) points that we want to add to the plot
  d2 = WREF_GEDI_footprints[[shot_n]]@data
  
  d=rbind(d, d2)
  
}

combined_gedi = WREF_GEDI_footprints[[1]]
combined_gedi@data=d
p=plot(combined_gedi)


for(shot_n in 7:14){
#for(shot_n in 1:length(WREF_GEDI_footprints)){
# Extract the specific waveform from the GEDI data
wf <- getLevel1BWF(gedilevel1b,shot_number = level1bgeo_WREF$shot_number[shot_n])

# Make a new data.frame 'd' to convert the waveform data coordinates into 3D space
d=wf@dt

# normalize rxwaveform to 0-1
d$rxwaveform=d$rxwaveform-min(d$rxwaveform)
d$rxwaveform=d$rxwaveform/max(d$rxwaveform)

# Add xy data in UTMs, and offset lower left corner of 'p'
d$x=st_coordinates(level1bgeo_WREF_UTM[shot_n,])[1]-p[1]
d$y=st_coordinates(level1bgeo_WREF_UTM[shot_n,])[2]-p[2]

# Make a new column 'x_wf' where we place the GEDI waveform in space with the 
# NEON AOP LiDAR data, we scale the waveform to 30m in the x-dimension, and 
# offset by 12.5m (the radius of the GEDI footprint) in the x-dimension.
d$x_wf=d$x+d$rxwaveform*30+12.5

# Add GEDI points to 3D space in 'green' color
# This time, subtracting the elevation difference for that shot
points3d(x=d$x_wf, y=d$y, z=d$elevation-net_diff[shot_n], col="green", add=T)
}
