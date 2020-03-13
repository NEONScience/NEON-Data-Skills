def plot_aop_rgb(rgbArray,ext,ls_pct=5,plot_title=''):
    
    ''' read in and plots 3 bands of a reflectance array as an RGB image
    --------
    Parameters
    --------
        rgbArray: ndarray (m x n x 3)
            3-band array of reflectance values, created from stack_rgb
        ext: tuple
            Extent of reflectance data to be plotted (xMin, xMax, yMin, yMax) 
            Stored in metadata['spatial extent'] from aop_h5refl2array function
        ls_pct: integer or float, optional
            linear stretch percent
        plot_title: string, optional
            image title

    Returns 
    --------
        plots RGB image of 3 bands of reflectance data
    --------

    Examples:
    --------
    >>> plot_aop_rgb(SERCrgb,
                     sercMetadata['spatial extent'],
                     plot_title = 'SERC RGB')'''
    
    from skimage import exposure
    
    pLow, pHigh = np.percentile(rgbArray[~np.isnan(rgbArray)], (ls_pct,100-ls_pct))
    img_rescale = exposure.rescale_intensity(rgbArray, in_range=(pLow,pHigh))
    plt.imshow(img_rescale,extent=ext)
    plt.title(plot_title + '\n Linear ' + str(ls_pct) + '% Contrast Stretch'); 
    ax = plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation #
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degree