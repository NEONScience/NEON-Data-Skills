---
syncID: 
title: "Functions for Visualizing AOP Image Collections"
description: "Load in and visualize SDR data using a function"
dateCreated: 2022-07-27
authors: Bridget M. Hass, John Musinsky
contributors: Tristan Goulden, Lukas Straube
estimatedTime: 30 minutes
packagesLibraries: 
topics: hyperspectral, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001
code1: 
tutorialSeries: aop-gee
urlTitle: intro-aop-gee-sdr-tutorial

---
## Read in and Visualize AOP SDR Data

In the previous <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-sdr-tutorial" target="_blank">Introduction to AOP Hyperspectral Data in GEE</a> tutorial, we showed how to read in SDR data for three individual images. In this tutorial, we will show you a different, more simplified way of doing the same thing, using functions. This is called "refactoring"; as you become more proficient with GEE coding, you will learn how to do this on your own to make your scripts more readable and efficient. 
<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
- Use a function to read in and display an AOP image collection

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API. These are introduced in the tutorial <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP Data in GEE</a>, as well as in the Additional Resources below.
 * A basic understanding of hyperspectral data and the AOP spectral data products. If this is your first time working with AOP hyperspectral data, we encourage you to start with the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/hsi-hdf5-r" target="_blank">Intro to Working with Hyperspectral Remote Sensing Data in R</a> tutorial. You do not need to follow along with the code in those lessons, but at least read through to gain a better understanding NEON's spectral data products.

## Additional Resources
If this is your first time using GEE, we recommend starting on the Google Developers website, and working through some of the introductory tutorials. The links below are good places to start.
 * <a href="https://developers.google.com/earth-engine/guides/getstarted" target="_blank"> Get Started with Earth-Engine  </a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial </a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_03" target="_blank"> Functional Programming in GEE </a>

</div>

Let's get started! First let's take a look at the syntax for writing functions in GEE:
