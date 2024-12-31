## Writing a tutorial with R and Python code tabs

### Overview:

The website displays tutorials based on markdown files. Because pure markdown doesn't allow for code tabs, we've implemented a workaround. The code tabs are created in an Rmarkdown file. That file is knit to an html fragment. The fragment is then embedded in a markdown file for rendering on the website. This means a tabbed tutorial involves four files:

* Rmd file: All content for the tutorial is written here
* html fragment: Knitted version of the Rmd file
* Second Rmd file: Contains only the yaml header for the website and a pointer to the html fragment
* md file: Knitted version of the second Rmd file. This is the file that syncs to the website.

This looks complicated, but only the first file requires real work (since it contains all the content). Detailed instructions below.

### Writing the content file (Rmd)

This file starts with a very simple yaml header:

```
---
title: Content for XXXXX tutorial
output: html_fragment
dateCreated: 'YYYY-MM-DD'
---
```

For all of the non-tabbed content, write in Rmarkdown as usual.

#### Creating tabs

Tabs are created by labeling a header with `{.tabset}`, then nesting the tab labels as headers one level below. Typically the tabset is at header level 2, and the tabs are at header level 3, like this:

```
## Title for this section {.tabset}

This text will appear above both tabs.

### R

This text will appear in the R tab.

### Python

This text will appear in the Python tab.

## {-}
```

The `## {-}` label closes out this set of tabs.

You can also make the tabset a level 3 header, and the tabs level 4. To the user, the tabs appear the same, but you may sometimes want to do this because in the NEON learning hub, level 2 headers appear as the table of contents for the tutorial in the lefthand bar. They define the sections of a tutorial. You can't create tabs without a header, so using level 3 headers lets you include multiple sets of tabs within a section.

```
### Level 3 header within a section {.tabset}

#### R

This text will appear in the R tab.

#### Python

This text will appear in the Python tab.

### {-}
```

Code blocks can be included in tabs just like they can in any other Rmarkdown file.

```
## Title for this section {.tabset}

This text describes the general approach, relevant to both languages.

### R

This text describes any specifics relevant to the R code.

 ```{r chunk-name}
 R code goes here
 \```

 ### Python

 This text describes any specifics relevant to the Python code.

  ```{python p-chunk-name}
  Python code goes here
  \```

 ## {-}
```

You can put multiple code chunks in a tab, but keep in mind this means they will appear and disappear as one large unit when the user toggles the tabs. If there is text between the code blocks, you'll need to repeat it in both tabs. I've mostly used this option when I have multiple code blocks with language-specific instructions between them.

### Knitting the html fragment

Make sure you have the reticulate package installed.

Use the Knit button in RStudio to Knit to html_fragment.

Review the html file. You won't see the tabs, but is all the code there? Did it run correctly? Do the figures appear as they should?

### Creating the file to sync (Rmd)

The Rmd file for the sync to website should contain the usual yaml header, as described in the [Tutorial Instructions](https://github.com/NEONScience/NEON-Data-Skills/blob/main/tutorials-in-development/Tutorial_Instructions.pdf) document. Other than that, it should contain only two code chunks: one to load the `htmltools` package, and one with a pointer to the html fragment. See the Rmd file for the [neonUtilities package](https://github.com/NEONScience/NEON-Data-Skills/blob/main/tutorials/R/NEON-general/neon-code-packages/neonUtilities/neonUtilities-0.Rmd) for an example to copy.

The URL to the html fragment should point to the "raw" version at raw.githubusercontent.com.

File naming: To make sure the website picks up the correct file, name the files so that this file appears before the content files in the folder. I've been ending the file names in `-0` to ensure this, e.g. `api-tokens-content.Rmd` and `api-tokens-0.Rmd`.

### Knitting the file to sync (md)

Knit the Rmd file using the usual R tutorial processing code [here](https://github.com/NEONScience/NEON-Data-Skills/blob/main/processing_code/01knit-RMD-2-MD_NDSRepo.R). Delete the .html and .R outputs.

Review the .md file. In most markdown viewers, you still won't see the tabs, but make sure the code ran correctly and the text and figures are rendering correctly.

### Pushing to GitHub and website

Push your changes to GitHub and follow the usual steps to verify the tutorial or updates appear on the website. Review the tutorial on the website to make sure the tabs appear as expected.
