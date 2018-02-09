def RGBplot_widget(R,G,B):
    
    #Pre-allocate array  size
    rgbArray = np.zeros((array.shape[0],array.shape[1],3), 'uint8')
    
    Rband = array[:,:,R-1].astype(np.float)
    Rband_clean = clean_band(Rband,Refl_md)
    
    Gband = array[:,:,G-1].astype(np.float)
    Gband_clean = clean_band(Gband,Refl_md)
    
    Bband = array[:,:,B-1].astype(np.float)
    Bband_clean = clean_band(Bband,Refl_md)
    
    rgbArray[..., 0] = Rband_clean*256
    rgbArray[..., 1] = Gband_clean*256
    rgbArray[..., 2] = Bband_clean*256
    
    # Apply Adaptive Histogram Equalization to Improve Contrast:
    
    img_nonan = np.ma.masked_invalid(rgbArray) #first mask the image 
    img_adapteq = exposure.equalize_adapthist(img_nonan, clip_limit=0.10)
    
    plot = plt.imshow(img_adapteq,extent=clipExt); 
    plt.title('Bands: \nR:' + str(R) + ' (' + str(round(wavelengths.value[R-1])) +'nm)'
              + '\n G:' + str(G) + ' (' + str(round(wavelengths.value[G-1])) + 'nm)'
              + '\n B:' + str(B) + ' (' + str(round(wavelengths.value[B-1])) + 'nm)'); 
    ax = plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') 
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) 
    
interact(RGBplot_widget, R=(1,426,1), G=(1,426,1), B=(1,426,1))