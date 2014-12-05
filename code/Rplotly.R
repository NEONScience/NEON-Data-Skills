#install.packages("devtools")

#http://www.r-bloggers.com/plotly-beta-collaborative-plotting-with-r/

#need to install Rtools - http://cran.r-project.org/bin/windows/Rtools/
#downloaded the exe and installed 

#find_rtools()

library("devtools")

#install_github("ropensci/plotly")

#to upgrade tools -- 
#devtools::install_github("ropensci/plotly")

library(plotly)

set_credentials_file("leahawasser", "tpdjz2b8pu")

p <- plotly(username="leahawasser", key="tpdjz2b8pu")


x0 = rnorm(500)
x1 = rnorm(500)+1
data0 = list(x=x0,
             type='histogramx',
             opacity=0.8)
data1 = list(x=x1,
             type='histogramx',
             opacity=0.8)
layout = list(barmode='overlay')  

response = p$plotly(data0, data1, kwargs=list(layout=layout)) 

browseURL(response$url)