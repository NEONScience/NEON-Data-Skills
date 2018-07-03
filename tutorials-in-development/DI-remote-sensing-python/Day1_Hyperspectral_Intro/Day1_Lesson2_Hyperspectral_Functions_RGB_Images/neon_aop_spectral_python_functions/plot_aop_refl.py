def plot_aop_refl(band_array,refl_extent,colorlimit=(0,1),ax=plt.gca(),title='',cbar ='on',cmap_title='',colormap='Greys'):
    '''read in and plot a single band or 3 stacked bands of a reflectance array
    --------
    Parameters
    --------
        band_array: ndarray
            Array of reflectance values, created from aop_h5refl2array
            If 'band_array' is a 2-D array, plots intensity of values
            If 'band_array' is a 3-D array (3 bands), plots RGB image, set cbar to 'off' and don't need to specify colormap 
        refl_extent: tuple
            Extent of reflectance data to be plotted (xMin, xMax, yMin, yMax) 
            Stored in metadata['spatial extent'] from aop_h5refl2array function
        colorlimit: tuple, optional
            Range of values to plot (min,max). 
            Look at the histogram of reflectance values before plotting to determine colorlimit.
        ax: axis handle, optional
            Axis to plot on; specify if making figure with subplots. Default is current axis, plt.gca()
        title: string, optional
            plot title 
        cbar: string, optional
            Use cbar = 'on' (default), shows colorbar; use if plotting 1-band array
            If cbar = 'off' (or not 'on'), does no
        cmap_title: string, optional
            colorbar title (eg. 'reflectance', etc.)
        colormap: string, optional
            Matplotlib colormap to plot 
            see https://matplotlib.org/examples/color/colormaps_reference.html

    Returns 
    --------
        plots flightline array of single band of reflectance data
    --------

    Examples:
    --------
    >>> plot_aop_refl(sercb56,
    sercMetadata['spatial extent'],
    colorlimit=(0,0.3),
    title='SERC Band 56 Reflectance',
    cmap_title='Reflectance',
    colormap='Greys_r')'''

    import matplotlib.pyplot as plt
    
    plot = plt.imshow(band_array,extent=refl_extent,clim=colorlimit); 
    if cbar == 'on':
        cbar = plt.colorbar(plot,aspect=40); plt.set_cmap(colormap); 
        cbar.set_label(cmap_title,rotation=90,labelpad=20)
    plt.title(title); ax = plt.gca(); 
    ax.ticklabel_format(useOffset=False, style='plain'); #do not use scientific notation for ticklabels
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90); #rotate x tick labels 90 degrees