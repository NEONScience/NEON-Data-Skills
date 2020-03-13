# 01-automation Instructor notes

1. Show the starting point (see content of `example-manuscript` folder):
   - one file per country in the `data-raw` folder

1. Explain motivation of the manuscript:
- explore change in life expectancy by continent across two time periods

1. Ask participants to open `manuscript-inline.Rmd` and make sure they can all
compile to HTML from within RStudio

1. Present analysis and results in a little more detail:
  - in the manuscript, we look at minimum and maximum life expectancy summarized
    across continents, draw a plot of the change in life expectancy through time
    for each continent, compare the rate of change in life expectancy (linear
    model) between lowest year and a breaking point (1985 by default, can be
    changed by participants later); and breaking point in latest year. Notice
    that rate of change in life expectancy has been decreasing for all continent
    (particularly noticeable for Africa), except for Oceania where it has
    accelerated.

1. Go through details of the document `manuscript-inline.Rmd` to explain its
   structure and highlight:
   - there is many more lines of code than text and that most of the code is
     actually duplicated
   - show that changing the variable `break_year` changes all the numbers, and
     graphs in the manuscript
   - show that there are chunks that:
     * prepare the data (convert from raw to workable, create the intermediate
     datasets the graphs are based on)
     * make plots
     * fit linear models to the data and extract summary statistics from it

The code is pretty advanced for participants not too familiar with R. It's OK
if they don't understand it all. They should however have a sense for what
each chunk does and they fit together.
