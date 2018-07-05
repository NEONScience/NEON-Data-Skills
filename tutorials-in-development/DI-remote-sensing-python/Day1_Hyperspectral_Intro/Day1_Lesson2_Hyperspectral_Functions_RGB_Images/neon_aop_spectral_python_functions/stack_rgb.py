def stack_rgb(reflArray,bands): 
    ''' extract and stack three bands of a reflectance array 
    --------
    Parameters
    --------
        reflArray: ndarray (m x n x #bands)
            Array of reflectance values, created from aop_h5refl2array
        bands: tuple
            Indices of bands to extract (R,G,B)

    Returns 
    --------
        stackedRGB: ndarray (m x n x 3)
            array containing 3 bands specified 
    --------

    Examples:
    --------
    >>> stack_rgbstack_rgb(sercRefl,(58,34,19)) '''
    
    import numpy as np
    
    red = reflArray[:,:,bands[0]-1]
    green = reflArray[:,:,bands[1]-1]
    blue = reflArray[:,:,bands[2]-1]
    
    stackedRGB = np.stack((red,green,blue),axis=2)
    
    return stackedRGB