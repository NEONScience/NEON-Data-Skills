---
syncID: 
title: "Importing AOP Cloud Optimized Geotiffs into Google Earth Engine"
description: "Introductory tutorial on importing AOP COG datasets into GEE."
dateCreated: 2022-05-29
authors: Bridget M. Hass
contributors: Tristan Goulden, John Musinsky
estimatedTime: 30 minutes
packagesLibraries: 
topics: lidar, hyperspectral, camera, remote-sensing
languageTool: GEE
dataProducts: DP3.30006.001, DP3.30010.001, DP3.30015.001, DP3.30024.001, DP3.30025.001
code1: 
tutorialSeries: aop-gee
urlTitle: importing-aop-cog-gee

---

AOP has a small subsets of sites uploaded into GEE to the `projects/neon` folder. We realize this excludes a lot of study areas, so this tutorial shows you how to upload other AOP GeoTIFF image files to your personal folder. GEE allows you to upload files up to 10 GB in size to your Earth Engine user folder. For larger files, you can use the <a href="https://developers.google.com/earth-engine/guides/command_line#upload" target="_blank"> command-line upload option</a>.

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
 * Import AOP cloud-optimized geotiffs data as an Asset into Google Earth Engine (GEE)
 * Display the datasets in the GEE Interactive Map

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API.
 * AOP data converted into the COG data format. 

## Additional Resources

 * If you need to convert AOP data to COG format, refer to the R tutorial <a href="" target="_blank"> AOP Mosaic Raster to COG </a>. This outlines how to download AOP L3 (tiled) raster data products, mosaic the tiles, and save the full-site rasters to a geotiff and COG.

 * For more information on uploading data into your personal workspace, refer to the Google Developers website documentation on asset management and uploading images below:
   - <a href="https://developers.google.com/earth-engine/guides/asset_manager" target="_blank"> Earth-Engine Managing Assets </a>
   - <a href="https://developers.google.com/earth-engine/guides/image_upload" target="_blank"> Earth-Engine Image Upload </a>

</div>

## AOP GEE Data Availability & Access

If you would like to work with AOP data that has not already been uploaded to the `projects/neon` folder (as outlined in the previous lesson, <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP data in GEE</a> Earth-Engine Managing Assets </a>), this tutorial will walk you through importing your own COG datasets. 

To convert AOP L3 data products from geotiff or h5 file formats to COG format, refer to the following R tutorials:
* Converting AOP rasters to Cloud Optimized Geotiffs
* Converting AOP h5 reflectance files to Cloud Optimized Geotiffs

This example will use the site <a href="https://www.neonscience.org/field-sites/mcra" target="_blank">McRae Creek, MCRA</a> in Domain 16 (Pacific Northwest). This is an aquatic site, and one of the smaller AOP flight-boxes, which makes it ideal for demonstration.

## Uploading AOP Geotiff Images into GEE

To upload a GeoTIFF using the Code Editor, click on the **Assets** tab in the upper left corner, then select "GeoTIFF (.tif, .tiff) or TFRecord (.tfrecord + .json) under **Image upload**. Earth Engine presents an upload dialog which should look similar to the figure below. Click the **SELECT** button and navigate to a GeoTIFF on your local file system, or alternatively you can drag and drop the file.

<figure>
	<a href="https://developers.google.com/earth-engine/images/Code_editor_diagram.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1b_upload_assets/upload_new_image_asset.png" width="350" alt="Upload New Image Asset Window."></a>
</figure>

Give the image an appropriate asset ID (which doesn't already exist) in your user folder. If you'd like to upload the image into an existing folder or collection, prefix the asset ID with the folder or collection ID, for example /users/name/folder-or-collection-id/new-asset.



