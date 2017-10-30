---
layout: post
title: "Create Interactive Plot.ly plots from R"
date:   2016-05-16
createdDate:   2016-05-17
lastModified:   2016-06-22
time:
packagesLibraries: [plotly]
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah, Naupaka, Kyla]
contributors: [Megan A. Jones]
category: remote-sensing
categories: [Remote Sensing]
tags : [lidar, R]
mainTag: institute-day3
tutorialSeries: institute-day3
description: "."
permalink: /plotly-plots-R/
comments: true
code1: institute-materials/day3_wednesday/plotly.R
image:
  feature:
  credit:
  creditlink:
---






After completing the [previous tutorial]({{site.baseurl}}/compare-lidar-to-field-data-R/),
you have an R object `p` that contains a
ggplot plot. We'll now make an interactive plot.ly plot.

If you have not completed the previous tutorial, the code for `p` can be found
in the downloadable R code for this lesson, or complete the previous tutorial.



Now we can create an interactive plot.ly plot from the `p` R object.

## Create Plot.ly Interactive Plot

Plot.ly is a free to use, online interactive data viz site. If you have the
plot.ly library installed, you can quickly export a ggplot graphic into plot.ly!
 (NOTE: it also works for python matplotlib)!! To use plotly, you need to setup
an account. Once you've setup an account, you can get your key from the plot.ly
site to make the code below work.

<a href="https://plot.ly/r/getting-started/" target="_blank">Plotly R Documentation</a>


    # install.packages("plotly")
    library(plotly)
    
    # your ggplot - object
    p

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day3_wednesday/plotly/create-local-plot-1.png)

Create a local version of a plotly plot!


    # plot your plot using plot_ly locally
    ggplotly(p)

Push a plot plot to your plotly account! Feel free to use NEON's credentials
for this week!


    # setup your plot.ly credentials
    Sys.setenv("plotly_username"="yourUserName")
    Sys.setenv("plotly_api_key"="yourAPIkey")
    
    # generate the plot
    plotly_POST(p,
                filename='NEON SJER CHM vs Insitu Tree Height') # let anyone in the world see the plot!

Check out the results!

NEON Remote Sensing Data compared to NEON Terrestrial Measurements for the SJER field site.

<div>
    <a href="https://plot.ly/~NEONDataSkills/0/" target="_blank" title="&lt;b&gt; LiDAR CHM Derived vs Measured Tree Height &lt;/b&gt;" style="display: block; text-align: center;"><img src="https://plot.ly/~NEONDataSkills/0.png" alt="&lt;b&gt; LiDAR CHM Derived vs Measured Tree Height &lt;/b&gt;" style="max-width: 100%;width: 1103px;"  width="1103" onerror="this.onerror=null;this.src='https://plot.ly/404.png';" /></a>
    <script data-plotly="NEONDataSkills:0"  src="https://plot.ly/embed.js" async></script>
</div>
