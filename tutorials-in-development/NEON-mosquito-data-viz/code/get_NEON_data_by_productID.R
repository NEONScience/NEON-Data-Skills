options(stringsAsFactors = F)
library(httr)

get_availability <- function(query, as = "parsed"){
  require(httr)
  url = paste("http://data.neonscience.org/api/v0", "products", query, sep = "/")
  req = GET(url = url) #, add_headers(Accept = "application/json"))
  con = content(req, as = as)
  site = lapply(con$data$siteCodes, as.data.frame)
  dat = data.frame()
  for (i in 1:length(site)){
    len = length(unlist(site[[i]]))
    int = data.frame(unlist(site[[i]])[1:len - 1])
    colnames(int) = "date"
    int$siteID = site[[i]]$siteCode
    
    dat <- rbind(dat, int)
  }
  row.names(dat) = 1:nrow(dat)
  dat$product <- query
  
  return(dat)
}
get_records <- function(product, site, date, as = "text"){
  require(httr)
  url = paste("http://data.neonscience.org/api/v0/data", product, site, date, sep = "/")
  req = GET(url = url) #, add_headers(Accept = "application/json"))
  con = content(req, as = as)
  return(con)
}
get_data_product <- function(productID, df = NULL, repo_dir = repo_location){
  # Use DP list if function directory path is provided
  if(is.null(df)&!is.null(repo_dir)){
    df = read.csv(paste0(repo_dir, "/all_pubs.csv"))
    df = df$table[grepl(productID, df$dpID)]
  }

  # Step 1: What dates and sites are available?
  dat = get_availability(query = productID)
  dat = unique.data.frame(dat[!grepl('http', dat$date), ])
  print(paste(length(unique(dat$siteID)),'site(s) are available for this data product.',
              paste0(unique(dat$siteID), collapse = ', ')))
  print(paste('Total of', nrow(dat), 'months of data to be read in.'))
  
  # Step 2: Knowing what is available, get all the data
  for (l in 1:length(df)){
    assign(df[l], data.frame()) # Create placeholders
  }
  
  # Collate records
  for (i in 1:nrow(dat)){
    print(dat[i, ])
    # Get the data links
    err <- try(result <- get_records(product = dat$product[i], site = dat$siteID[i],
                                     date = dat$date[i], as = "parsed")  
    )
    # If successful grab data via url download
    if (class(err)!="try-error"){
      
      # Get the urls for download
      urls = as.character(unlist(result$data$files))
      urls = urls[grepl('\\.csv', urls) & grepl('http', urls)]
      
      for (k in urls){
        # For each url that exists, rbind to the correct table
        for (j in df){
          if(grepl(j, k)){
            # Apparent issues with headers; Generalized resolution:
            # Treat headers as false, append colnames from a row
            # that contains uid, discard unknown columns
            a = read.csv(k, encoding = 'UTF-8', row.names = NULL, header = F) 
            if(c(a$V1, a$V2)%in%'uid'){
              cols = a[c(a$V1, a$V2)%in%'uid', ]; cols = unlist(cols[!is.na(cols)&cols!='row.names'])
              # Discard unknown columns
              a = a[-which(c(a$V1, a$V2)%in%'uid'), 1:length(cols)]
              colnames(a) = cols # Name columns
              
              # Dataframe a now contains part of the mammal download
              # If this is the first instance, rename dataframe 'a' 
              # To the appropriate dataset; if not the first instance -
              # Attempt to merge tables
              if(nrow(get(j))>0){
                if(all(colnames(get(j))==colnames(a))){
                  assign(j, rbind(a, get(j)))  
                } else {
                  cols_j = colnames(get(j))
                  a[, cols_j[!cols_j%in%colnames(a)]] = NA
                  assign(j, rbind(get(j), a))
                }
              } else {
                assign(j,get('a'))  
              }
              rm(a, cols)
            }

          }
        }
      }
      rm(urls)
    }
    rm(err, result)
  }
  
  a = list(sapply(df, get, envir = sys.parent(0)))
  return(a[[1]])
}
