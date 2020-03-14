create_dir <- function(file, verbose) {
    if (!file.exists(dirname(file))) {
        if (verbose) {
            message("Create: ", dirname(file))
        }
        dir.create(dirname(file), recursive = TRUE)
    }
}

make_pdf <- function(expr, file, ..., verbose = TRUE) {
    create_dir(file = file, verbose = verbose)
    if (verbose) {
        message("Creating figure: ", file)
    }
    pdf(file = file, ...)
    on.exit(dev.off())
    eval.parent(substitute(expr))
}

make_csv <- function(obj, file, ...,  verbose = TRUE) {
    create_dir(file = file, verbose = verbose)
    if (verbose) {
        message("Creating csv file: ", file)
    }
    write.csv(obj, file = file, row.names = FALSE, ...)
}
