##########################################
##########################################
# Function to create a matrix to reclassify raster values

create_height_class_matrix <- function(breaks){
	# first create a matrix of values that represent the classification ranges
	# Lowest height class = 1
	
	# Get length of bins vector to figure out number of classes
	br.len <- length(breaks)
	
	# initialize height class vector
	height.class.m <- c(0)
	
	for (i in 1:br.len) {
		height.class.m <- c(height.class.m, breaks[i - 1], breaks[i], i)
	}
	
	# for input of breaks = c(6, 30, 50, 100) we want to make something like this:
	# height.class.m <- c(0, 6, 1, 
	# 					6, 30, 2, 
	# 					30, 50, 3, 
	# 					50, 100, 4)
	
	# reshape the object into a matrix with columns and rows
	reclass.height.mat <- matrix(height.class.m, 
								 ncol = 3, 
								 byrow = TRUE)
	
	reclass.height.mat
}


##########################################
##########################################
# plot density of chm heights with cutoff lines
plot_chm_density <- function(rast.in, site_name, bins) {
	
	density(rast.in, 
			main = paste("Canopy heights at", site_name, "site\n with bin cutoffs in red"), 
			xlab = "Height (m)")
	
	# cutoffs for bins from the reclassification matrix (second column)
	sapply(bins, function(x) abline(v = x, col = "red"))
	
}


##########################################
##########################################
# function to plot the reclassified raster

plot_reclassified_raster <- function(rast.in, site.name, breaks){
	# this is a tricky bit because we need to out the legend
	# outside of the plot region
	
	# Get colors for plotting
	bin.colors <- rev(terrain.colors(length(breaks)))
	
	# make room for a legend
	
	par(xpd = FALSE, mar = c(5.1, 4.1, 4.1, 4.5))
	
	# plot
	plot(rast.in,
		 col = bin.colors,
		 main = paste("Canopy height classes \n", site.name),
		 legend = FALSE)
	
	# allow legend to plot outside of bounds
	par(xpd = TRUE)
	
	# legend x
	leg.x <- par()$usr[2] + 20
	
	# legend y
	leg.y <- par()$usr[4] + 50 - (abs(par()$usr[3] - par()$usr[4]) / 2) 
	
	# create legend text
	height.mat <- create_height_class_matrix(breaks)
	
	# initialize legend text
	legend.text <- c()
	
	for (i in 1:length(breaks)) {
		
		legend.text <- c(legend.text, 
						 paste0(height.mat[i, 1], "-", 
						 	   height.mat[i, 2], " m"))
	}
	
	# create the legend
	legend(leg.x, leg.y,  # set x,y legend location
		   legend = legend.text,  # make sure the order matches colors
		   fill = bin.colors,
		   bty = "n") # turn off border
	
	# turn off plotting outside of bounds
	par(xpd = FALSE)
}

##########################################
##########################################
## An example that generates a PDF file from a function that creates a plot
## See http://nicercode.github.io/blog/2013-07-09-figure-functions/

make_pdf <- function(expr, filename, ..., verbose = TRUE) {
	if (verbose) {
		message("Creating: ", filename)
	}
	pdf(file = filename, ...)
	on.exit(dev.off())
	eval.parent(substitute(expr))
}
