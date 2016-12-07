## Instructor notes for "Functions for data"

Starting with this part of the lesson, the instructor should explain what the
chunks of code do.

We start from a list of files (one file per country). The first step/function
gathers the content of all the files into a single data frame
(`gather_gdp_data()`). We use this function to demonstrate how it can be
generalized to work in other contexts by using `path` and `gdp-percapita-` as
arguments to the function. This can also be used to exemplify how writing
functions can save time in the long term, as functions can be re-used across
projects (but with the warning that it's easy here because all the files have
exactly the same number of columns and are in the same order, which might not be
the case in a real life case).

## `make_csv()`

Demonstrate how to write this function. Start by just typing the write.csv line
and expends from there. We use `row.names=FALSE` because we don't want them in
the output, `verbose` just write something at the terminal which will be useful
when we are building the full manuscript to keep track of progress. You may want
to leave out the `...` depending on the participants' level of comfort with R
code.

## Before the challenge of converting into functions

Demonstrate what the 2 chunks of code do before asking participants to convert
them into functions.
