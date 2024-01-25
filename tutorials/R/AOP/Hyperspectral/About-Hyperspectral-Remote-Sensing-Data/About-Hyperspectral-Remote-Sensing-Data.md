---
syncID: d7e725d81a784a368de5089f072c9052
title: "About Hyperspectral Remote Sensing Data"
description: "Learn about the fundamental principles of hyperspectral remote sensing data."
dateCreated: 2014-1-10
authors: Leah A. Wasser
contributors: Donal O'Leary, Felipe Sanchez
estimatedTime: 0.25 - 0.5 Hours
packagesLibraries:
topics: hyperspectral, HDF5, remote-sensing 
languagesTool:
dataProduct:
code1: 
tutorialSeries: intro-hsi-r-series
urlTitle: hyper-spec-intro
---

<div id="ds-objectives" markdown="1">
 
## Learning Objectives
After completing this tutorial, you will be able to:

* Define hyperspectral remote sensing. 
* Explain the fundamental principles of hyperspectral remote sensing data.
* Describe the key attributes that are required to effectively work with 
  hyperspectral remote sensing data in tools like R or Python.
* Describe what a "band" is.

</div>

#### Mapping the Invisible

<iframe width="640" height="360" src="https://www.youtube.com/embed/3iaFzafWJQE?rel=0" frameborder="0" allowfullscreen></iframe>


## About Hyperspectral Remote Sensing Data

The electromagnetic spectrum is composed of thousands of bands representing 
different types of light energy. Imaging spectrometers (instruments that collect 
hyperspectral data) break the electromagnetic spectrum into groups of bands 
that support classification of objects by their spectral properties on the 
earth's surface. Hyperspectral data consists of many bands -- up to hundreds of 
bands -- that cover the electromagnetic spectrum.

The NEON imaging spectrometer collects data within the 380nm to 2510nm portions 
of the electromagnetic spectrum within bands that are approximately 5nm in 
width. This results in a hyperspectral data cube that contains approximately 
426 bands - which means big, big data.

## Key Metadata for Hyperspectral Data

### Bands and Wavelengths

A *band* represents a group of wavelengths. For example, the wavelength values 
between 695nm and 700nm might be one band as captured by an imaging spectrometer. 
The imaging spectrometer collects reflected light energy in a pixel for light 
in that band. Often when you work with a multi or hyperspectral dataset, the 
band information is reported as the center wavelength value. This value 
represents the center point value of the wavelengths represented in that band. 
Thus in a band spanning 695-700 nm, the center would be 697.5).

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral-general/spectrumZoomed.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral-general/spectrumZoomed.png"
    alt="Graphic showing an example of how bands or regions of visible light, within the electromagnetic spectrum, are devided when captured by imaging spectrometers.">
    </a>
    <figcaption>Imaging spectrometers collect reflected light information within 
    defined bands or regions of the electromagnetic spectrum. Source: National 
    Ecological Observatory Network (NEON) </figcaption>
</figure>

### Spectral Resolution
The spectral resolution of a dataset that has more than one band, refers to the 
width of each band in the dataset. In the example above, a band was defined as 
spanning 695-700nm. The width or spatial resolution of the band is thus 5 
nanometers. To see an example of this, check out the band widths for the 
<a href="http://landsat.usgs.gov/band_designations_landsat_satellites.php" target="_blank">Landsat sensors</a>.

 
### Full Width Half Max (FWHM)
The full width half max (FWHM) will also often be reported in a multi or 
hyperspectral dataset. This value represents the spread of the band around that 
center point. 

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral-general/FWHM2.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral-general/FWHM2.png"
    alt="Graphic showing an example of the Full Width Half Max value of a band. The full width half band value is determined by the relative distance in nanometers between the band center and the edge of the band.">
    </a>
    <figcaption>The Full Width Half Max (FWHM) of a band relates to the distance 
    in nanometers between the band center and the edge of the band. In this 
    case, the FWHM for Band C is 5 nm.</figcaption>
</figure>

In the illustration above, the band that covers 695-700nm has a FWHM of 5 nm. 
While a general spectral resolution of the sensor is often provided, not all 
sensors create bands of uniform widths. For instance bands 1-9 of Landsat 8 are 
listed below (Courtesy of <a href="http://landsat.usgs.gov" target="_blank">USGS</a>)


| Band | Wavelength range (microns) | Spatial Resolution (m) | Spectral Width (microns)|
|-------------------------------------|------------------|--------------------|----------------|
| Band 1 - Coastal aerosol | 0.43 - 0.45 | 30 | 0.02 |
| Band 2 - Blue | 0.45 - 0.51 | 30 | 0.06 |
| Band 3 - Green | 0.53 - 0.59 | 30 | 0.06 |
| Band 4 - Red | 0.64 - 0.67 | 30 | 0.03 |
| Band 5 - Near Infrared (NIR) | 0.85 - 0.88 | 30 | 0.03 |
| Band 6 - SWIR 1 | 1.57 - 1.65 | 30 | 0.08  |
| Band 7 - SWIR 2 | 2.11 - 2.29 | 30 | 0.18 |
| Band 8 - Panchromatic | 0.50 - 0.68 | 15 | 0.18 |
| Band 9 - Cirrus | 1.36 - 1.38 | 30 | 0.02 |





