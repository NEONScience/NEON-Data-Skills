## ----load-libraries-----------------------------

library(ggplot2)   # create efficient, professional plots
library(plotly)    # create interactive plots



## ----load-libraries-hidden, echo=FALSE, results="hide"----
# this library is only added to get the webpage derived from this code to render
# the plotly graphs.  It is NOT needed for any of the analysis or data 
# visualizations.

# install.packages("webshot")
# webshot::install_phantomjs() 
library(webshot) # embed the plotly plots


## ----import-drought-data------------------------
## Set your working directory to ensure R can find the file we wish to import and where we want to save our files. Be sure to move the downloaded files into your working directory!
wd <- "C:/Users/fsanchez/Documents/data/" # This will depend on your local environment
setwd(wd)

# Import CO state-wide nCLIMDIV data
nCLIMDIV <- read.csv(paste0(wd,"disturb-events-co13/drought/CDODiv8506877122044_CO.txt"), header = TRUE)

# view data structure
str(nCLIMDIV)


## ----convert-year-month, eval= F, comment=NA----
# convert to date, and create a new Date column 
nCLIMDIV$Date <- as.Date(nCLIMDIV$YearMonth, format="%Y%m")



## ----convert-date-------------------------------
#add a day of the month to each year-month combination
nCLIMDIV$Date <- paste0(nCLIMDIV$YearMonth,"01")

#convert to date
nCLIMDIV$Date <- as.Date(nCLIMDIV$Date, format="%Y%m%d")

# check to see it works
str(nCLIMDIV$Date)


## ----create-quick-palmer-plot, fig.cap= "Bar graph of the Palmer Drought Severity Index for Colorado during years 1991 through 2015. X-axis is Date and Y-axis is drought index."----

# plot the Palmer Drought Index (PDSI)
palmer.drought <- ggplot(data=nCLIMDIV,
			 aes(Date,PDSI)) +  # x is Date & y is drought index
	     geom_bar(stat="identity",position = "identity") +   # bar plot 
       xlab("Date") + ylab("Palmer Drought Severity Index") +  # axis labels
       ggtitle("Palmer Drought Severity Index - Colorado \n 1991-2015")   # title on 2 lines (\n)

# view the plot
palmer.drought



## ----summary-stats, fig.cap= "Histogram showing the frequency of Palmer Drought Severity Indices. X-axis is Palmer Drought Severity Indices and Y-axis is frequency."----
#view summary stats of the Palmer Drought Severity Index
summary(nCLIMDIV$PDSI)

#view histogram of the data
hist(nCLIMDIV$PDSI,   # the date we want to use
     main="Histogram of PDSI",  # title
		 xlab="Palmer Drought Severity Index (PDSI)",  # x-axis label
     col="wheat3")  #  the color of the bars



## ----set-plotly-creds, eval=FALSE---------------
## # set plotly user name
## Sys.setenv("plotly_username"="YOUR_plotly_username")
## 
## # set plotly API key
## Sys.setenv("plotly_api_key"="YOUR_api_key")
## 


## ----create-ggplotly-drought--------------------

# Use existing ggplot plot & view as plotly plot in R
palmer.drought_ggplotly <- ggplotly(palmer.drought)  
palmer.drought_ggplotly


## ----create-plotly-drought-plot, fig.cap="Bar graph of the Palmer Drought Severity Index for Colorado during years 1991 through 2015. X-axis is Date and Y-axis is drought index."----
# use plotly function to create plot
palmer.drought_plotly <- plot_ly(nCLIMDIV,    # the R object dataset
	type= "bar", # the type of graph desired
	x=nCLIMDIV$Date,      # our x data 
	y=nCLIMDIV$PDSI,      # our y data
	orientation="v",   # for bars to orient vertically ("h" for horizontal)
	title=("Palmer Drought Severity Index - Colorado 1991-2015"))

palmer.drought_plotly



## ----post-plotly, eval=FALSE--------------------
## # publish plotly plot to your plot.ly online account when you are happy with it
## # skip this step if you haven't connected a Plotly account
## 
## api_create(palmer.drought_plotly)


## ----challenge-Div04, fig.cap= "Bar graph of the Palmer Drought Severity Index for the Platte River Drainage during years 1991 through 2015. X-axis is Date and Y-axis is drought index.", include=FALSE, echo=FALSE, results="hide", eval=FALSE----
## 
## library(ggplot2)
## library(plotly)
## 
## wd <- "C:/Users/fsanchez/Documents/data/" # This will depend on your local environment
## setwd(wd)
## 
## # Import CO state-wide nCLIMDIV data
## nCLIMDIV.co04 <- read.csv(paste0(wd,"disturb-events-co13/drought/CDODiv8868227122048_COdiv04.txt"),
##                           header = TRUE)
## 
## # view data structure
## str(nCLIMDIV.co04)
## 
## #add a day of the month to each year-month combination
## nCLIMDIV.co04$Date <- paste0(nCLIMDIV.co04$YearMonth,"01")
## 
## #convert to date
## nCLIMDIV.co04$Date <- as.Date(nCLIMDIV.co04$Date, format="%Y%m%d")
## 
## # check to see it works
## str(nCLIMDIV.co04$Date)
## 
## # plot the Palmer Drought Index (PDSI) w/ ggplot
## palmer.drought.co04 <- ggplot(data=nCLIMDIV.co04,
## 			 aes(Date,PDSI)) +  # x is Date & y is drought index
## 	     geom_bar(stat="identity",position = "identity") +   # bar plot
##        xlab("Date") + ylab("Palmer Drought Severity Index") +  # axis labels
##        ggtitle("Palmer Drought Severity Index - Platte River Drainage")   # title on 2 lines (\n)
## 
## # view the plot
## palmer.drought.co04
## 
## # --OR-- we could use plotly
## # use plotly function to create plot
## palmer.drought.co04_plotly <- plot_ly(nCLIMDIV.co04,    # the R object dataset
## 				type= "bar", # the type of graph desired
## 				x=nCLIMDIV.co04$Date,      # our x data
## 				y=nCLIMDIV.co04$PDSI,      # our y data
## 				orientation="v",   # for bars to orient vertically ("h" for horizontal)
##         title=("Palmer Drought Severity Index - Platte River Drainage"))
## 
## palmer.drought.co04_plotly
## 


## ----challenge-PHSI, echo=FALSE,fig.cap ="Bar graph of the Palmer Drought Severity Index for Colorado during years 1991 through 2015. X-axis is Date and Y-axis is drought index.",results="hide", include=FALSE----

# our example code uses the Palmer Hydrological Drought Index (PHDI)

# Palmer Hydrological Drought Index (PHDI) -- quoted from the metadata
# "This is the monthly value (index) generated monthly that indicates the
# severity of a wet or dry spell.  This index is based on the principles of a
# balance between moisture supply and demand.  Man-made changes such as
# increased irrigation, new reservoirs, and added industrial water use were not
# included in the computation of this index.  The index generally ranges from -
# 6 to +6, with negative values denoting dry spells, and positive values
# indicating wet spells.  There are a few values in the magnitude of +7 or -7. 
# PHDI values 0 to -0.5 = normal; -0.5 to -1.0 = incipient drought; -1.0 to -
# 2.0 = mild drought; -2.0 to -3.0 = moderate drought; -3.0 to -4.0 = severe
# drought; and greater than -4.0 = extreme drought.  Similar adjectives are
# attached to positive values of wet spells.  This is a hydrological drought
# index used to assess long-term moisture supply.

# check format of PHDI
str(nCLIMDIV)

# plot PHDI using ggplot
palmer.hydro <- ggplot(data=nCLIMDIV,
			 aes(Date,PHDI)) +  # x is Date & y is drought index
	     geom_bar(stat="identity",position = "identity") +   # bar plot 
       xlab("Date") + ylab("Palmer Hydrological Drought Index") +  # axis labels
       ggtitle("Palmer Hydrological Drought Index - Colorado")   # title on 2 lines (\n)

# view the plot
palmer.hydro



## ----palmer-NDV-plot-only, echo=FALSE,fig.cap= "Bar graph of the Palmer Drought Severity Index for Colorado during years 1990 through 2015. X-axis is Date and Y-axis is drought index.",results="hide"----

library(ggplot2)  
library(plotly)

wd <- "C:/Users/fsanchez/Documents/data/" # This will depend on your local environment
setwd(wd)

# NoData Value in the nCLIMDIV data from 1990-2015 US spatial scale 
nCLIMDIV_US <- read.csv(paste0(wd,"disturb-events-co13/drought/CDODiv5138116888828_US.txt"),
                        header = TRUE)


#add a day of the month to each year-month combination
nCLIMDIV_US$Date <- paste0(nCLIMDIV_US$YearMonth,"01")

#convert to date
nCLIMDIV_US$Date <- as.Date(nCLIMDIV_US$Date, format="%Y%m%d")

# check to see it works
str(nCLIMDIV_US$Date)

palmer.droughtUS <- ggplot(data=nCLIMDIV_US,
												 aes(Date,PDSI)) +  # x is Date & y is drought index
	geom_bar(stat="identity",position = "identity") +   # bar plot 
       xlab("Date") + ylab("Palmer Drought Severity Index") +  # axis labels
       ggtitle("Palmer Drought Severity Index - United States")   # title

palmer.droughtUS



## ----palmer-no-data-values, fig.cap=c(" Histogram showing the frequency of Palmer Drought Severity Indices. X-axis is Palmer Drought Severity Indices and Y-axis is frequency. Histogram shows existing -99.99 values.","Histogram showing the frequency of Palmer Drought Severity Indices. X-axis is Palmer Drought Severity Indices and Y-axis is frequency.-99.99 values have been assigned to NA,therefore not included.", "Bar graph of the Palmer Drought Severity Index for Colorado during years 1990 through 2015. X-axis is Date and Y-axis is drought index. No data values have been removed.")----

wd <- "C:/Users/fsanchez/Documents/data/" # This will depend on your local environment
setwd(wd)

# NoData Value in the nCLIMDIV data from 1990-2015 US spatial scale 
nCLIMDIV_US <- read.csv(paste0(wd,"disturb-events-co13/drought/CDODiv5138116888828_US.txt"), header = TRUE)

# add a day of the month to each year-month combination
nCLIMDIV_US$Date <- paste0(nCLIMDIV_US$YearMonth,"01")

# convert to date
nCLIMDIV_US$Date <- as.Date(nCLIMDIV_US$Date, format="%Y%m%d")

# check to see it works
str(nCLIMDIV_US$Date)

# view histogram of data -- great way to check the data range
hist(nCLIMDIV_US$PDSI,
     main="Histogram of PDSI values",
     col="springgreen4")

# easy to see the "wrong" values near 100
# check for these values using min() - what is the minimum value?
min(nCLIMDIV_US$PDSI)

# assign -99.99 to NA in the PDSI column
# Note: you may want to do this across the entire data.frame or with other columns
# but check out the metadata -- there are different NoData Values for each column!
nCLIMDIV_US[nCLIMDIV_US$PDSI==-99.99,] <-  NA  # == is the short hand for "it is"

#view the histogram again - does the range look reasonable?
hist(nCLIMDIV_US$PDSI,
     main="Histogram of PDSI value with NA value assigned",
     col="springgreen4")

# that looks better!  

#plot Palmer Drought Index data
ggplot(data=nCLIMDIV_US,
       aes(Date,PDSI)) +
       geom_bar(stat="identity",position = "identity") +
       xlab("Year") + ylab("Palmer Drought Severity Index") +
       ggtitle("Palmer Drought Severity Index - Colorado\n1991 thru 2015")

# The warning message lets you know that two "entries" will be missing from the
# graph -- these are the ones we assigned NA. 



## ----subset-decade------------------------------

# subset out data between 2005 and 2015 
nCLIMDIV2005.2015 <- subset(nCLIMDIV,    # our R object dataset 
                        Date >= as.Date('2005-01-01') &  # start date
                        Date <= as.Date('2015-12-31'))   # end date

# check to make sure it worked
head(nCLIMDIV2005.2015$Date)  # head() shows first 6 lines
tail(nCLIMDIV2005.2015$Date)  # tail() shows last 6 lines



## ----plotly-decade, fig.cap="Bar graph of the Palmer Drought Severity Index for Colorado during years 2005 through 2015. X-axis is Date and Y-axis is drought index. No data values have been removed."----

# use plotly function to create plot
palmer_plotly0515 <- plot_ly(nCLIMDIV2005.2015,    # the R object dataset
				type= "bar", # the type of graph desired
				x=nCLIMDIV2005.2015$Date,      # our x data 
				y=nCLIMDIV2005.2015$PDSI,      # our y data
				orientation="v",   # for bars to orient vertically ("h" for horizontal)
        title=("Palmer Drought Severity Index - Colorado 2005-2015"))

palmer_plotly0515


## ----plotlyPost, eval=FALSE---------------------
## # publish plotly plot to your plot.ly online account when you are happy with it
## # skip this step if you haven't connected a Plotly account
## 
## api_create(palmer_plotly0515)
## 

