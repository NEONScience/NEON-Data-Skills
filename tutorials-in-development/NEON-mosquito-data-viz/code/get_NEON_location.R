###############################################################################
#' @title NEON location metadata
#'
#' @author Katherine LeVan \email{katherine.levan@gmail.com} 
#'
#' @description A curl wrapper that pull in location metadata from the NEON 
#' location REST API
#'
#' @param \code{namedLocation} A valid named location within the NEON 
#' Observatory, could be a domain, site, plot, or point.
#' @param \code{output} The desired spatial data to output. Options are 'latlon',
#' 'parent', 'child', or 'metadata'. 'latlon' gives only latitude/longitude, 
#' 'parent' and 'child' give all the parent and child location information. 
#' 'metadata' gives back everything.
#' 
#' @references data.neonscience.org/home
#'
#' @keywords NEON, location
#' @examples
#' @seealso None
#' @export
###############################################################################
get_NEON_location <- function(namedLocation = NULL, output = NULL){
  require(httr)
  require(jsonlite)
  url = paste0('data.neonscience.org/api/v0/locations/', namedLocation)
  request <- httr::GET(url)
  content <- jsonlite::fromJSON(httr::content(request, as = "text"))
  con = data.frame('namedLocation' = namedLocation,
                   'decimalLatitude' = NA,
                   'decimalLongitude' = NA,
                   'elevation' = NA,
                   'ncldClass' = NA
                   )
  if(output == 'latlon'){
    if(request$status_code==200){
    con = data.frame('namedLocation' = ifelse(is.null(content$data$locationName),
                                              '',content$data$locationName),
                     'decimalLatitude' = ifelse(is.null(content$data$locationDecimalLatitude),
                                                '',content$data$locationDecimalLatitude),
                     'decimalLongitude' = ifelse(is.null(content$data$locationDecimalLongitude),
                                                 '',content$data$locationDecimalLongitude),
                     'elevation' = ifelse(is.null(content$data$locationElevation),
                                          '',content$data$locationElevation),
                     'ncldClass' = ifelse(!"Value for National Land Cover Database (2001)"%in%
                                            content$data$locationProperties$locationPropertyName,
                                          '',content$data$locationProperties$locationPropertyValue[
                                            grepl('National Land Cover Database',
                                                  content$data$locationProperties$locationPropertyName)
                                          ])
                     )
      #print(namedLocation)
      return(con)    
    } else {
      return(con) 
      cat('Does not appear to be a valid named location.')
    }
  }
  if(output == 'metadata'&request$status_code==200){
    return(content$rows)  
  }
  if(output == 'parent'){
    if(request$status_code==200){
      con = gsub('http://data.neonscience.org:80/api/v0/locations/', 
                 '', content$data$locationParentUrl)
      return(con)  
    } else {
      cat('Given location is not nested within a parent location.')
    }
  }
  if(output == 'child'){
    if(request$status_code==200){
      con = gsub('http://data.neonscience.org:80/api/v0/locations/', 
                 '', content$data$locationChildrenUrls)
      return(con)  
    } else {
      cat('No child locations nested within given location.')
    }
  }
}