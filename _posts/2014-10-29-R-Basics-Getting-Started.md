---
layout: post
title: "Activity: Getting Started with R"
date:   2014-11-04 20:49:52
authors: Adapted from Software Carpentry Materials by Leah A. Wasser
categories: [Coding and Informatics]
tags : [R]
description: "This activity will provide the basics of using R."
code1: 
image:
  feature: codedpoints2.png
  credit: National Ecological Observatory Network
  creditlink: http://www.neoninc.org
permalink: /R-Programming/Getting-Started-With-R
---

<section id="table-of-contents" class="toc">
  <header>
    <h3 >Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->

# The Very Basics of R

R is a versatile, open source programming language that was specifically designed for data analysis. R is extremely useful both for statistics and analyzing data. 

>Cool Fact: R was inspired by the programming language <a href="http://en.wikipedia.org/wiki/S_(programming_language)" target="_blank">S</a>.  

R is:
* Open source software under a <a href="http://en.wikipedia.org/wiki/GNU_General_Public_License" target="_blank">General Public License (GPL)</a>.  
* A good alternative to commercial analysis tools. R has over 5,000 user contributed packages and is widely used both in academia and industry.  
* Available on all platforms.  
* Not just for statistics, but also general purpose programming.   
* Supported by a large and growing community of peers.  

#Basic Syntax

##Comments in R
Use `#` signs to comment. Comment liberally in your R scripts. Anything to the right of a `#` is ignored by R.  

    #this is a comment. there is a line of code below it.
    a <- 1+2

### Drop the Equals Sign - Assignment operator

`<-` is the assignment operator. Assigns values on the right to objects on the left. Mostly similar to `=` but not always. Learn to use `<-` as it is good programming practice. Using `=` in place of `<-` can lead to issues down the line.

    a<- 1+2 #this is preferred syntax over:
    a= 1+2 #this is NOT preferred syntax
    
    
### Packages in R
R comes with a set of functions or commands that perform particular sets of calculations. For example, in the equation 1+2, R knows that the "+" means to add the two numbers, 1 and 2 together. However, you can expand the capability of R by installing packages that contain suites of functions and compiled code that you can also use in your code.  

[Learn more about packages in R - Adapted from Software Carpentry, HERE.]({{ site.baseurl }}/R/Packages-In-R/ "Packages in R")


## Introduction to R and RStudio

You can use R or RStudio to write your code. Some people prefer R studio as it provides a graphic interface where you can see what objects have been created and you can also set variables like your working directory, using menu options.

> Let's start by learning about R studio and R.  
> [Learn More about R Studio](http://dss.princeton.edu/training/RStudio101.pdf)
> * Console, Scripts, Environments, Plots
> * Avoid using shortcuts. 
> * Code and workflow is more reproducible if we can document everything that we do.
> * Our end goal is not just to "do stuff" but to do it in a way that anyone can easily and exactly replicate our workflow and results.

##Basic Operations in R
Let's take a few moments to play with R. You can get output from R simply by typing in math

    3 + 5


`[1] 8` 

    12/7


`[1] 1.714`
 
or by typing words, with the command `writeLines()`


   writeLines("hello world")

`hello world`

We can assign our results to an object, if we give it a name

    a <- 60 * 60
    hours <- 365 * 24
 
The *result* of the operation on the right hand side of `<-` is *assigned* to an object with the name specified on the left hand side of `<-`. The *result* could be any type of R object, including your own functions.


### List All objects in the environment
Some of the same commands we learned from the command line can be used in R.
List objects in your current environment

    ls()

Remove objects from your current environment.  

    x <- 5
    rm(x)

Remove all objects from your current environment. Typing `x` on the console will give you an error.

    rm(list = ls())

## Data types and structures

### Understanding basic data types in R

To make the best of the R language, you'll need a strong understanding of the basic data types and data structures and how to operate on those.

This understanding is because these are the objects you will manipulate on a day-to-day basis in R. Dealing with object conversions is one of the most common sources of frustration for beginners.

**Everything** in R is an object.

R has 6 (although we will not discuss the raw class for this workshop) atomic vector types.

* character
* numeric (real or decimal)
* integer
* logical
* complex

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
 

**Let's look at some examples:**

    x <- "dataset"
    typeof(x)


`OUTPUT: [1] "character"`

    attributes(x)

`NULL`

    y <- 1:10
    y


`OUTPUT: [1]  1  2  3  4  5  6  7  8  9 10`

    typeof(y)


`OUTPUT: [1] "integer"`

    length(y)

`OUTPUT: [1] 10`

	z <- as.numeric(y)
	z

`OUTPUT: [1]  1  2  3  4  5  6  7  8  9 10`

    typeof(z)

`OUTPUT: [1] "double"`


R has many __data structures__. These include

- atomic vector
- list
- matrix
- data frame
- factors

### Vectors

A vector is the most common and basic data structure in R and is the workhorse of R. Technically, vectors can be one of two types:

* atomic vectors
* lists

although the term "vector" most commonly refers to the atomic types not to lists.


#### Atomic Vectors

A vector is a collection of elements that are most commonly `character`, `logical`, `integer` or `numeric`.

You can create an empty vector with `vector()`. (By default the mode is `logical`. You can be more explicit as shown in the examples below.) It is more common to use direct constructors such as `character()`, `numeric()`, etc.


    x <- vector()
    
	#Create vector with a length and type
    vector("character", length = 10)

`OUTPUT: [1] "" "" "" "" "" "" "" "" "" ""`


	#create character vector with length of 5
	character(5)  

`OUTPUT: [1] "" "" "" "" ""`

	#numeric vector length=5
	numeric(5)

`OUTPUT: [1] 0 0 0 0 0`
	
	#logical vector length=5
	logical(5)

`OUTPUT: [1] FALSE FALSE FALSE FALSE FALSE`


Some othe examples of creating objects in R follow:


	x <- c(1, 2, 3)
	x


`OUTPUT: [1] 1 2 3`


	length(x)

`OUTPUT: [1] 3`

`x` is a numeric vector. These are the most common kind. They are numeric objects and are treated as double precision real numbers (they can store decimal points). To explicitly create integers (no decimal points), add an `L` to each (or *coerce* to the integer type using `as.integer()`.

	#a numeric vector with integers (L)
	x1 <- c(1L, 2L, 3L)


You can also have logical vectors. 

	y <- c(TRUE, TRUE, FALSE, FALSE)


Finally you can have character vectors:

	z <- c("Sarah", "Tracy", "Jon")


**Examine your vector**  


	typeof(z)


OUTPUT: [1] "character"

	length(z)


OUTPUT [1] 3 

	class(z)

OUTPUT: [1] "character"

	str(z)

OUTPUT:  chr [1:3] "Sarah" "Tracy" "Jon"


Question: Do you see a property that's common to all these vectors above?

**Add elements**


	z <- c(z, "Annette")
	z

OUTPUT: [1] "Sarah"   "Tracy"   "Jon"     "Annette"



More examples of vectors

	x <- c(0.5, 0.7)
	x <- c(TRUE, FALSE)
	x <- c("a", "b", "c", "d", "e")
	x <- 9:100
	x <- c(1 + (0+0i), 2 + (0+4i))

You can also create vectors as a sequence of numbers



	series <- 1:10
	seq(10)


OUTPUT:  [1]  1  2  3  4  5  6  7  8  9 10


	seq(from = 1, to = 10, by = 0.1)


OUTPUT:
 [1]  1.0  1.1  1.2  1.3  1.4  1.5  1.6  1.7  1.8  1.9  2.0  2.1  2.2  2.3
 [15]  2.4  2.5  2.6  2.7  2.8  2.9  3.0  3.1  3.2  3.3  3.4  3.5  3.6  3.7
 [29]  3.8  3.9  4.0  4.1  4.2  4.3  4.4  4.5  4.6  4.7  4.8  4.9  5.0  5.1
 [43]  5.2  5.3  5.4  5.5  5.6  5.7  5.8  5.9  6.0  6.1  6.2  6.3  6.4  6.5
 [57]  6.6  6.7  6.8  6.9  7.0  7.1  7.2  7.3  7.4  7.5  7.6  7.7  7.8  7.9
 [71]  8.0  8.1  8.2  8.3  8.4  8.5  8.6  8.7  8.8  8.9  9.0  9.1  9.2  9.3
 [85]  9.4  9.5  9.6  9.7  9.8  9.9 10.0



`Inf` is infinity. You can have either positive or negative infinity.


	1/0

OUTPUT: [1] Inf


`NaN` means Not a Number. It's an undefined value.

	0/0

OUTPUT: [1] NaN


Objects can have __attributes__. Attribues are part of the object. These include:

* names
* dimnames
* dim
* class
* attributes (contain metadata)

You can also glean other attribute-like information such as length (works on vectors and lists) or number of characters (for character strings).



	length(1:10)

[1] 10

	nchar("Software Carpentry")

[1] 18


####What happens when you mix types?

When you mix types, R will create a resulting vector that is the least common denominator. The coercion will move towards the one that's easiest to __coerce__ to.

Guess what the following do without running them first


	xx <- c(1.7, "a")
	xx <- c(TRUE, 2)
	xx <- c("a", TRUE)



This is called implicit coercion. You can also coerce vectors explicitly using the `as.<class_name>`. Example



	as.numeric("1")



OUTPUT: [1] 1



	as.character(1:2)



OUTPUT [1] "1" "2"



### Matrix

In R matrices are an extension of the numeric or character vectors. They are not a separate type of object but simply an atomic vector with dimensions; the number of rows and columns.



	m <- matrix(nrow = 2, ncol = 2)
	m


OUTPUT:

   [,1] [,2]
[1,]   NA   NA
[2,]   NA   NA



	dim(m)



OUTPUT [1] 2 2



Matrices in R are filled column-wise.



	m <- matrix(1:6, nrow = 2, ncol = 3)



Other ways to construct a matrix. 



	m <- 1:10
	dim(m) <- c(2, 5)



`Dim` takes a vector and transform into a matrix with 2 rows and 5 columns. Another way to shape your matrix is to bind columns `cbind()` or rows `rbind()`.



	x <- 1:3
	y <- 10:12
	cbind(x, y)



OUTPUT
.    x  y
[1,] 1 10
[2,] 2 11
[3,] 3 12



	rbind(x, y)



OUTPUT
[,1] [,2] [,3]
x    1    2    3
y   10   11   12


You can also use the `byrow` argument to specify how the matrix is filled. From R's own documentation:



	mdat <- matrix(c(1, 2, 3, 11, 12, 13), nrow = 2, ncol = 3, byrow = TRUE)
	mdat


OUTPUT:
.     [,1] [,2] [,3]
[1,]    1    2    3
[2,]   11   12   13



### List

In R lists act as containers. Unlike atomic vectors, the contents of a list are not restricted to a single mode and can encompass any mixture of data types. Lists are sometimes called generic vectors, because the elements of a list can by of any type of R object, even lists containing further lists. This property makes them fundamentally different from atomic vectors.

A list is a special type of vector. Each element can be a different type.

Create lists using `list()` or coerce other objects using `as.list()`. An empty list of the required length can be created using `vector()`



	x <- list(1, "a", TRUE, 1 + (0+4i))
	x


OUTPUT:

[[1]]
[1] 1
 
[[2]]
[1] "a"
 
[[3]]
[1] TRUE
 
[[4]]
[1] 1+4i




	x <- vector("list", length = 5)  ## empty list
	length(x)



OUTPUT: [1] 5



	x[[1]]



OUTPUT:  NULL

	x <- 1:10
	x <- as.list(x)
	length(x)



 [1] 10



1. What is the class of `x[1]`?
2. What about `x[[1]]`?



	xlist <- list(a = "Karthik Ram", b = 1:10, data = head(iris))
	xlist


OUTPUT:

$a
[1] "Ben Smiley"
 
$b
[1]  1  2  3  4  5  6  7  8  9 10



 
$data

|     | Sepal.Length | Sepal.Width | Petal.Length | Petal.Width | Species |
| --- | :--------: | :-------: | :---------: | :-------------: | ------- |
| 1   |      5.1   |    3.5    |      1.4    |      0.2        |   setosa |
| 2   |      4.9   |    3.0    |      1.4    |      0.2        |   setosa |
| 3   |      4.7   |    3.2    |      1.3    |      0.2        |   setosa |
| 4   |      4.6   |    3.1    |      1.5    |      0.2        |   setosa |
| 5   |      5.0   |    3.6    |      1.4    |      0.2        |   setosa |
| 6   |      5.4   |    3.9    |      1.7    |      0.4        |   setosa |



1. What is the length of this object? What about its structure?

* Lists can be extremely useful inside functions. You can “staple” together lots of different kinds of results into a single object that a function can return.

* A list does not print to the console like a vector. Instead, each element of the list starts on a new line.

* Elements are indexed by double brackets. Single brackets will still return a(nother) list.


### Factors

Factors are special vectors that represent categorical data. Factors can be ordered or unordered and are important for modelling functions such as `lm()` and `glm()` and also in `plot()` methods. Once created, factors can only contain a pre-defined set values, known as *levels*.

Factors are stored as integers that have labels associated the unique integers. While factors look (and often behave) like character vectors, they are actually integers under the hood. You need to be careful when treating them like strings. Some string methods will coerce factors to strings, while others will throw an error.

* Sometimes factors can be left unordered. Example: male, female.

* Other times you might want factors to be ordered (or ranked). Example: low, medium, high.

* Underlying it's represented by numbers 1, 2, 3.

* They are better than using simple integer labels because factors are what are called self describing. male and female is more descriptive than 1s and 2s. Helpful when there is no additional metadata.

Which is male? 1 or 2? You wouldn't be able to tell with just integer data. Factors have this information built in.

Factors can be created with `factor()`. Input is often a character vector.



	x <- factor(c("yes", "no", "no", "yes", "yes"))
	x



OUTPUT:
 [1] yes no  no  yes yes
 Levels: no yes



`table(x)` will return a frequency table counting the number of elements in each level.

If you need to convert a factor to a character vector, simply use



	as.character(x)



OUTPUT: [1] "yes" "no"  "no"  "yes" "yes"



To convert a factor to a numeric vector, go via a character. Compare



	f <- factor(c(1, 5, 10, 2))
	as.numeric(f)  ## wrong!



OUTPUT: [1] 1 3 4 2



	as.numeric(as.character(f))



OUTPUT [1]  1  5 10  2  


In modeling functions, it is important to know what the baseline level is. This is the first factor but by default the ordering is determined by alphanumerical order of elements. You can change this by speciying the `levels` (another option is to use the function `relevel()`).



	x <- factor(c("yes", "no", "yes"), levels = c("yes", "no"))
	x


OUTPUT  
 [1] yes no  yes
 Levels: yes no



### Data frame

A data frame is a very important data type in R. It's pretty much the *de facto* data structure for most tabular data and what we use for statistics.  


* A data frame is a special type of list where every element of the list has same length.  


* Data frames can have additional attributes such as `rownames()`, which can be useful for annotating data, like `subject_id` or `sample_id`. But most of the time they are not used.  

Some additional information on data frames:

* Usually created by `read.csv()` and `read.table()`.
* Can convert to matrix with `data.matrix()` (preferred) or `as.matrix()`
* Coercion will be forced and not always what you expect.
* Can also create with `data.frame()` function.
* Find the number of rows and columns with `nrow(dat)` and `ncol(dat)`, respectively.
* Rownames are usually 1, 2, ..., n.

#### Creating data frames by hand



	dat <- data.frame(id = letters[1:10], x = 1:10, y = 11:20)
	dat


OUTPUT  
    id  x  y  
 1   a  1 11  
 2   b  2 12  
 3   c  3 13  
 4   d  4 14  
 5   e  5 15  
 6   f  6 16  
 7   g  7 17  
 8   h  8 18  
 9   i  9 19  
 10  j 10 20  



#### Useful data frame functions

* `head()` - shown first 6 rows
* `tail()` - show last 6 rows
* `dim()` - returns the dimensions
* `nrow()` - number of rows
* `ncol()` - number of columns
* `str()` - structure of each column
* `names()` - shows the `names` attribute for a data frame, which gives the column names.

See that it is actually a special list:



	is.list(iris)



[1] TRUE



	class(iris)



[1] "data.frame"



| Dimensions | Homogenous | Heterogeneous |
| :-----: | :--: | :--: |
| 1-D | atomic vector | list |
| 2_D | matrix | data frame |

### Indexing

Vectors have positions, these positions are ordered and can be called using `object[index]`



	letters[2]



OUTPUT: [1] "b"



### Functions

A function is an R object that takes inputs to perform a task. 
Functions take in information and may return desired outputs.

`output <- name_of_function(inputs)`



	x <- 1:10
	y <- sum(x)



### Help

All functions come with a help screen. 
It is critical that you learn to read the help screens since they provide important information on what the function does, 
how it works, and usually sample examples at the very bottom.

### Get new functions

To install any package use `install.packages()`



install.packages("ggplot2")  ## install the ggplot2 package



You can't ever learn all of R, but you can learn how to build a program and how to find help to do the things that you want to do.

Let's get hands-on.
