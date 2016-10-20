---
layout: post
title: "Interactive Data Vizualization with R and Plotly"
date: 2016-10-19
createdDate: 2014-12-06
authors: [Megan A. Jones, Leah A. Wasser]
lastModified: 2016-10-20
categories: [self-paced-tutorial]
tags: [R, data-viz]
mainTag: data-viz
librariesPackages: [ggplot, plotly]
description: "Learn the basics of how to use the plotly package to create 
interactive plots and use the Plotly API in R to share these plots."
code1: 
image:
  feature: lidar_GrandMesa.png
  credit: LiDAR data collected over Grand Mesa, Colorado - National Ecological Observatory Network (NEON)
  creditlink:
permalink: /R/Plotly
code1:
comments: true
---

{% include _toc.html %}

## Plotly - Interactive (and Online) Plots

<a href="https://plot.ly/" target="_blank"> Plotly</a> 
bills itself as "a collaborative platform for modern data science". You can use
it to build  interactive plots that can easily be shared with others (like
the
<a href="http://{{ site.baseurl }}/teaching-module/disturb-event-co13/detailed-lesson#drought" target="_blank"> Disturbance Events lessons</a>). 

You will need an free online Plotly account to post & share you plots online. But
you can create the plots and use them on your local computer without an account.
If you do not wish to share plots online you can skip to 
**Step 3: Create Plotly plot**. 

Additional information on the `plotly` R package can be found 
<a href="https://plot.ly/r/getting-started/" target="_blank"> on the Plotly R Getting Started page</a>.  

Note: Plotly doesn't just work with R -- other programs include Python, MATLAB,
Excel, and JavaScript. 

### Step 1: Create account
If you do not already have an account, you need to set up an account by visiting
the <a href="https://plot.ly/" target="_blank" >Plotly</a> website and following
the directions there.

### Step 2: Connect account to R 

To share plots from R (or RStudio) to Plotly, you have to connect to your 
account.  This is done through an API (Application Program Interface). You can
find your username & API key in your profile settings on the Plotly website 
under the "API key" menu option.  

To link your account to your R, use the following commands, substituting in your
own username & key as appropriate. 


    # set plotly user name
    Sys.setenv("plotly_username"="YOUR_plotly_username")
    # set plotly API key
    Sys.setenv("plotly_api_key"="YOUR_api_key")

### Step 3: Create Plotly plot
There are lots of ways to plot with the plotly package. We breifly describe two 
basic functions `plotly()` and `ggplotly()`. For more information on plotting in
R with Plotly, check out the 
<a href="https://plot.ly/r/" target="_blank"> Plotly R library page. 

Here we use the example dataframe `economics` that comes with the package. 


    # Set working directory to the data directory
    # setwd("YourFullPathToDataDirectory")
    
    
    # load packages
    library(plotly)  # to create interactive plots
    library(ggplot2) # to create plots and feed to ggplotly()
    
    # view str of example data set
    str(economics)

    ## Classes 'tbl_df', 'tbl' and 'data.frame':	574 obs. of  6 variables:
    ##  $ date    : Date, format: "1967-07-01" "1967-08-01" ...
    ##  $ pce     : num  507 510 516 513 518 ...
    ##  $ pop     : int  198712 198911 199113 199311 199498 199657 199808 199920 200056 200208 ...
    ##  $ psavert : num  12.5 12.5 11.7 12.5 12.5 12.1 11.7 12.2 11.6 12.2 ...
    ##  $ uempmed : num  4.5 4.7 4.6 4.9 4.7 4.8 5.1 4.5 4.1 4.6 ...
    ##  $ unemploy: int  2944 2945 2958 3143 3066 3018 2878 3001 2877 2709 ...

    # plot with the plot_ly function
    unempPerCapita <- plot_ly(economics, x = date, y = unemploy/pop)
    unempPerCapita 

![ ]({{ site.baseurl }}/images/rfigs/DATAVIZ/DataVis-plotly-R/create-plotly-plot-1.png)

Note: This plot is interactive within the R environment but is not as posted on
this website. 

If you already use ggplot to create your plots, you can directly turn your 
ggplot objects into interactive plots with `ggplotly()`. 


    ## plot with ggplot, then ggplotly
    
    unemployment <- ggplot(economics, aes(date,unemploy)) + geom_line()
    unemployment

![ ]({{ site.baseurl }}/images/rfigs/DATAVIZ/DataVis-plotly-R/ggplotly-1.png)

    ggplotly(unemployment)

![ ]({{ site.baseurl }}/images/rfigs/DATAVIZ/DataVis-plotly-R/ggplotly-2.png)

Note: This plot is interactive within the R environment but is not as posted on
this website. 

### Step 4: Publish to Plotly

The function `plotly_POST()` allows you to post any plotly plot to your account. 


    # publish plotly plot to your plotly online account
    plotly_POST(unemployment)

## Examples

The plots below were generated using R code that harnesses the power of the
`ggplot2` and the `plotly` packages. The plotly code utilizes the <a href="http://ropensci.org/packages/" target="_blank">RopenSci `plotly` packages - check them out!</a>

<iframe width="460" height="293" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/24.embed?width=460&height=293"></iframe>


<iframe width="460" height="345" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/6.embed?width=460&height=345"></iframe>


<iframe width="560" height="420" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/16.embed?width=800&height=600"></iframe>

<iframe width="560" height="420" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/19.embed?width=800&height=600"></iframe>


<i class="fa fa-star"></i> **Data Tip** Are you a Python user? Use `matplotlib` 
to create and publish visualizations.
{: .notice}


