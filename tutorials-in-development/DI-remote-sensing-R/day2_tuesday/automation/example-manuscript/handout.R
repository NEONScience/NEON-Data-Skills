





## Gathering all the data files
split_gdp_files <- list.files(path = "data-raw", pattern = "gdp-percapita\\.csv$", full.names = TRUE)
split_gdp_list <- lapply(split_gdp_files, read.csv)
gdp <- do.call("rbind", split_gdp_list)
## Turn this into a function called get_mean_lifeExp
mean_lifeExp_by_cont <- gdp %>%
    group_by(continent, year) %>%
    summarize(mean_lifeExp = mean(lifeExp)) %>%
    as.data.frame
## Turn this into a function called get_latest_lifeExp
latest_lifeExp <- gdp %>%
    filter(year == max(gdp$year)) %>%
    group_by(continent) %>%
    summarize(latest_lifeExp = mean(lifeExp)) %>%
    as.data.frame
## If you need to save an R object to avoid the repetition of long computations
make_rds <- function(obj, file, ..., verbose = TRUE) {
    if (verbose) {
        message("Creating rds file: ", file)
    }
    saveRDS(obj, file = file)
    invisible(file.exists(file))
}
## ## An example of the kind of code you could use to work with time-consuming
## ## computations in R.
## if ( !file.exists("data-output/gdp.rds")) {
##     gdp <- gather_gdp_data() ## long computation...
##     make_rds(gdp, file="data-output/gdp.rds")
## }
## gdp <- readRDS(file="data-output/gdp.rds")


gdp <- read.csv(file="data-output/gdp.csv")

gdp %>%
    filter(country %in% c("United States", "France", "Zimbabwe", "South Africa")) %>%
    ggplot(aes(x = year, y = lifeExp, color = country)) +
    geom_point(aes(size = gdpPercap)) + geom_line() +
    geom_vline(xintercept = year_break, color = "red", linetype = 2)

## An example of a function that generates a PDF file from a function
## that creates a plot
## See http://nicercode.github.io/blog/2013-07-09-figure-functions/
make_pdf <- function(expr, filename, ..., verbose = TRUE) {
    if (verbose) {
        message("Creating: ", filename)
    }
    pdf(file = filename, ...)
    on.exit(dev.off())
    eval.parent(substitute(expr))
}
## Create your own function that generates a plot and use it with make_pdf.

## If you are looking for some inspiration (or not too familiar with R
## syntax), the code below compares the relationship between GDP and
## life expectancy for Japan and Finland.

finland <- read.csv(file = "data-raw/Finland-gdp-percapita.csv")
japan <- read.csv(file = "data-raw/Japan-gdp-percapita.csv")
comp_finland_japan <- rbind(finland, japan)

ggplot(comp_finland_japan, aes(x = gdpPercap, y = lifeExp, color = country)) +
   geom_point() +
   stat_smooth(method = "lm", se = FALSE)



## Example of using testthat to check that a function generating a dataset works as expected.
test_that("my first test: correct number of countries",
          expect_equal(length(unique(gather_gdp_data()$country)),
                       length(list.files(path = "data-raw/", pattern="gdp-percapita\\.csv$")))
          )


## add this to make.R
make_tests <- function() {
    test_dir("tests/")
}
## add this to R/figure.R
plot_summary_lifeExp_by_continent <- function(mean_lifeExp) {
    ggplot(mean_lifeExp, aes(x = year, y = mean_lifeExp, colour = continent)) +
      geom_line() + facet_wrap(~ continent) + theme(legend.position = "top")
}

plot_change_trend <- function(mean_lifeExp, year_break) {
    tmp_data <- get_coef_before_after(mean_lifeExp, year_break)
    ggplot(tmp_data, aes(x = period, y = trend, colour = continent, group = continent)) +
      geom_point() + geom_path()
}
## -----
## add this to make.R
make_figures <- function(path = "fig", ...) {
    make_summary_by_continent(path = path, ...)
    make_change_trend(path = path, ...)
}

make_summary_by_continent <- function(path = "fig", ...) {
    mean_lifeExp <- get_mean_lifeExp(gather_gdp_data())
    p <- plot_summary_lifeExp_by_continent(mean_lifeExp)
    make_pdf(print(p), file = file.path(path, "summary_by_continent.pdf"), ...)
}

make_change_trend <- function(path = "fig", year = 1980, ...) {
    mean_lifeExp <- get_mean_lifeExp(gather_gdp_data())
    p <- plot_change_trend(mean_lifeExp, year = year)
    make_pdf(print(p), file = file.path(path, "change_trend.pdf"), ...)
}
## -----
## add this to R/data.R
gather_gdp_data <- function(path = "data-raw") {
    split_gdp_files <- list.files(path = path, pattern = "gdp-percapita\\.csv$", full.names = TRUE)

    split_gdp_list <- lapply(split_gdp_files, read.csv)
    gdp <- do.call("rbind", split_gdp_list)
    gdp
}

get_mean_lifeExp <- function(gdp) {
    mean_lifeExp_by_cont <- gdp %>% group_by(continent, year) %>%
      summarize(mean_lifeExp = mean(lifeExp)) %>% as.data.frame
    mean_lifeExp_by_cont
}

get_latest_lifeExp <- function(gdp) {
    latest_lifeExp <- gdp %>% filter(year == max(gdp$year)) %>%
      group_by(continent) %>%
      summarize(latest_lifeExp = mean(lifeExp)) %>%
      as.data.frame
    latest_lifeExp
}

get_coef_before_after <- function(mean_lifeExp, year_break) {
    coef_before_after <- lapply(unique(mean_lifeExp$continent), function(cont) {
                                    mdl_before <- lm(mean_lifeExp ~ year,
                                                     data = mean_lifeExp,
                                                     subset = (continent == cont & year <= year_break))
                                    mdl_after  <- lm(mean_lifeExp ~ year,
                                                     data = mean_lifeExp,
                                                     subset = (continent == cont & year > year_break))
                                    rbind(c(as.character(cont), "before", coef(mdl_before)[2]),
                                          c(as.character(cont), "after", coef(mdl_after)[2]))
                                }) %>%
      do.call("rbind", .) %>% as.data.frame %>%
      setNames(c("continent", "period", "trend"))
    coef_before_after$trend <- as.numeric(levels(coef_before_after$trend)[coef_before_after$trend])
    coef_before_after$period <- factor(coef_before_after$period, levels = c("before", "after"))
    coef_before_after
}
## -----
## add this to make.R
make_data <- function(path = "data-output", verbose = TRUE) {
    make_gdp_data(path)
    make_mean_lifeExp_data()
}

make_gdp_data <- function(path = "data-output") {
    gdp <- gather_gdp_data()
    make_csv(gdp, file = file.path(path, "gdp.csv"))
}

make_mean_lifeExp_data <- function(path = "data-output") {
    gdp <- gather_gdp_data()
    make_csv(get_mean_lifeExp(gdp), file = file.path(path, "mean_lifeExp.csv"))
}
## -----
## add this to make.R
clean_data <- function(path = "data-output") {
    to_rm <- list.files(path = path, pattern = "csv$", full.names = TRUE)
    res <- file.remove(to_rm)
    invisible(res)
}

clean_figures <- function(path = "fig") {
    to_rm <- list.files(path = path, pattern = "pdf$", full.names = TRUE)
    res <- file.remove(to_rm)
    invisible(res)
}
## -----
## add this to make.R
make_ms <- function() {
    rmarkdown::render("manuscript.Rmd", "html_document")
    invisible(file.exists("manuscript.html"))
}

clean_ms <- function() {
    res <- file.remove("manuscript.html")
    invisible(res)
}

make_all <- function() {
    make_data()
    make_figures()
    make_tests()
    make_ms()
}

clean_all <- function() {
    clean_data()
    clean_figures()
    clean_ms()
}
## -----
## add this to make.R
make_tests <- function() {
    if (require(testthat)) {
        p <- test_dir("tests/")
        if (!interactive() && any(p$failed)) {
            q("no", status = 1, FALSE)
        }
    } else {
        message("skipped the tests, testthat not available.")
        return(NULL)
    }
}
## -----


