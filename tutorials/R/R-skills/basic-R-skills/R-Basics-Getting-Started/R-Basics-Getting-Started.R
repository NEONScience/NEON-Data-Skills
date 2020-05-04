## ----comment--------------------------------------------------
# this is a comment. It allows text that is ignored by the program.
# for clean, easy to read comments, use a space between the # and text. 

# there is a line of code below this comment
 a <- 1 + 2



## ----basic-output1--------------------------------------------
# basic math
3 + 5

12 / 7



## ----basic-output2--------------------------------------------
# have R write words

writeLines("Hello World")



## ----basic-input----------------------------------------------

# assigning values to objects 
secondsPerHour <- 60 * 60

hoursPerYear <- 365 * 24


# object names can't contain spaces.  Use a period, underscore, or camelCase to 
# create longer names
temp_HARV <- 90
par.OSBS <- 180


## ----basic-output3--------------------------------------------
secondsPerHour
hoursPerYear


## ----basic-output4--------------------------------------------
secondsPerYear <- secondsPerHour * hoursPerYear

secondsPerYear


## ----assignment-operator--------------------------------------
# this is preferred syntax
a <- 1 + 2 

# this is NOT preferred syntax
a = 1 + 2 


## ----ls-rm-funcs, eval=FALSE, comment=NA----------------------

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



## ----basic-data-----------------------------------------------
# assign word "april" to x"
x <- "april"

# return the type of the object
class(x)

# does x have any attributes?
attributes(x)

# assign all integers 1 to 10 as an atomic vector to the object y
y <- 1:10
y

class(y)

# how many values does the vector y contain?
length(y)

# coerce the integer vector y to a numeric vector
# store the result in the object z
z <- as.numeric(y)
z

class(z)



## ----vector---------------------------------------------------

x <- vector()
    
# Create vector with a length and type
vector("character", length = 10)

# create character vector with length of 5
character(5)

# numeric vector length=5
numeric(5)

# logical vector length=5
logical(5)

# create a list or vector with combine `c()`
# this is the function used to create vectors and lists most of the time
x <- c(1, 2, 3)
x
length(x)
class(x)


## ----integers-------------------------------------------------
# a numeric vector with integers (L)
x1 <- c(1L, 2L, 3L)
x1
class(x1)

# or using as.integer()
x2 <- as.integer(x)
class(x2)


## ----log-vect-------------------------------------------------
# logical vector 
y <- c(TRUE, TRUE, FALSE, FALSE)
y
class(y)


## ----char-vect------------------------------------------------
# character vector
z <- c("Sarah", "Tracy", "Jon")
z

# what class is it?
class(z)

#how many elements does it contain?
length(z)

# what is the structure?
str(z)



## ----add-vector-----------------------------------------------
# c function combines z and "Annette" into a single vector
# store result back to z
z <- c(z, "Annette")
z


## ----sequence-------------------------------------------------
# simple series 
1:10

# use seq() 'sequence'
seq(10)

# specify values for seq()
seq(from = 1, to = 10, by = 0.1)


## -------------------------------------------------------------
# infinity return
1/0

# non numeric return
0/0


## ----indexing-------------------------------------------------
# index
z[2]

# to call multiple items (a subset of our data), we can put a vector of which 
# items we want in the brackets
group1 <- c(1, 4)
z[group1]

# this is especially useful with a sequence vector
z[1:3]



## ----length---------------------------------------------------

# length of an object
length(1:10)
length(x)

# number of characters in a text string
nchar("NEON Data Skills")



## ----challenge-code-types-hetero------------------------------
n <- c(1.7, "a")
n

o <- c(TRUE, 2)
o

p <- c("a", TRUE)
p


## ----coercion-------------------------------------------------
# making values numeric
as.numeric("1")

# make values charactor
as.character(1)

# make values 
as.factor(c("male", "female"))


## ----matrix---------------------------------------------------
# create an empty matrix that is 2x2
m <- matrix(nrow = 2, ncol = 2)
m

# what are the dimensions of m
dim(m)


## ----matrix2--------------------------------------------------
# create a matrix. Notice R fills them by columns by default
m2 <- matrix(1:6, nrow = 2, ncol = 3)
m2

# set the byrow argument to TRUE to fill by rows
m2_row <- matrix(c(1:6), nrow = 2, ncol = 3, byrow = TRUE)
m2_row


## ----matrix3--------------------------------------------------
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



## ----matrix-index---------------------------------------------
z <- matrix(c("a", "b", "c", "d", "e", "f"), nrow = 3, ncol = 2)
z

# call element in the third row, second column
z[3, 2]

# leaving the row blank will return contents of the whole column
# note: the column's contents are displayed as a vector (horizontally)
z[, 2]

class(z[, 2])

# return the contents of the second row
z[2, ]


## ----list-----------------------------------------------------

x <- list(1, "a", TRUE, 1 + (0 + 4i))
x
class(x)

x <- vector("list", length = 5)  ## empty list
length(x)

#call the 1st element of list x
x[[1]]


x <- 1:10
x <- as.list(x)



## ----analytics------------------------------------------------
# note 'iris' is an example data frame included with R
# the head() function simply calls the first 6 rows of the data frame
xlist <- list(a = "Karthik Ram", b = 1:10, data = head(iris))
xlist

# see names of our list elements
names(xlist)

# call individual elements by name
xlist$a
 
xlist$b

xlist$data



## ----factors--------------------------------------------------

x <- factor(c("yes", "no", "no", "yes", "yes"))
x



## ----conv-char------------------------------------------------

as.character(x)



## ----conv-factor1---------------------------------------------
as.numeric(x)


## ----conv-factor2---------------------------------------------

f <- factor(c(1, 5, 5, 10, 2, 2, 2))

levels(f)       ## returns just the four levels present in our factor

as.numeric(f)   ## wrong! returns the assigned integer for each level
                ## integer corresponds to the position of that number in levels(f)

as.character(f) ## returns a character string of each number

as.numeric(as.character(f)) ## coerce the character strings to numbers



## ----name-----------------------------------------------------
# the default result (because N comes before Y alphabetically)
x <- factor(c("yes", "no", "yes"))
x

# now let's try again, this time specifying the order of our levels
x <- factor(c("yes", "no", "yes"), levels = c("yes", "no"))
x


## ----dataframes-----------------------------------------------
# create a dataframe
dat <- data.frame(id = letters[1:10], x = 1:10, y = 11:20)
dat



## ----list2----------------------------------------------------

list() 

is.list(iris)

class(iris)



## ----list3----------------------------------------------------
# see the class of a single variable column within iris: "Sepal.Length"
class(iris$Sepal.Length)


## ----funct----------------------------------------------------
# create a list of 1 to 10
x <- 1:10 

# the sum of all x
y <- sum(x)
y


## ----help-----------------------------------------------------
# call up a help search
help.start()

# help (documentation) for a package
??ggplot2

# help for a function
??sum()


