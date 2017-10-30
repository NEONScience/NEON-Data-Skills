## Files for an exercise on file, data, and code documentation and organization

Files in the subdirectory `messy-dir-example` can be used to help
students identify problems that make it difficult to share or reuse
analyses. There are many problems with the folder structure, file
nameing, data organization, and code organization in this example
directory. This was taught as part of the [NEON Data Science Institute
2016](http://neon-workwithdata.github.io/neon-data-institute-2016/) by
[Naupaka Zimmerman](https://github.com/naupaka). The data and files are
for the most part derived from various NEON remote sensing (AOP)
    products from the D17 California sites.

Students are shown the introductory slides ([available
        here](https://github.com/NEON-WorkWithData/slide-shows/blob/gh-pages/intro-reprod-science.md)) and then asked to identify problems in the directory.

Some of the problems are:

1. No metadata or readme
1. No directory structure
1. Background info is a picture of text instead of searchable text
1. Multiple files with similar content and different names; ambiguous naming
1. Some vector GIS files are missing and it’s unclear why
1. Tabular data is in proprietary format
1. Not clear which sites different files are from
1. Not clear the order in which the script were run or should be run
1. In the code:
    * Multiple copies of similar code pasted near each other but with slight changes
    * Very few comments
    * Unclear about the order in which lines should be run
1. In the tabular file foliar chem:
    * Notes at bottom of files
    * Notes off to the right in unlabeled column
    * Gap between columns
    * Column name starting with a number
    * Duplicate column names
    * Spaces in column names
    * Misspellings in columns that might be used as categorical variables
    * Different values for missing data
    * Dealing with dates in Excel (DANGER)
    * Units for values?
    * Where is metadata?


