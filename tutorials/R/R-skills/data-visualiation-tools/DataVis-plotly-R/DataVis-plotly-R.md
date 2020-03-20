---
syncID: b29c2164e6844a93b9d39961faa9861e
title: "Interactive Data Vizualization with R and Plotly"
description: "Learn the basics of how to use the plotly package to create interactive plots and use the Plotly API in R to share these plots."
dateCreated: 2014-12-06
authors: Megan A. Jones, Leah A. Wasser
contributors:
estimatedTime:
packagesLibraries: ggplot, plotly
topics: data-viz
languagesTool: R
dataProduct:
code1: DATAVIZ/DataVis-plotly-R.R
tutorialSeries:
urlTitle: plotly
---


## Plotly - Interactive (and Online) Plots

<a href="https://plot.ly/" target="_blank"> Plotly</a> 
bills itself as "a collaborative platform for modern data science". You can use
it to build  interactive plots that can easily be shared with others (like
the
<a href="https://www.neonscience.org/overview-disturbance-events-co13flood" target="_blank"> *Quantifying The Drivers and Impacts of Natural Disturbance Events – The 2013 Colorado Floods* lessons</a>). 


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
    Sys.setenv("plotly_username"="YOUR_USERNAME")
    # set plotly API key
    Sys.setenv("plotly_api_key"="YOUR_KEY")



### Step 3: Create Plotly plot
There are lots of ways to plot with the plotly package. We briefly describe two 
basic functions `plotly()` and `ggplotly()`. For more information on plotting in
R with Plotly, check out the 
<a href="https://plot.ly/r/" target="_blank"> Plotly R library page</a>. 

Here we use the example dataframe `economics` that comes with the package. 


    # load packages
    library(ggplot2) # to create plots and feed to ggplotly()
    library(plotly)  # to create interactive plots
    
    # view str of example dataset
    str(economics)

    ## Classes 'spec_tbl_df', 'tbl_df', 'tbl' and 'data.frame':	574 obs. of  6 variables:
    ##  $ date    : Date, format: "1967-07-01" "1967-08-01" "1967-09-01" ...
    ##  $ pce     : num  507 510 516 512 517 ...
    ##  $ pop     : num  198712 198911 199113 199311 199498 ...
    ##  $ psavert : num  12.6 12.6 11.9 12.9 12.8 11.8 11.7 12.3 11.7 12.3 ...
    ##  $ uempmed : num  4.5 4.7 4.6 4.9 4.7 4.8 5.1 4.5 4.1 4.6 ...
    ##  $ unemploy: num  2944 2945 2958 3143 3066 ...

    # plot with the plot_ly function
    unempPerCapita <- plot_ly(x =economics$date, y = economics$unemploy/economics$pop)
    unempPerCapita 

    ## No trace type specified:
    ##   Based on info supplied, a 'scatter' trace seems appropriate.
    ##   Read more about this trace type -> https://plot.ly/r/reference/#scatter

    ## No scatter mode specifed:
    ##   Setting the mode to markers
    ##   Read more about this attribute -> https://plot.ly/r/reference/#scatter-mode

    ## PhantomJS not found. You can install it with webshot::install_phantomjs(). If it is installed, please make sure the phantomjs executable can be found via the PATH variable.

    ## Warning in normalizePath(f2): path[1]="webshot1f082b56ce4d.png": No such file or directory

    ## Warning in file(con, "rb"): cannot open file 'webshot1f082b56ce4d.png': No such file or
    ## directory

    ## Error in file(con, "rb"): cannot open the connection

Note: This plot is interactive within the R environment but is not as posted on
this website. 

If you already use ggplot to create your plots, you can directly turn your 
ggplot objects into interactive plots with `ggplotly()`. 


    ## plot with ggplot, then ggplotly
    
    unemployment <- ggplot(economics, aes(date,unemploy)) + geom_line()
    unemployment

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/R-skills/data-visualiation-tools/DataVis-plotly-R/rfigs/ggplotly-1.png)

    ggplotly(unemployment)

    ## PhantomJS not found. You can install it with webshot::install_phantomjs(). If it is installed, please make sure the phantomjs executable can be found via the PATH variable.

    ## Warning in normalizePath(f2): path[1]="webshot1f08f37ba65.png": No such file or directory

    ## Warning in file(con, "rb"): cannot open file 'webshot1f08f37ba65.png': No such file or
    ## directory

    ## Error in file(con, "rb"): cannot open the connection


Note: This plot is interactive within the R environment but is not as posted on
this website. 

### Step 4: Publish to Plotly

The function `plotly_POST()` allows you to post any plotly plot to your account. 


    # publish plotly plot to your plotly online account
    api_create(unemployment)

## Examples

The plots below were generated using R code that harnesses the power of the
`ggplot2` and the `plotly` packages. The plotly code utilizes the 
<a href="http://ropensci.org/packages/" target="_blank">RopenSci `plotly` packages - check them out!</a>

<iframe width="640" height="360" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/24.embed?width=460&height=293"></iframe>

<iframe width="640" height="360" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/6.embed?width=460&height=345"></iframe>

<iframe width="640" height="360" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/16.embed?width=800&height=600"></iframe>

<iframe width="640" height="360" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/19.embed?width=800&height=600"></iframe>


<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip** Are you a Python user? Use `matplotlib` 
to create and publish visualizations.
</div>


