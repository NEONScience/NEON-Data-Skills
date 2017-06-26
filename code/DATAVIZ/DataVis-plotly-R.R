## ----set-plotly-creds, eval=FALSE----------------------------------------
## # set plotly user name
## Sys.setenv("plotly_username"="YOUR_plotly_username")
## # set plotly API key
## Sys.setenv("plotly_api_key"="YOUR_api_key")
## 

## ----create-plotly-plot--------------------------------------------------
# Set working directory to the data directory
# setwd("YourFullPathToDataDirectory")


# load packages
library(plotly)  # to create interactive plots
library(ggplot2) # to create plots and feed to ggplotly()

# view str of example data set
str(economics)

# plot with the plot_ly function
unempPerCapita <- plot_ly(economics, x = date, y = unemploy/pop)
unempPerCapita 


## ----ggplotly------------------------------------------------------------
## plot with ggplot, then ggplotly

unemployment <- ggplot(economics, aes(date,unemploy)) + geom_line()
unemployment

ggplotly(unemployment)


## ----pub-plotly, eval=FALSE----------------------------------------------
## 
## # publish plotly plot to your plotly online account
## plotly_POST(unemployment)
## 

