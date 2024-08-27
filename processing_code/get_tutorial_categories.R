# get superset of DPIDs, programming languages, and topics from tutorial yaml headers

# get list of tutorial files
fls <- list.files('/Users/clunch/GitHub/NEON-Data-Skills/tutorials/',
                  pattern='[.]md$', full.names=T, recursive=T)

dps <- character()
tops <- character()
lang <- character()
for(i in 1:length(fls)) {
  
  # read in tutorial
  tut <- readLines(fls[i])

  # get data products
  tut.dps <- grep('dataProduct', tut, value=T)
  if(length(tut.dps)==0) {
    dps <- dps
  } else {
    tut.dps <- gsub('dataProducts', '', tut.dps)
    tut.dps <- gsub('dataProduct', '', tut.dps)
    tut.dps <- regmatches(tut.dps, regexpr('[a-z0-9 .,;&]+', tut.dps, ignore.case=T))
    tut.dps <- unlist(strsplit(tut.dps, split=',', fixed=T))
    tut.dps <- gsub(' ', '', tut.dps)
  }
  if(length(tut.dps)==0) {
    dps <- dps
  }
  
  dps <- c(dps, tut.dps)
  
  # get topics
  tut.tops <- grep('topics', tut, value=T)
  if(length(tut.tops)==0) {
    tops <- tops
  } else {
    tut.tops <- gsub('topics: ', '', tut.tops)
    tut.tops <- regmatches(tut.tops, regexpr('[a-z0-9 .,;&-]+', tut.tops, ignore.case=T))
    tut.tops <- unlist(strsplit(tut.tops, split=',', fixed=T))
    tut.tops <- gsub(' ', '', tut.tops)
  }
  if(length(tut.tops)==0) {
    tops <- tops
  }
  
  tops <- c(tops, tut.tops)
  
  # get programming languages
  tut.l <- grep('languageTool', tut, value=T)
  tut.l.2 <- grep('languagesTool', tut, value=T)
  tut.l.3 <- grep('languagesTools', tut, value=T)
  tut.l.4 <- grep('languageTools', tut, value=T)
  tut.l <- c(tut.l, tut.l.2, tut.l.3, tut.l.4)
  if(length(tut.l)==0) {
    lang <- lang
  } else {
    tut.l <- unlist(strsplit(tut.l, split=':', fixed=T))
    tut.l <- regmatches(tut.l, regexpr('[a-z0-9 .,;&-]+', tut.l, ignore.case=T))
    tut.l <- unlist(strsplit(tut.l, split=',', fixed=T))
    tut.l <- gsub(' ', '', tut.l)
  }
  if(length(tut.l)==0) {
    lang <- lang
  }
  
  lang <- c(lang, tut.l)
  
}

unique(dps)
unique(tops)
unique(lang)

writeLines(unique(tops), '/Users/clunch/Desktop/tutorial_topics.txt')
writeLines(unique(lang), '/Users/clunch/Desktop/tutorial_langs.txt')
