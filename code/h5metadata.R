h5metadata <- function(fileN, group, natt){
  out <- H5Fopen(fileN)
  g <- H5Gopen(out,group)
  output <- list()
  for(i in 0:(natt-1)){
    ## Open the attribute
    a <- H5Aopen_by_idx(g,i)
    output[H5Aget_name(a)] <-  H5Aread(a)
    ## Close the attributes
    H5Aclose(a)
  }
  H5Gclose(g)
  H5Fclose(out)
  return(output)
}