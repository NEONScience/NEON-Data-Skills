## ----set-plotly-creds, eval=FALSE---------------------------------------------------------
## # set plotly user name
## Sys.setenv("plotly_username"="YOUR_USERNAME")
## # set plotly API key
## Sys.setenv("plotly_api_key"="YOUR_KEY")
## 


## ----load-libraries-hidden, echo=FALSE, results="hide"------------------------------------
# this package is only added to get the webpage derived from this code to render
# the plotly graphs.  It is NOT needed for any of the analysis or data 
# visualizations.

# install.packages("webshot")
# webshot::install_phantomjs() 
library(webshot) # embed the plotly plots


## ----create-plotly-plot-------------------------------------------------------------------

# load packages
library(ggplot2) # to create plots and feed to ggplotly()
library(plotly)  # to create interactive plots

# view str of example dataset
str(economics)

# plot with the plot_ly function
unempPerCapita <- plot_ly(x =economics$date, y = economics$unemploy/economics$pop)
unempPerCapita 



## ----ggplotly-----------------------------------------------------------------------------
## plot with ggplot, then ggplotly

unemployment <- ggplot(economics, aes(date,unemploy)) + geom_line()
unemployment

ggplotly(unemployment)



## ----pub-plotly, eval=FALSE---------------------------------------------------------------
## 
## # publish plotly plot to your plotly online account
## api_create(unemployment)
## 

