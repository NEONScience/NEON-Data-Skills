## load all the functions in memory
invisible(sapply(list.files(path = "R", pattern = "R$", full.names = TRUE), source))
