---
syncID: 03868e86e4d34d1fa88caacaddf95a57
title: "Plot Continuous & Discrete Data Together"
description: "This tutorial discusses ways to plot plant phenology (discrete time series) and single-aspirated temperature (continuous time series) together."
dateCreated: 2017-08-01
authors: Lee Stanish, Megan A. Jones, Natalie Robinson
contributors: Katie Jones, Cody Flagg
estimatedTime:
packagesLibraries: dplyr, ggplot2, lubridate, gridExtra, scales
topics: timeseries, meteorology, phenology, organisms
languagesTool: R
dataProduct: NEON.DP1.10055, 
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/biodiversity/neon-phenology-temp/03-plot-discrete-continuous-data-pheno-temp/03-plot-discrete-continuous-data-pheno-temp.R
tutorialSeries:  neon-pheno-temp-series
urlTitle: neon-pheno-temp-plots-r
---

This tutorial discusses ways to plot plant phenology (discrete time
series) and single-aspirated temperature (continuous time series) together.

<div id="ds-objectives" markdown="1">

## Objectives
After completing this tutorial, you will be able to:

 * plot multiple figures together with grid.arrange()
 * plot only a subset of dates

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages
* **ggplot2:** `install.packages("ggplot2")`
* **gridExtra:** `install.packages("gridExtra")`
* **dplyr:** `install.packages("dplyr")`
* **lubridate:** `install.packages("lubridate")`
* **scales:** `install.packages("scales")`


<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Download Data 

<h3> <a href="https://ndownloader.figshare.com/files/9012085">
NEON Teaching Data Subset: Plant Phenology & Single Aspirated Air Temperature</a></h3>


The data used in this lesson were collected at the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map" target="_blank"> Domain 02 field sites</a>. 
This teaching data subset represent a small subset of the data NEON will collect over 
30 years and at 20 domains across the United States. NEON data are available on the
<a href="http://data.neonscience.org/" target="_blank">NEON data portal</a>. 

<a href="https://ndownloader.figshare.com/files/9012085" class="link--button link--arrow">
Download Dataset</a>





****
**Set Working Directory:** This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce 
learned skills. If available, the code for challenge solutions is found in the
downloadable R script of the entire lesson, available in the footer of each lesson page.


</div>

First, we'll set up the environment. If you are continuing from the last 
tutorial, simply load the new packages, as you already have the data as an R 
object. 


    # Load required libraries
    library(ggplot2)
    library(dplyr)
    library(lubridate)
    library(gridExtra)
    library(scales)  # use with date_breaks
    
    # set working directory to ensure R can find the file we wish to import
    # setwd("working-dir-path-here")
    
    # Read in data -> if in series this is unnecessary
    temp_day <- read.csv('NEON-pheno-temp-timeseries/temp/NEONsaat_daily_SCBI_2016.csv',
    		stringsAsFactors = FALSE)

    ## Warning in file(file, "rt"): cannot open file 'NEON-pheno-temp-timeseries/temp/
    ## NEONsaat_daily_SCBI_2016.csv': No such file or directory

    ## Error in file(file, "rt"): cannot open the connection

    phe_1sp_2016 <- read.csv('NEON-pheno-temp-timeseries/pheno/NEONpheno_LITU_Leaves_SCBI_2016.csv',
    		stringsAsFactors = FALSE)

    ## Warning in file(file, "rt"): cannot open file 'NEON-pheno-temp-timeseries/pheno/
    ## NEONpheno_LITU_Leaves_SCBI_2016.csv': No such file or directory

    ## Error in file(file, "rt"): cannot open the connection

    # Convert dates
    temp_day$sDate <- as.Date(temp_day$sDate)

    ## Error in as.Date(temp_day$sDate): object 'temp_day' not found

    phe_1sp_2016$date <- as.Date(phe_1sp_2016$date)

    ## Error in as.Date(phe_1sp_2016$date): object 'phe_1sp_2016' not found

## Aligned Plots

We've previously looked at the plots apart, but let's plot them in the same 
pane. 

We can do this with the `grid.arrange()` function from the gridExtra package. 


    phenoPlot <- ggplot(phe_1sp_2016, aes(date, n.y)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Total Individuals in Leaf") +
        xlab("Date") + ylab("Number of Individuals") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(phe_1sp_2016, aes(date, n.y)): object 'phe_1sp_2016' not found

    phenoPlot

    ## Error in eval(expr, envir, enclos): object 'phenoPlot' not found

    tempPlot_dayMax <- ggplot(temp_day, aes(sDate, dayMax)) +
        geom_point() +
        ggtitle("Daily Max Air Temperature") +
        xlab("") + ylab("Temp (C)") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(temp_day, aes(sDate, dayMax)): object 'temp_day' not found

    tempPlot_dayMax

    ## Error in eval(expr, envir, enclos): object 'tempPlot_dayMax' not found

    # Output with both plots
    grid.arrange(phenoPlot, tempPlot_dayMax) 

    ## Error in arrangeGrob(...): object 'phenoPlot' not found


### Format Dates in Axis Labels
Hmmm... the x-axis on both plots is kinda wonky. For the pheno data, We might 
want a different
date display format (e.g. 2016-07 vs. Jul); for the temp data there are a TON of tick
marks! These parameters can be adujusted with `scale_x_date`. Let's format the x-axis
ticks so they read "month" (`%b`) in both graphs. We will use the syntax:

`scale_x_date(labels=date_format("%b"")`

Rather than re-coding the entire plot, we can add the `scale_x_date` element
to the plot object `phenoPlot` we just created. 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** You can type `?strptime` into the R 
console to find a list of date format conversion specifications (e.g. %b = month).
Type `scale_x_date` for a list of parameters that allow you to format dates 
on the x-axis.
</div>

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** If you are working with a date & time
class (e.g. POSIXct), you can use `scale_x_datetime` instead of `scale_x_date`.
</div>


    # format x-axis: dates
    phenoPlot <- phenoPlot + 
      (scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")))

    ## Error in eval(expr, envir, enclos): object 'phenoPlot' not found

    phenoPlot

    ## Error in eval(expr, envir, enclos): object 'phenoPlot' not found

    tempPlot_dayMax <- tempPlot_dayMax +
      (scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")))

    ## Error in eval(expr, envir, enclos): object 'tempPlot_dayMax' not found

    tempPlot_dayMax

    ## Error in eval(expr, envir, enclos): object 'tempPlot_dayMax' not found

    # Output with both plots
    grid.arrange(phenoPlot, tempPlot_dayMax) 

    ## Error in arrangeGrob(...): object 'phenoPlot' not found

### Align Datasets

We have different start and end dates, which makes it harder to see trends. 
Let's align the datasets and replot


    # align dates
    temp_day_fit <- filter(temp_day, sDate >= min(phe_1sp_2016$date) & sDate <= max(phe_1sp_2016$date))

    ## Error in filter(temp_day, sDate >= min(phe_1sp_2016$date) & sDate <= max(phe_1sp_2016$date)): object 'temp_day' not found

    # Check it
    range(phe_1sp_2016$date)

    ## Error in eval(expr, envir, enclos): object 'phe_1sp_2016' not found

    range(temp_day_fit$sDate)

    ## Error in eval(expr, envir, enclos): object 'temp_day_fit' not found

    #plot again
    tempPlot_dayMax_corr <- ggplot(temp_day_fit, aes(sDate, dayMax)) +
        geom_point() +
        scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) +
        ggtitle("Daily Max Air Temperature") +
        xlab("") + ylab("Temp (C)") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(temp_day_fit, aes(sDate, dayMax)): object 'temp_day_fit' not found

    grid.arrange(phenoPlot, tempPlot_dayMax_corr)

    ## Error in arrangeGrob(...): object 'phenoPlot' not found

## Same plot with two Y-axes

What about layering these plots and having two y-axes (right and left) that have
the different scale bars. This might look cool. 

However, some argue that you should not do this as it 
can distort what is actually going on with the data. The author of the ggplot2 
package is one of these individuals. Therefore, you cannot use `ggplot()` to 
create a single plot with multiple Y scales. You can read his own discussion of
the topic on this 
<a href="https://stackoverflow.com/questions/3099219/plot-with-2-y-axes-one-y-axis-on-the-left-and-another-y-axis-on-the-right/3101876#3101876" target="_blank" > StackOverflow post</a>.

---

However, individuals have found work arounds for these plots. The below code
is provided as a demonstration of this capability. Note, by showing this code 
here, we don't necessarily endorse having plots with two y-axes.

This code is adapted from code by <a href="heareresearch.blogspot.com/2014/10/10-30-2014-dual-y-axis-graph-ggplot2_30.html" target="_blank">Jake Heare</a>. 


    # Source: http://heareresearch.blogspot.com/2014/10/10-30-2014-dual-y-axis-graph-ggplot2_30.html
    
    # Additional packages needed
    library(gtable)
    library(grid)
    
    
    #Pheno data as bars, temp as scatter
    grid.newpage()
    phenoPlot_2 <- ggplot(phe_1sp_2016, aes(date, n.y)) +
      geom_bar(stat="identity", na.rm = TRUE) +
      scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) +
      ggtitle("Total Individuals in Leaf vs. Temp (C)") +
      xlab("Date") + ylab("Number of Individuals") +
      theme_bw()+
      theme(legend.justification=c(0,1),
            legend.position=c(0,1),
            plot.title=element_text(size=25,vjust=1),
            axis.text.x=element_text(size=20),
            axis.text.y=element_text(size=20),
            axis.title.x=element_text(size=20),
            axis.title.y=element_text(size=20))

    ## Error in ggplot(phe_1sp_2016, aes(date, n.y)): object 'phe_1sp_2016' not found

    tempPlot_dayMax_corr_2 <- ggplot() +
      geom_point(data = temp_day_fit, aes(sDate, dayMax),color="red") +
      scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) +
      xlab("") + ylab("Temp (C)") +
      theme_bw() %+replace% 
      theme(panel.background = element_rect(fill = NA),
            panel.grid.major.x=element_blank(),
            panel.grid.minor.x=element_blank(),
            panel.grid.major.y=element_blank(),
            panel.grid.minor.y=element_blank(),
            axis.text.y=element_text(size=20,color="red"),
            axis.title.y=element_text(size=20))

    ## Error in fortify(data): object 'temp_day_fit' not found

    g1<-ggplot_gtable(ggplot_build(phenoPlot_2))

    ## Error in ggplot_build(phenoPlot_2): object 'phenoPlot_2' not found

    g2<-ggplot_gtable(ggplot_build(tempPlot_dayMax_corr_2))

    ## Error in ggplot_build(tempPlot_dayMax_corr_2): object 'tempPlot_dayMax_corr_2' not found

    pp<-c(subset(g1$layout,name=="panel",se=t:r))

    ## Error in subset(g1$layout, name == "panel", se = t:r): object 'g1' not found

    g<-gtable_add_grob(g1, g2$grobs[[which(g2$layout$name=="panel")]],pp$t,pp$l,pp$b,pp$l)

    ## Error in is.gtable(x): object 'g1' not found

    ia<-which(g2$layout$name=="axis-l")

    ## Error in which(g2$layout$name == "axis-l"): object 'g2' not found

    ga <- g2$grobs[[ia]]

    ## Error in eval(expr, envir, enclos): object 'g2' not found

    ax <- ga$children[[2]]

    ## Error in eval(expr, envir, enclos): object 'ga' not found

    ax$widths <- rev(ax$widths)

    ## Error in rev(ax$widths): object 'ax' not found

    ax$grobs <- rev(ax$grobs)

    ## Error in rev(ax$grobs): object 'ax' not found

    ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(1, "npc") + unit(0.15, "cm")

    ## Error in eval(expr, envir, enclos): object 'ax' not found

    g <- gtable_add_cols(g, g2$widths[g2$layout[ia, ]$l], length(g$widths) - 1)

    ## Error: x must be a gtable

    g <- gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)

    ## Error: x must be a gtable

    grid.draw(g)

    ## Error in UseMethod("grid.draw"): no applicable method for 'grid.draw' applied to an object of class "H5IdComponent"

    #Both pheno data and temp data as line graphs
    grid.newpage()
    phenoPlot_3 <- ggplot(phe_1sp_2016, aes(date, n.y)) +
      geom_line(na.rm = TRUE) +
      scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) +
      ggtitle("Total Individuals in Leaf vs. Temp (C)") +
      xlab("Date") + ylab("Number of Individuals") +
      theme_bw()+
      theme(legend.justification=c(0,1),
            legend.position=c(0,1),
            plot.title=element_text(size=25,vjust=1),
            axis.text.x=element_text(size=20),
            axis.text.y=element_text(size=20),
            axis.title.x=element_text(size=20),
            axis.title.y=element_text(size=20))

    ## Error in ggplot(phe_1sp_2016, aes(date, n.y)): object 'phe_1sp_2016' not found

    tempPlot_dayMax_corr_3 <- ggplot() +
      geom_line(data = temp_day_fit, aes(sDate, dayMax),color="red") +
      scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) +
      xlab("") + ylab("Temp (C)") +
      theme_bw() %+replace% 
      theme(panel.background = element_rect(fill = NA),
            panel.grid.major.x=element_blank(),
            panel.grid.minor.x=element_blank(),
            panel.grid.major.y=element_blank(),
            panel.grid.minor.y=element_blank(),
            axis.text.y=element_text(size=20,color="red"),
            axis.title.y=element_text(size=20))

    ## Error in fortify(data): object 'temp_day_fit' not found

    g1<-ggplot_gtable(ggplot_build(phenoPlot_3))

    ## Error in ggplot_build(phenoPlot_3): object 'phenoPlot_3' not found

    g2<-ggplot_gtable(ggplot_build(tempPlot_dayMax_corr_3))

    ## Error in ggplot_build(tempPlot_dayMax_corr_3): object 'tempPlot_dayMax_corr_3' not found

    pp<-c(subset(g1$layout,name=="panel",se=t:r))

    ## Error in subset(g1$layout, name == "panel", se = t:r): object 'g1' not found

    g<-gtable_add_grob(g1, g2$grobs[[which(g2$layout$name=="panel")]],pp$t,pp$l,pp$b,pp$l)

    ## Error in is.gtable(x): object 'g1' not found

    ia<-which(g2$layout$name=="axis-l")

    ## Error in which(g2$layout$name == "axis-l"): object 'g2' not found

    ga <- g2$grobs[[ia]]

    ## Error in eval(expr, envir, enclos): object 'g2' not found

    ax <- ga$children[[2]]

    ## Error in eval(expr, envir, enclos): object 'ga' not found

    ax$widths <- rev(ax$widths)

    ## Error in rev(ax$widths): object 'ax' not found

    ax$grobs <- rev(ax$grobs)

    ## Error in rev(ax$grobs): object 'ax' not found

    ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(1, "npc") + unit(0.15, "cm")

    ## Error in eval(expr, envir, enclos): object 'ax' not found

    g <- gtable_add_cols(g, g2$widths[g2$layout[ia, ]$l], length(g$widths) - 1)

    ## Error: x must be a gtable

    g <- gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)

    ## Error: x must be a gtable

    grid.draw(g)

    ## Error in UseMethod("grid.draw"): no applicable method for 'grid.draw' applied to an object of class "H5IdComponent"



