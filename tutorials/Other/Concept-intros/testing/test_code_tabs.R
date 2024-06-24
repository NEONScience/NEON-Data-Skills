## ----setup, echo=FALSE-------------------------------------------------------------------------------------------------

library(htmltools)
library(httr)
res <- GET("https://api.github.com/repos/cklunch/NEON-Data-Skills/contents/tutorials-in-development/Other/test_code_tabs.html")
r2 <- content(res)
download.file(r2$download_url, destfile=paste(getwd(), "/tut_html.html", sep=""), mode="wb", quiet=T)



## ----html, echo=FALSE, warning=FALSE, message=FALSE--------------------------------------------------------------------

htmltools::tags$iframe(src = base64enc::dataURI(file=paste(getwd(), "/tut_html.html", sep=""), 
                                                mime="text/html; charset=UTF-8"), width="100%", height=1600)



## ----cleanup, echo=FALSE-----------------------------------------------------------------------------------------------

unlink(paste(getwd(), "/tut_html.html", sep=""))


