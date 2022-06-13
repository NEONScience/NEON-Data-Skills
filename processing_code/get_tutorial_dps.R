fls <- list.files('/Users/clunch/GitHub/NEON-Data-Skills/tutorials/',
                  pattern='[.]md$', full.names=T, recursive=T)

tutorial.dps <- matrix(data=NA, nrow=0, ncol=2)
for(i in 1:length(fls)) {
  
  tut <- readLines(fls[i])
  tut.title <- grep('title[:]', tut, value=T)
  tut.title <- gsub('title: ', '', tut.title)
  tut.title <- regmatches(tut.title, regexpr('[a-z &]+', tut.title, ignore.case=T))
  
  tut.dps <- grep('dataProduct', tut, value=T)
  if(length(tut.dps)==0) {
    tut.dps <- NA
  } else {
    tut.dps <- gsub('dataProducts', '', tut.dps)
    tut.dps <- gsub('dataProduct', '', tut.dps)
    tut.dps <- regmatches(tut.dps, regexpr('[a-z0-9 .,;&]+', tut.dps, ignore.case=T))
  }
  if(length(tut.dps)==0) {
    tut.dps <- NA
  }
  
  tutorial.dps <- rbind(tutorial.dps, c(tut.title, tut.dps))
}

tutorial.dps <- data.frame(tutorial.dps)
names(tutorial.dps) <- c('Tutorial name','Data products')
write.table(tutorial.dps, '/Users/clunch/Desktop/tutorial_dps.txt', sep='\t', row.names=F)
