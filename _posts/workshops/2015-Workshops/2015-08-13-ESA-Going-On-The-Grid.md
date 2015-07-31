---
layout: workshop
title: "ESA 2015: Going On The Grid - Gridding & Spatial Interpolation - An Intro"
estimatedTime: 1.75 Hours
packagesLibraries: 
language: []
date: 2015-08-13 10:49:52
dateCreated:   2015-08-13 10:49:52
lastModified: 2015-07-30 22:11:52
authors: Leah Wasser, Tristan Goulden
tags: [Data-Workshops, GIS-Spatial-Data]
mainTag: Data-Workshops
description: "This brown-bag style workshop, to be held at ESA 2015 in Baltimore,
 Maryland on August 13 provides an overview of the basic knowledge needed to 
begin to exploring converting point data into raster or gridding format. Most of the demonstration will be performed in ArcGIS however concepts learned can be applied to any tool that supports spatial interpolation functions."
code1: 
image:
  feature: lidar_GrandMesa.png
  credit: LiDAR data collected over Grand Mesa, Colorado - National Ecological Observatory Network (NEON)
  creditlink: http://www.neoninc.org
permalink: /Data-Workshops/ESA15-Going-On-The-Grid-Spatial-Interpolation-Basics
comments: true 
---

###A NEON #WorkWithData Event

**Date:** 13 August 2015 - Ecological Society of America Meeting

**Location:** Baltimore, Maryland

As ecologists we often need to create seamless maps, in raster or gridded format, 
of biomass, carbon, vegetation height or other metrics from points sampled on the 
landscape. However, when converting points to pixels, there are many processing 
choices that can impact the uncertainty of derived products. Incomplete 
understanding of the uncertainty in derived products, in turn, impacts downstream 
analytical and model results and can lead to erroneous conclusions drawn from the 
data. This lunchtime power workshop will demonstrate, on the fly, the impacts of 
selecting various  methods of interpolation for converting points to pixels (e.g. 
Kriging, IDW, TIN), as well as non-interpolated mathematical methods. We will use 
a height normalized LiDAR point cloud, which represents canopy height values, to 
create several raster grids of canopy height (known as a canopy height model), 
using different point-to-pixel conversion methods. We will then quantify and 
assess differences in height values derived using these different methods.

Participants will leave the workshop with a better understanding of various 
point-to-pixel conversion methods (interpolators and other gridding methods), how
 to interpret the resulting pixel values, how to perform basic raster math, and 
some of the key questions we should ask ourselves before creating a seamless grid 
from a point-based dataset. ArcGIS will be the primary demonstration tool used 
in this workshop however all concepts can be applied to any interpolation toolset.

<div id="objectives">

<h2>Background Materials</h2>

<h3>Things to Do Before the Workshop</h3>

This is a demonstration based brown-bag and thus nothing is required to attend
this workshop! However, the data used in the workshop are available to download
for further exploration.

<h4>Download The Data</h4>


<a href="#" class="btn btn-success"> 
Data to Be posted soon...</a>
<br>


<h3>Useful Background Materials:</h3>
<ul>




<li><a href="http://webapps.fundp.ac.be/geotp/SIG/interpolating.pdf" target="_blank" >An Overview Presentation on Spatial Interpolation by ESRI. </a></li>

<li><a href="http://webapps.fundp.ac.be/geotp/SIG/InterpolMethods.pdf" target="_blank" >An Overview Presentation on Spatial Interpolation Principles. </a></li>

<li><a href="http://resources.arcgis.com/en/help/main/10.2/index.html#/Understanding_interpolation_analysis/009z0000006w000000/" target="_blank" >ESRI 
Background Materials - Understanding Spatial interpolation</a></li>

</ul>

</div>


###Workshop Instructors
* **[Leah Wasser](http://www.neoninc.org/about/staff/leah-wasser) @leahawasser**, Supervising Scientist, NEON, Inc 


####Workshop Fearless Instruction Assistants

* **[Natalie Robinson](http://www.neoninc.org/about/staff/natalie-robinson)**, Staff Scientist, NEON, Inc

## #WorkWithData Hashtag
  
Please tweet using the hashtag:
  "#WorkWithData" during this workshop!

Also you can tweet at @neoninc !


##TENTATIVE SCHEDULE

Please note that we are still developing the agenda for this workshop. The schedule below is subject to change.


| Time        | Topic         | Instructor | 
|-------------|---------------|------------|
| 11:30     | Spatial Gridding vs. Interpolation |          |
| 12:00     |  |           |
| 12:30     |        | Natalie           |
| 1:00 | ------- Wrap Up! ------- |      |


##About Rasters

A raster is a dataset made up of cells or pixels. Each pixel represents a value associated with a region on the earth’s surface. We can create a raster from points through a process sometimes called gridding. Gridding is the process of taking a set of points and using them to create a surface composed of a regular grid. 


{% include _images_nolink.html url="http://neondataskills.org/images/gridding.gif" description="Animation Showing the general process of taking lidar point clouds and converting them to a Raster Format. Credits: Tristan Goulden, National Ecological Observatory Network" %}

## Grid vs. Interpolate

<figure>
    <a href="{{ site.baseurl }}/images/spatialData/Grid_Outline.png"><img src="{{ site.baseurl }}/images/spatialData/Grid_Outline.png"></a>
    
    <figcaption>When converting a set of sample points to a grid, there are many
	different approaches that should be considered.</figcaption>
</figure>

### Gridding Points
When creating a raster, you may chose to perform a direct **gridding** of the data.
This means that you calculate one value for every cell in the raster where there
are sample points. This value may be a mean of all points, a max, min or some other
mathematical function. All other cells will then have `no data` values associated with
them. This means you may have gaps in your data if the point spacing is not well 
distributed.

### Interpolating Points

Spatial **interpolation** involves calculating the value for a cell with an unknown 
value from a set of known sample point values that are distributed across an area. 
There is a general assumption that points closer to the location of the unknown cell, are more strongly related to that cell than those further away. However this general
assumption is applied differently across different interpolation functions.

### Triangulated Irregular Network (TIN)

The Triangulated Irregular Network (TIN) is a vector based surface where sample
points (nodes) are connected by a series of edges creating a triangulated surface.
The TIN remains the most true to the point distribution, density and spacing of a 
dataset. It also may yield the largest file size!

**More on TINs*

* <a href="http://resources.arcgis.com/en/help/main/10.1/index.html#//006000000001000000" target="_blank">ESRI overview of TINs</a>
* 

## Determinstic vs. Probablistic Interpolators

There are two main types of interpolation approaches:

* **Deterministic**: create surfaces from measured points, based on either the 
 extent of similarity (inverse distance weighted) or the degree of smoothing 
 (radial basis functions).  
* **Probablistic (Geostatistical)**: utilize the statistical properties of the 
 measured points. Probablistic techniques quantify the spatial autocorrelation 
 among measured points and account for the spatial configuration of the sample 
 points around the prediction location.

We will focus on deterministic methods in this workshop.

## Deterministic Interpolation Examples

Let's look at a few different deterministic interpolation methods to begin to 
understand HOW the deecisions that we make when gridding our sample points, can 
impact the final raster produced.

### Inverse Distance Weighted (IDW) 




<figure>
    <a href="https://docs.qgis.org/2.2/en/_images/idw_interpolation.png"><img src="https://docs.qgis.org/2.2/en/_images/idw_interpolation.png"></a>
    
    <figcaption>
	IDW interpolation calculates the value of an unknown cell using
	surrounding points with the assumption that closest points will be the most
	similar to the value of interest.
</figcaption>

</figure>


* Raster is derived based upon an assumed linear relationship between the location of interest and the distance to surrounding sample points.
* Sample points closest to the cell of interest are assumed to be more related
to its value than those further away.
* Exact - Grid is forced through actual sample points (when they fall in the cell center).
* Can only estimate within the range of EXISTING sample point values - this can 
yield "flattened" peaks and valleys" especially if the data didn't capture those 
high and low points.
* Point average values
* Good for data that are equally distributed and  dense. Assumes a consistent
trend / relationship between points and does not accommodate trends within the data
(e.g. east to west, etc).


<figure>
    <a href="http://www.geography.hunter.cuny.edu/~jochen/GTECH361/lectures/lecture10/3Dconcepts/Inverse%20Distance%20Weighted_files/image001.gif">
	<img src="http://www.geography.hunter.cuny.edu/~jochen/GTECH361/lectures/lecture10/3Dconcepts/Inverse%20Distance%20Weighted_files/image001.gif">
	</a>
    
    <figcaption>
	IDW interpolation looks at the linear distance between the unknown value
	and surrounding points.
</figcaption>

</figure>




#### Power

There power setting in IDW interpolation specifies how strongly points further
away from the cell value of interest impact the calculated value for that call.
Power values range from 0-3+ with a default settings generally being 2. A larger
power value produces a more localized result - values further away from the cell 
have less impact on it's calculated value, values closer to the cell impact it's 
value more. A smaller power value produces a more averaged result where sample points
further away from the cell have a greater impact on the cell's calculated value.

<figure>
    <a href="http://www.geography.hunter.cuny.edu/~jochen/GTECH361/lectures/lecture10/3Dconcepts/Inverse%20Distance%20Weighted_files/image003.gif
"><img src="http://www.geography.hunter.cuny.edu/~jochen/GTECH361/lectures/lecture10/3Dconcepts/Inverse%20Distance%20Weighted_files/image003.gif
"></a>
    
    <figcaption>
	The solid line represents more power and the dashed line represents less power. 
	The higher the power, the more localized an affect a sample point's value has on 
	the resulting surface. A smaller power value yields are smoothed or more averaged 
	surface. IMAGE SOURCE: http://www.geography.hunter.cuny.edu/~jochen/GTECH361/lectures/lecture10/3Dconcepts/Inverse%20Distance%20Weighted.htm

</figcaption>
</figure>

The impacts of power

**Lower Power Values** more averaged result, potential for a smoother surface.
As Power decreases, the influence of sample points is larger. This yields a smoother 
surface that is more averaged.

**Higher Power Values**: more localized result, potential for more peaks and 
around sample point locations.
As Power increases, the influence of sample points falls off more rapidly with 
distance. The output cell values become more localized and less averaged. 


### IDW Summary Take Home Points

GOOD FOR: 

* good for data whose distribution is strongly (and linearly) correlated with 
distance. For example, noise falls off very predictably with distance. 

* Provides explicit control over the influence of distance; (compared to Spline 
or Kriging). 

NOT AS GOOD FOR:

* Not as good for data whose distribution depends on more complex sets of variables
 because it can account only for the effects of distance. 

OTHER FEATURES:
* You can create a smoother surface by decreasing the power, increasing the 
number of sample points used, or increasing the search radius. 
* Create a surface that more closely represents the peaks and dips of your sample
points by decreasing the number of sample points used / decreasing the search 
radius, increasing the power.
* Increase IDW surface accuracy by adding breaklines to the interpolation process
that serve as barriers. Breaklines represent abrupt changes in elevation, such 
as cliffs



### Spline 

Spline interpolation fits a curved surface through the sample points of your 
dataset. Imagine stretching a rubber sheet across your points and glueing it to 
each sample point along the way. Unlike IDW, spline can estimate values above and 
below the min and max values of your sample points. thus it is good for estimating 
hight and low values not already represented in your data.
 
<figure>
    <a href="http://www.geography.hunter.cuny.edu/~jochen/GTECH361/lectures/lecture10/3Dconcepts/Spline_files/image001.gif">
	<img src="http://www.geography.hunter.cuny.edu/~jochen/GTECH361/lectures/lecture10/3Dconcepts/Spline_files/image001.gif">
	</a>
    
    <figcaption>
	Spline interpolation fits a surface between the sample points of known values
	to estimate a value for the unknown cell.
</figcaption>

</figure>


###Regularized vs Tension Spline

There are two types of curved surfaces that can be fit when using spline interpolation:

<figure>
    <a href="{{ site.baseurl }}/images/spatialData/reg_ten_Spline.png">
	<img src="{{ site.baseurl }}/images/spatialData/reg_ten_Spline.png">
	</a>
    
    <figcaption>
	Regular vs tension spline.
	</figcaption>
</figure>

1. Tension spline: a flatter surface that forces estimated values to stay closer
to the known sample points.

2. Regularized spline: a more elastic surface that is more likely to estimate above
and below the known sample points.


SPLINE IS GOOD FOR:

* Estimating values outside of the range of sample input data.
* Creating a smooth continuous surface.

NOT AS GOOD FOR:

* Points that are close together and have large value differences. Slope calculations
can yield over and underestimation.
* Data with large, sudden changes in values that need to be represented (eg fault
lines, extreme vertical topographic changes, etc). IDW allows for breaklines. NOTE:
some tools like ARCGIS have introduces a spline with barriers function in recent
years.


### More on Spline

* <a href="http://help.arcgis.com/EN/arcgisdesktop/10.0/help/index.html#//009z00000078000000.htm" target="_blank">ESRI background on spline 
interpolation.</a>