# How To Contribute a Lesson To This Site

1. Create a markdown (.md) file. Be sure to copy the YAML template header. Then fill out the various YAML categories:
 
---
layout: post
title: "R: Create a Canopy Height Model from LiDAR derived Rasters (grids) in R"
date:   2014-7-18 20:49:52
createdDate:   2014-07-21 20:49:52
lastModified:   2015-5-11 19:33:52
estimatedTime: 3.0 - 3.5 Hours
packagesLibraries: raster, sp, dplyr, maptools, rgeos
authors: Edmund Hart, Leah A. Wasser
category: remote-sensing
categories: [Remote Sensing]
tags : [lidar, R]
mainTag: lidar
description: "Bring LiDAR-derived raster data (DSM and DTM) into R to create a final canopy height model representing the actual vegetation height with the influence of elevation removed. Then compare lidar derived height (CHM) to field measured tree height to estimate uncertainty in lidar estimates."
permalink: /lidar-data/lidar-data-rasters-in-R/
comments: true
code1: Create_Lidar_CHM.R
image:
  feature: textur2_pointsProfile.png
  credit: National Ecological Observatory Network (NEON)
  creditlink: http://www.neonscience.org
--- 

1. Save your file in the _posts directory. Please get in touch if you are unsure of what directory to save your file in!
2. Submit the PR!