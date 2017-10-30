## Summarizing lidar height values for each plot 

The `centre_ovr` object is a list of lists. It contains the lidar CHM pixel values that fall within each plot boundary. We want to summarize the data to get ONE summary height value for each plot. 
We will then create a new column in our `data.frame` that represents the max height value for all pixels
within each plot boundary. 

To summarize a list of numbers, we can use the `sapply` function. The `sapply` function
aggregates elements in the list using a aggregate function such as mean, max or min that we
specify in our code.

## Sapply Example

	# create 3 vectors of numbers
	a <- c(2, 3, 5, 7)
    b <- c(23, 13, 45, 57) 
	c <- c(2, 1, 4, 5) 
	#create a list of lists
	x <- list(a,b,c)

	x
	
The object `x` looks like: 
	
	[[1]]
	[1] 2 3 5 7

	[[2]]
	[1] 23 13 45 57

	[[3]]
	[1] 2 1 4 5

Let's call elements from the list

	# grab the first two elements of the second list in the x object
	x[[2]][1:2]

Calculate summary

	# grab the max value from each list in our object x
	summary <- sapply(x,max)
	
OUTPUT:

	[1]  7 57  5

<a href="http://www.r-bloggers.com/using-apply-sapply-lapply-in-r/" target="_blank">More about
the apply functions in R.</a>


In this case, we'll use the `sapply` command to return the `max` height value for pixels in each plot. 
Given we are working with lidar data, the max value will represent the tallest trees in the plot.

	centroids$chmMax <- sapply(cent_ovr, max)
 	
 	#look at the centroids dataframe structure
 	head(centroids$chmMax)
