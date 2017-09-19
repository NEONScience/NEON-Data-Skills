---
syncID: 8346bef7292b46a09a76a0171b05662c
title: "Getting Started with the R Programming Language"
description: "This tutorial presents the basics of using R."
dateCreated: 2014-11-04
authors: Leah A. Wasser - Adapted from Software Carpentry
contributors: 
estimatedTime:
packagesLibaries:
topics: data-analysis
languagesTool: R
dataProduct:
code1: /R/R-basics/R-Basics-Getting-Started.R
tutorialSeries: R-basics
---


R is a versatile, open source programming language that was specifically 
designed for data analysis. R is extremely useful for data management, 
statistics and analyzing data. 

This tutorial should be seem more as a reference on the basics of R and not a 
tutorial for learning to use R. Here we define many of the basics, however, this 
can get overwhelming if you are brand new to R. 

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to: 

* Use basic R syntax
* Explain the concepts of objects and assignment
* Explain the concepts of vector and data types
* Describe why you would or would not use *factors*
* Use basic few functions

## Things You’ll Need To Complete This Tutorial
You will need the most current version of `R` and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

****

{% include/_greyBox-wd-rscript.html %}

</div>

## The Very Basics of R

R is a versatile, open source programming language that was specifically 
designed for data analysis. R is extremely useful for data management, statistics and 
analyzing data. 

<div id="ds-dataTip">
<i class="fa fa-star"></i>**Cool Fact:** R was inspired by the programming language <a href="http://en.wikipedia.org/wiki/S_(programming_language)" target="_blank">S</a>.  
</div>

R is:

* Open source software under a 
<a href="http://en.wikipedia.org/wiki/GNU_General_Public_License" target="_blank">GNU General Public License (GPL)</a>.  
* A good alternative to commercial analysis tools. R has over 5,000 user 
contributed packages (as of 2014) and is widely used both in academia and industry.  
* Available on all platforms.  
* Not just for statistics, but also general purpose programming.   
* Supported by a large and growing community of peers.  

## Introduction to R

You can use R alone or with a user interace like RStudio to write your code. 
Some people prefer RStudio as it provides a graphic interface where you can see 
what objects have been created and you can also set variables like your working
directory, using menu options.

Learn more about <a href="https://www.rstudio.com/online-learning/" target="_blank"> RStudio with thier online learning materials</a>.

We want to use R to create code and a workflow is more reproducible.  We can 
document everything that we do.  Our end goal is not just to "do stuff" but to 
do it in a way that anyone can easily and exactly replicate our workflow and 
results -- this includes ourselves in 3 months when the paper reviews come back!

## Code & Comments in R

Everything you type into an R script is code, unless you demark it otherwise. 

Anything to the right of a `#` is ignored by R. Use these comments within the 
code to describe what it is that you code is doing. Comment liberally in your R 
scripts. This will help you when you return to it and will also help others 
understand your scripts and analyses. 


    # this is a comment. It allows text that is ignored by the program.
    # for clean, easy to read comments, use a space between the # and text. 
    
    # there is a line of code below this comment
     a <- 1+2

## Basic Operations in R
Let's take a few moments to play with R. You can get output from R simply by 
typing in math


    # basic math
    3 + 5

    ## [1] 8

    12/7

    ## [1] 1.714286

or by typing words, with the command `writeLines()`. Words that you want to be
recognized as text (as opposed to a field name or other text that signifies an 
object) must be enclosed within quotes. 


    # have R write words
    
    writeLines("hello world")

    ## hello world

We can assign our results to an `object` and name the object. Objects names cannot
contain spaces. 


    # assigning values to objects 
    b <- 60 * 60
    
    hours <- 365 * 24
    
    # object names can't contain spaces.  Use a period, underscore, or camelCase to 
    # create longer names
    temp_HARV <- 90

The *result* of the operation on the right hand side of `<-` is *assigned* to 
an object with the name specified on the left hand side of `<-`. The *result* 
could be any type of R object, including your own functions (see the 
<a href="{{ site.baseurl}}/Using-R/Working-With-Functions" target="_blank"> *Build & Work With Functions in R* tutorial</a>.

### Assignment Operator: Drop the Equals Sign

The assignment operator is `<-`. It assigns values on the right to `objects` on 
the left. It is similar to `=` but there are some subtle differences. Learn to 
use `<-` as it is good programming practice. Using `=` in place of `<-` can lead
to issues down the line.


    # this is preferred syntax
    a <- 1+2 
    
    # this is NOT preferred syntax
    a = 1+2 

<div id="ds-dataTip">
<i class="fa fa-star"></i>**Typing Tip:** If you are using RStudio, you can use
a keyboard shortcut for the assignment operator: **Windows/Linux: "Alt" + "-"** 
or **Mac: "Option" + "-"**. 
</div>

### List All Objects in the Environment

Some functions are the same as in other languages. These might be familiar from 
command line. 

* `ls()`: to list objects in your current environment. 
* `rm()`: remove objects from your current environment.  

Now try them in the console.  


    # assign value "5" to object "x"
    x <- 5
    ls()

    ##  [1] "a"           "b"           "base.url"    "codeDir"     "dat"        
    ##  [6] "dir"         "dirs"        "f"           "fig.path"    "files"      
    ## [11] "gitRepoPath" "hours"       "imagePath"   "input"       "m"          
    ## [16] "m2"          "m2_row"      "m3"          "mdFile"      "n"          
    ## [21] "o"           "p"           "postsDir"    "rmd.files"   "subDir"     
    ## [26] "temp_HARV"   "wd"          "x"           "x1"          "x2"         
    ## [31] "y"           "z"

    # remove x
    rm(x)
    
    # what is left?
    ls()

    ##  [1] "a"           "b"           "base.url"    "codeDir"     "dat"        
    ##  [6] "dir"         "dirs"        "f"           "fig.path"    "files"      
    ## [11] "gitRepoPath" "hours"       "imagePath"   "input"       "m"          
    ## [16] "m2"          "m2_row"      "m3"          "mdFile"      "n"          
    ## [21] "o"           "p"           "postsDir"    "rmd.files"   "subDir"     
    ## [26] "temp_HARV"   "wd"          "x1"          "x2"          "y"          
    ## [31] "z"

    # remove all objects
    rm(list = ls())
    
    ls()

    ## character(0)

Using `rm(list=ls())`, you combine several functions to remove all objects. 
If you typed `x` on the console now you will get `Error: object 'x' not found'`.

## Data Types and Structures

To make the best of the R language, you'll need a strong understanding of the 
basic data types and data structures and how to operate on those. These are the 
objects you will manipulate on a day-to-day basis in R. Dealing with object 
conversions is one of the most common sources of frustration for beginners.

First, **everything** in R is an object.  But there are different types of 
objects.  One of the basic differences in in the *data structures* which are
different ways data are stored. 

R has many different **data structures**. These include

* atomic vector
* list
* matrix
* data frame
* array

These data structures vary by the dimensionality of the data and if they can 
handle data of differnt types (homogenous vs heterogeneous).

| Dimensions | Homogenous | Heterogeneous |
| :-----: | :--: | :--: |
| 1-D | atomic vector | list |
| 2-D | matrix | data frame |
| none| array| |

### Vectors

A vector is the most common and basic data structure in R and is the workhorse 
of R. Technically, vectors can be one of two types:

* atomic vectors
* lists

although the term "vector" most commonly refers to the atomic types not to lists.


#### Atomic Vectors

R has 6 atomic vector types.

* character
* numeric (real or decimal)
* integer
* logical
* complex
* raw (not discussed in this tutorial)

By *atomic*, we mean the vector only holds data of a single type.

- **character**: `"a"`, `"swc"`
- **numeric**: `2`, `15.5`
- **integer**: `2L` (the `L` tells R to store this as an integer)
- **logical**: `TRUE`, `FALSE`
- **complex**: `1+4i` (complex numbers with real and imaginary parts)

R provides many functions to examine features of vectors and other objects, for example

1. `typeof()` - what is it?  
2. `length()` - how long is it? What about two dimensional objects?  
3. `attributes()` - does it have any metadata?
 

Let's look at some examples:


    # assign word "april" to x"
    x <- "april"
    
    # return the type of the object
    typeof(x)

    ## [1] "character"

    # 
    attributes(x)

    ## NULL

    # assign all values 1 to 10 to the object y
    y <- 1:10
    y

    ##  [1]  1  2  3  4  5  6  7  8  9 10

    typeof(y)

    ## [1] "integer"

    # how many 
    length(y)

    ## [1] 10

    # 
    z <- as.numeric(y)
    z

    ##  [1]  1  2  3  4  5  6  7  8  9 10

    typeof(z)

    ## [1] "double"

A vector is a collection of elements that are most commonly `character`, 
`logical`, `integer` or `numeric`.

You can create an empty vector with `vector()`. (By default the mode is 
`logical`. You can be more explicit as shown in the examples below.) It is more 
common to use direct constructors such as `character()`, `numeric()`, etc.


    x <- vector()
        
    # Create vector with a length and type
    vector("character", length = 10)

    ##  [1] "" "" "" "" "" "" "" "" "" ""

    # create character vector with length of 5
    character(5)  

    ## [1] "" "" "" "" ""

    # numeric vector length=5
    numeric(5)

    ## [1] 0 0 0 0 0

    # logical vector length=5
    logical(5)

    ## [1] FALSE FALSE FALSE FALSE FALSE

    # create a list with combine `c()`
    x <- c(1, 2, 3)
    x

    ## [1] 1 2 3

    length(x)

    ## [1] 3

    typeof(x)

    ## [1] "double"

`x` is a numeric vector. These are the most common kind. They are numeric 
objects and are treated as double precision real numbers (they can store 
decimal points). To explicitly create integers (no decimal points), add an 
`L` to each (or *coerce* to the integer type using `as.integer()`.


    # a numeric vector with integers (L)
    x1 <- c(1L, 2L, 3L)
    x1

    ## [1] 1 2 3

    typeof(x1)

    ## [1] "integer"

    # or using as.integer()
    x2 <- as.integer(x)
    typeof(x2)

    ## [1] "integer"

You can also have logical vectors. 


    # logical vector 
    y <- c(TRUE, TRUE, FALSE, FALSE)
    y

    ## [1]  TRUE  TRUE FALSE FALSE

    typeof(y)

    ## [1] "logical"

Finally, you can have character vectors.


    # character vector
    z <- c("Sarah", "Tracy", "Jon")
    z

    ## [1] "Sarah" "Tracy" "Jon"

    typeof(z)

    ## [1] "character"

    length(z)

    ## [1] 3

    # what class is it
    class(z)

    ## [1] "character"

    # what is the structure
    str(z)

    ##  chr [1:3] "Sarah" "Tracy" "Jon"

You can also add to a list


    	z <- c(z, "Annette")
    	z

    ## [1] "Sarah"   "Tracy"   "Jon"     "Annette"

More examples of how to create vectors

* x <- c(0.5, 0.7)
* x <- c(TRUE, FALSE)
* x <- c("a", "b", "c", "d", "e")
* x <- 9:100
* x <- c(1 + (0+0i), 2 + (0+4i))


You can also create vectors as a sequence of numbers.


    # simple series 
    1:10

    ##  [1]  1  2  3  4  5  6  7  8  9 10

    # use seq() 'sequence'
    seq(10)

    ##  [1]  1  2  3  4  5  6  7  8  9 10

    # specify values for seq()
    seq(from = 1, to = 10, by = 0.1)

    ##  [1]  1.0  1.1  1.2  1.3  1.4  1.5  1.6  1.7  1.8  1.9  2.0  2.1  2.2  2.3
    ## [15]  2.4  2.5  2.6  2.7  2.8  2.9  3.0  3.1  3.2  3.3  3.4  3.5  3.6  3.7
    ## [29]  3.8  3.9  4.0  4.1  4.2  4.3  4.4  4.5  4.6  4.7  4.8  4.9  5.0  5.1
    ## [43]  5.2  5.3  5.4  5.5  5.6  5.7  5.8  5.9  6.0  6.1  6.2  6.3  6.4  6.5
    ## [57]  6.6  6.7  6.8  6.9  7.0  7.1  7.2  7.3  7.4  7.5  7.6  7.7  7.8  7.9
    ## [71]  8.0  8.1  8.2  8.3  8.4  8.5  8.6  8.7  8.8  8.9  9.0  9.1  9.2  9.3
    ## [85]  9.4  9.5  9.6  9.7  9.8  9.9 10.0

You can also get non-numeric outputs. 

* `Inf` is infinity. You can have either positive or negative infinity.
* `NaN` means Not a Number. It's an undefined value.

Try it out in the console. 


    # infinity return
    1/0

    ## [1] Inf

    # non numeric return
    0/0

    ## [1] NaN

Objects can have **attributes**. Attribues are part of the object. These include:

* **names**: the field or variable name within the object 
* **dimnames**:
* **dim**:
* **class**:
* **attributes**: this contain metadata

You can also glean other attribute-like information such as `length()` 
(works on vectors and lists) or number of characters `nchar()` (for 
character strings).


    # length of an object
    length(1:10)

    ## [1] 10

    length(x)

    ## [1] 3

    # number of characters in a text string
    nchar("NEON Data Skills")

    ## [1] 16


#### Heterogeneous Data - Mixing Types?

When you mix types, R will create a resulting vector that is the least common 
denominator. The coercion will move towards the one that's easiest to **coerce** 
to.

Guess what the following do:

* m <- c(1.7, "a")
* n <- c(TRUE, 2)
* o <- c("a", TRUE)

Were you correct? 


    n <- c(1.7, "a")
    n

    ## [1] "1.7" "a"

    o <- c(TRUE, 2)
    o

    ## [1] 1 2

    p <- c("a", TRUE)
    p

    ## [1] "a"    "TRUE"

This is called implicit coercion. You can also coerce vectors explicitly using 
the `as.<class_name>`.


    # making values numeric
    as.numeric(c("1")
    
    # make values charactor
    as.character(1:2)
    
    # make values 
    as.factor("male","female")

    ## Error: <text>:5:1: unexpected symbol
    ## 4: # make values charactor
    ## 5: as.character
    ##    ^

### Matrix

In R, matrices are an extension of the numeric or character vectors. They are 
not a separate type of object but simply an atomic vector with dimensions; the 
number of rows and columns.


    # create an empty matrix that is 2x2
    m <- matrix(nrow = 2, ncol = 2)
    m

    ##      [,1] [,2]
    ## [1,]   NA   NA
    ## [2,]   NA   NA

    # what are the dimensions of m
    dim(m)

    ## [1] 2 2

Matrices in R are by default filled column-wise. You can also use the `byrow` 
argument to specify how the matrix is filled. 


    # create a matrix. Notice R fills them by columns
    m2 <- matrix(1:6, nrow = 2, ncol = 3)
    m2

    ##      [,1] [,2] [,3]
    ## [1,]    1    3    5
    ## [2,]    2    4    6

    m2_row <- matrix(c(1:6), nrow = 2, ncol = 3, byrow = TRUE)
    m2_row

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6

`dim()` takes a vector and transform into a matrix with 2 rows and 5 columns. 
Another way to shape your matrix is to bind columns `cbind()` or rows `rbind()`.


    # create vector with 1:10
    m3 <- 1:10
    m3

    ##  [1]  1  2  3  4  5  6  7  8  9 10

    class(m3)

    ## [1] "integer"

    # set the dimensions so it becomes a matrix
    dim(m3) <- c(2, 5)
    m3

    ##      [,1] [,2] [,3] [,4] [,5]
    ## [1,]    1    3    5    7    9
    ## [2,]    2    4    6    8   10

    class(m3)

    ## [1] "matrix"

    # create matrix from two vectors
    x <- 1:3
    y <- 10:12
    
    # cbind will bind the two by column
    cbind(x, y)

    ##      x  y
    ## [1,] 1 10
    ## [2,] 2 11
    ## [3,] 3 12

    # rbind will bind the two by row
    rbind(x, y)

    ##   [,1] [,2] [,3]
    ## x    1    2    3
    ## y   10   11   12

### List

In R, lists act as containers. Unlike atomic vectors, the contents of a list are 
not restricted to a single mode and can encompass any mixture of data types. 
Lists are sometimes called generic vectors, because the elements of a list can 
by of any type of R object, even lists containing further lists. This property 
makes them fundamentally different from atomic vectors.

A list is different from an atomic vector because each element can be a 
different type -- it can contain heterogeneous data types.

Create lists using `list()` or coerce other objects using `as.list()`. An empty 
list of the required length can be created using `vector()`


    x <- list(1, "a", TRUE, 1 + (0+4i))
    x

    ## [[1]]
    ## [1] 1
    ## 
    ## [[2]]
    ## [1] "a"
    ## 
    ## [[3]]
    ## [1] TRUE
    ## 
    ## [[4]]
    ## [1] 1+4i

    class(x)

    ## [1] "list"

    x <- vector("list", length = 5)  ## empty list
    length(x)

    ## [1] 5

    x[[1]]

    ## NULL

    x <- 1:10
    x <- as.list(x)


Questions: 

1. What is the class of `x[1]`?
1. What about `x[[1]]`?

Try it out.


    
    xlist <- list(a = "Karthik Ram", b = 1:10, data = head(iris))
    xlist
    
    $a
     
    $b
    
    $data

    ## Error: <text>:5:1: unexpected '$'
    ## 4: 
    ## 5: $
    ##    ^


1. What is the length of this object? What about its structure?

* Lists can be extremely useful inside functions. You can “staple” together 
lots of different kinds of results into a single object that a function can 
return.
* A list does not print to the console like a vector. Instead, each element 
of the list starts on a new line.
* Elements are indexed by double brackets. Single brackets will still return 
a(nother) list.


### Factors

Factors are special vectors that represent categorical data. Factors can be 
ordered or unordered and are important for modelling functions such as `lm()` 
and `glm()` and also in `plot()` methods. Once created, factors can only contain 
a pre-defined set values, known as *levels*.

Factors are stored as integers that have labels associated the unique integers. 
While factors look (and often behave) like character vectors, they are actually 
integers under the hood. You need to be careful when treating them like strings. 
Some string methods will coerce factors to strings, while others will throw an 
error.

* Sometimes factors can be left unordered. Example: male, female.
* Other times you might want factors to be ordered (or ranked). Example: low, medium, high.
* Underlying it's represented by numbers 1, 2, 3.
* They are better than using simple integer labels because factors are what are 
called self describing. male and female is more descriptive than 1s and 2s. 
Helpful when there is no additional metadata.

Which is male? 1 or 2? You wouldn't be able to tell with just integer data. 
Factors have this information built in.

Factors can be created with `factor()`. Input is often a character vector.


    x <- factor(c("yes", "no", "no", "yes", "yes"))
    x

    ## [1] yes no  no  yes yes
    ## Levels: no yes

`table(x)` will return a frequency table counting the number of elements in 
each level.

If you need to convert a factor to a character vector, simply use


    as.character(x)

    ## [1] "yes" "no"  "no"  "yes" "yes"

To convert a factor to a numeric vector, go via a character. Compare


    f <- factor(c(1, 5, 10, 2))
    
    as.numeric(f)  ## wrong!

    ## [1] 1 3 4 2

    as.numeric(as.character(f))

    ## [1]  1  5 10  2


In modeling functions, it is important to know what the baseline level is. This 
is the first factor but by default the ordering is determined by alphanumerical 
order of elements. You can change this by speciying the `levels` (another option 
is to use the function `relevel()`).


    x <- factor(c("yes", "no", "yes"), levels = c("yes", "no"))
    x

    ## [1] yes no  yes
    ## Levels: yes no

### Data Frame

A data frame is a very important data type in R. It's pretty much the *de facto*
data structure for most tabular data and what we use for statistics.  


* A data frame is a special type of list where every element of the list has 
same length.  
* Data frames can have additional attributes such as `rownames()`, which can 
be useful for annotating data, like `subject_id` or `sample_id`. But most of 
the time they are not used.  

Some additional information on data frames:

* Usually created by `read.csv()` and `read.table()`.
* Can convert to matrix with `data.matrix()` (preferred) or `as.matrix()`
* Coercion will be forced and not always what you expect.
* Can also create with `data.frame()` function.
* Find the number of rows and columns with `nrow(dat)` and `ncol(dat)`, 
respectively.
* Rownames are usually 1, 2, ..., n.

#### Manually Create Data Frames

You can manually create a data frame using `data.frame`. 


    # create a dataframe
    dat <- data.frame(id = letters[1:10], x = 1:10, y = 11:20)
    dat

    ##    id  x  y
    ## 1   a  1 11
    ## 2   b  2 12
    ## 3   c  3 13
    ## 4   d  4 14
    ## 5   e  5 15
    ## 6   f  6 16
    ## 7   g  7 17
    ## 8   h  8 18
    ## 9   i  9 19
    ## 10  j 10 20

#### Useful Data Frame Functions

* `head()` - shown first 6 rows
* `tail()` - show last 6 rows
* `dim()` - returns the dimensions
* `nrow()` - number of rows
* `ncol()` - number of columns
* `str()` - structure of each column
* `names()` - shows the `names` attribute for a data frame, which gives the 
column names.

See that it is actually a special list:


    list()

    ## list()

    is.list(iris)

    ## [1] TRUE

    class(iris)

    ## [1] "data.frame"

A recap of the different data types

| Dimensions | Homogenous | Heterogeneous |
| :-----: | :--: | :--: |
| 1-D | atomic vector | list |
| 2-D | matrix | data frame |
| none| array| |

### Indexing

Vectors have positions, these positions are ordered and can be called using 
`object[index]`


    # index
    letters[2]

    ## [1] "b"

### Functions

A function is an R object that takes inputs to perform a task. 
Functions take in information and may return desired outputs.

`output <- name_of_function(inputs)`


    # create a list of 1 to 10
    x <- 1:10 
    
    # the sum of all x
    y <- sum(x)
    y

    ## [1] 55


### Help

All functions come with a help screen. It is critical that you learn to read the
help screens since they provide important information on what the function does, 
how it works, and usually sample examples at the very bottom. You can use `help()`
or more simply `??()` 


    # call up a help search
    help.start()
    
    # help (documentation) for a package
    ?? ggplot2
    
    # help for a function
    ?? sum()

You can't ever learn all of R as it is ever changing with new packages and new 
tools, but once you have the basics and know how to find help to do the things 
that you want to do, you'll be able to use R in your science. 

### Sample Data

R comes with sample data sets. You will often find these as the date sets in 
documentation files or responses to inquires on public forums like *StackOverflow*. 
To see all available sample data sets you can type in `data()` to the console.  

### Packages in R

R comes with a set of functions or commands that perform particular sets of 
calculations. For example, in the equation `1+2`, R knows that the "+" means to 
add the two numbers, 1 and 2 together. However, you can expand the capability of 
R by installing packages that contain suites of functions and compiled code that 
you can also use in your code.  

Go to the next tutorial
[*Packages in R*]({{ site.baseurl }}/R/Packages-In-R/ "Packages in R").
