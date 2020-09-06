#```python
from spectral import *
import spectral.io.envi as envi
import numpy as np
import matplotlib

#for clean output, to not print warnings, don't use when developing script
import warnings
warnings.filterwarnings('ignore')
#```

print('Press Enter to begin\n')
input()

#```python
img = envi.open('C:/R/data/Hyperspectral/NEON_D02_SERC_DP3_368000_4306000_reflectance.hdr',
                'C:/R/data/Hyperspectral/NEON_D02_SERC_DP3_368000_4306000_reflectance.dat')
#```

print('Press Enter to print out band center wavelengths\n')
input()


#```python
print('First 3 Band Center Wavelengths:',img.bands.centers[:3])
print('Last 3 Band Center Wavelengths:',img.bands.centers[-3:])
#```

print('\nPress enter to check image band centers for NaN values.\n')
input()


#```python
print(img.bands.centers[191:211]==np.nan)
print(img.bands.centers[281:314]==np.nan)
print(img.bands.centers[-10:]==np.nan)
#```

print('\nPress enter to get image parameters\n')
input()

#```python
print(img.params)
#```



print('\nPress enter to display image metadata:\n')
input()


#```python
md = img.metadata
print('Metadata Contents:')
for item in md:
    print('\t',item)
#```


print('\nPress enter to print description and map info\n')
input()

#```python
print('description:',md['description'])
print('map info:',md['map info'])
#```


print('\nPress enter to display wavelength type and numbers.\n')
input()

#```python
print(type(md['wavelength']))
print('Number of Bands:',len(md['wavelength']))
#```



#print('Press enter to display image')
#input()

#```python
#view = imshow(img,bands=(58,34,19),stretch=0.05,title="RGB Image of 2017 SERC Tile")
#print(view)
#```





#```python
valid_band_range = [i for j in (range(0,191), range(212, 281), range(315,415)) for i in j] #remove water vapor bands
img_subset = img.read_subimage(range(400,600),range(400,600),bands=valid_band_range) #subset image by area and bands
#```


#```python
view = imshow(img_subset,bands=(58,34,19),stretch=0.01,title="RGB Image of 2017 SERC Tile Subset")
#```


print('Beginning kmeans...\n')

#```python
(m,c) = kmeans(img_subset,5,50) 
#```


print('Press Enter to view cluster center info\n')
input()


#```python
print(c.shape)
#```


print('Press enter to display Spectral Classes\n')
input()


#```python
#%matplotlib inline
import pylab
pylab.figure()
pylab.hold(1)
for i in range(c.shape[0]):
    pylab.plot(c[i])
pylab.show
pylab.title('Spectral Classes from K-Means Clustering')
pylab.xlabel('Bands (with Water Vapor Windows Removed)')
pylab.ylabel('Reflectance')
#```


#```python
#%matplotlib notebook
view = imshow(img_subset, bands=(58,34,19),stretch=0.01, classes=m)
view.set_display_mode('overlay')
view.class_alpha = 0.5 #set transparency
view.show_data
#```


print('Press enter to quit')
input()