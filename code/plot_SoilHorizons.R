## generate some profile depths: 0 - 150, in 10 cm increments
depth <- seq(0,150, by=10)

## generate some property: random numbers in this case
prop <- rnorm(n=length(depth), mean=15, sd=2)

## since the 0 is not a depth, and we would like the graph to start from 0
## make the first property row (associated with depth 0) the same as the second
## property row
prop[1] <- prop[2]

## combine into a table: data read in from a spread sheet would already be in this format
soil <- data.frame(depth=depth, prop=prop)

## note the reversal of the y-axis with ylim=c(150,0)
plot(depth ~ prop, data=soil, ylim=c(150,0), type='s', ylab='Depth', xlab='Property', main='Property vs. Depth Plot')

Really nice plots
#https://r-forge.r-project.org/scm/viewvc.php/*checkout*/docs/aqp/aqp-intro.html?root=aqp