## ----setup, echo=FALSE-------------------------------------------------------------------------------------------------

library(htmltools)
library(httr)
res <- GET("https://api.github.com/repos/NEONScience/NEON-Data-Skills/contents/tutorials-in-development/Other/test_code_tabs.html")
r2 <- content(res)
download.file(r2$download_url, destfile=paste(getwd(), "/tut_html.html", sep=""), mode="wb", quiet=T)



## ----html, echo=FALSE, warning=FALSE, message=FALSE--------------------------------------------------------------------

htmltools::tags$embed(paste(getwd(), "/tut_html.html", sep=""))



## ----cleanup, echo=FALSE-----------------------------------------------------------------------------------------------

unlink(paste(getwd(), "/tut_html.html", sep=""))


