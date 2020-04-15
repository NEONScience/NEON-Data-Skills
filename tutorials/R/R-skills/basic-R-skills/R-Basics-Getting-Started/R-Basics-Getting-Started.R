## ----comment------------------------------------------------------------------------------
# this is a comment. It allows text that is ignored by the program.
# for clean, easy to read comments, use a space between the # and text. 

# there is a line of code below this comment
 a <- 1+2



## ----basic-output1------------------------------------------------------------------------
# basic math
3 + 5

12/7



## ----basic-output2------------------------------------------------------------------------
# have R write words

writeLines("hello world")



## ----basic-input--------------------------------------------------------------------------

# assigning values to objects 
b <- 60 * 60

hours <- 365 * 24

# object names can't contain spaces.  Use a period, underscore, or camelCase to 
# create longer names
temp_HARV <- 90


## ----assignment-operator------------------------------------------------------------------
# this is preferred syntax
a <- 1+2 

# this is NOT preferred syntax
a = 1+2 


## ----ls-rm-funcs, eval=FALSE, comment=NA--------------------------------------------------

# assign value "5" to object "x"
x <- 5
ls()
    
# remove x
rm(x)

# what is left?
ls()
    
# remove all objects
rm(list = ls())

ls()



## ----basic-data---------------------------------------------------------------------------
# assign word "april" to x"
x <- "april"

# return the type of the object
typeof(x)

# 
attributes(x)

# assign all values 1 to 10 to the object y
y <- 1:10
y

typeof(y)

# how many 
length(y)

# 
z <- as.numeric(y)
z

typeof(z)



## ----vector-------------------------------------------------------------------------------

x <- vector()
    
# Create vector with a length and type
vector("character", length = 10)

# create character vector with length of 5
character(5)  

# numeric vector length=5
numeric(5)

# logical vector length=5
logical(5)

# create a list with combine `c()`
x <- c(1, 2, 3)
x
length(x)
typeof(x)


## ----integers-----------------------------------------------------------------------------
# a numeric vector with integers (L)
x1 <- c(1L, 2L, 3L)
x1
typeof(x1)

# or using as.integer()
x2 <- as.integer(x)
typeof(x2)


## ----log-vect-----------------------------------------------------------------------------
# logical vector 
y <- c(TRUE, TRUE, FALSE, FALSE)
y
typeof(y)


## ----char-vect----------------------------------------------------------------------------
# character vector
z <- c("Sarah", "Tracy", "Jon")
z
typeof(z)
length(z)

# what class is it
class(z)

# what is the structure
str(z)



## ----add-list-----------------------------------------------------------------------------
	z <- c(z, "Annette")
	z


## ----sequence-----------------------------------------------------------------------------
# simple series 
1:10

# use seq() 'sequence'
seq(10)

# specify values for seq()
seq(from = 1, to = 10, by = 0.1)


## -----------------------------------------------------------------------------------------
# infinity return
1/0

# non numeric return
0/0


## ----length-------------------------------------------------------------------------------

# length of an object
length(1:10)
length(x)

# number of characters in a text string
nchar("NEON Data Skills")



## ----challenge-code-types-hetero----------------------------------------------------------
n <- c(1.7, "a")
n
o <- c(TRUE, 2)
o
p <- c("a", TRUE)
p


## ----coercion-----------------------------------------------------------------------------
# making values numeric
as.numeric("1")

# make values charactor
as.character(c(1:2))

# make values 
as.factor(c("male","female"))


## ----matrix-------------------------------------------------------------------------------
# create an empty matrix that is 2x2
m <- matrix(nrow = 2, ncol = 2)
m

# what are the dimensions of m
dim(m)


## ----matrix2------------------------------------------------------------------------------
# create a matrix. Notice R fills them by columns
m2 <- matrix(1:6, nrow = 2, ncol = 3)
m2

m2_row <- matrix(c(1:6), nrow = 2, ncol = 3, byrow = TRUE)
m2_row


## ----matrix3------------------------------------------------------------------------------
# create vector with 1:10
m3 <- 1:10
m3
class(m3)

# set the dimensions so it becomes a matrix
dim(m3) <- c(2, 5)
m3
class(m3)

# create matrix from two vectors
x <- 1:3
y <- 10:12

# cbind will bind the two by column
cbind(x, y)

# rbind will bind the two by row
rbind(x, y)



## ----list---------------------------------------------------------------------------------

x <- list(1, "a", TRUE, 1 + (0+4i))
x
class(x)

x <- vector("list", length = 5)  ## empty list
length(x)

x[[1]]


x <- 1:10
x <- as.list(x)



## ----analytics----------------------------------------------------------------------------

xlist <- list(a = "Karthik Ram", b = 1:10, data = head(iris))
xlist

xlist$a
 
xlist$b

xlist$data



## ----factors------------------------------------------------------------------------------

x <- factor(c("yes", "no", "no", "yes", "yes"))
x



## ----conv-char----------------------------------------------------------------------------

as.character(x)



## ----conv-facor---------------------------------------------------------------------------

f <- factor(c(1, 5, 10, 2))

as.numeric(f)  ## wrong!

as.numeric(as.character(f))



## ----name---------------------------------------------------------------------------------

x <- factor(c("yes", "no", "yes"), levels = c("yes", "no"))
x


## ----dataframes---------------------------------------------------------------------------
# create a dataframe
dat <- data.frame(id = letters[1:10], x = 1:10, y = 11:20)
dat



## ----list2--------------------------------------------------------------------------------

list()

is.list(iris)

class(iris)



## ----indexing-----------------------------------------------------------------------------
# index
letters[2]



## ----funct--------------------------------------------------------------------------------
# create a list of 1 to 10
x <- 1:10 

# the sum of all x
y <- sum(x)
y


## ----help---------------------------------------------------------------------------------
# call up a help search
help.start()

# help (documentation) for a package
?? ggplot2

# help for a function
?? sum()


