def RGBplot_widget(R,G,B):
    
	"""interactively plots an RGB image (true or false color) from a cleaned NEON reflectance array.
    --------
    Parameters
    ----------
        array : cleaned AOP reflectance array, created from aop_h5refl2array
		metadata: AOP reflectance metadata, created from aop_h5refl2array
		
	See Also:
    --------
		aop_h5refl2array

    Usage:
    --------
		run this function after defining array and metadata 
		array, metadata = h5refl2array('NEON_D02_SERC_DP3_368000_4306000_reflectance.h5')
	"""
	
    #Pre-allocate array  size
    rgbArray = np.zeros((array.shape[0],array.shape[1],3), 'uint8')
    
    Rband = array[:,:,R-1].astype(np.float)
    Gband = array[:,:,G-1].astype(np.float)
    Bband = array[:,:,B-1].astype(np.float)
    
    rgbArray[..., 0] = Rband*256
    rgbArray[..., 1] = Gband*256
    rgbArray[..., 2] = Bband*256
    
    # Apply Adaptive Histogram Equalization to Improve Contrast:
    
    img_nonan = np.ma.masked_invalid(rgbArray) #first mask the image 
    img_adapteq = exposure.equalize_adapthist(img_nonan, clip_limit=0.10)
    
    plot = plt.imshow(img_adapteq,extent=metadata['spatial extent']); 
    plt.title('Bands: \nR:' + str(R) + ' (' + str(round(metadata['wavelength'][R-1])) +'nm)'
              + '\n G:' + str(G) + ' (' + str(round(metadata['wavelength'][G-1])) + 'nm)'
              + '\n B:' + str(B) + ' (' + str(round(metadata['wavelength'][B-1])) + 'nm)'); 
    ax = plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') 
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) 
    
interact(RGBplot_widget, R=(1,426,1), G=(1,426,1), B=(1,426,1))