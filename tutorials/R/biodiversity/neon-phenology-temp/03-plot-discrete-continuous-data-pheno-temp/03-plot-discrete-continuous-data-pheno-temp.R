## ----setup-env-----------------------------------------------------------------------------------------------------------
# Install needed package (only uncomment & run if not already installed)
#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("scales")

# Load required libraries
library(ggplot2)
library(dplyr)
library(gridExtra)
library(scales)

options(stringsAsFactors=F) #keep strings as character type not factors

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd <- "~/Documents/data/" # Change this to match your local environment
setwd(wd)


## ----load-data-----------------------------------------------------------------------------------------------------------
# Read in data -> if in series this is unnecessary
temp_day <- read.csv(paste0(wd,'NEON-pheno-temp-timeseries/NEONsaat_daily_SCBI_2018.csv'))

phe_1sp_2018 <- read.csv(paste0(wd,'NEON-pheno-temp-timeseries/NEONpheno_LITU_Leaves_SCBI_2018.csv'))

# Convert dates
temp_day$Date <- as.Date(temp_day$Date)
# use dateStat - the date the phenophase status was recorded
phe_1sp_2018$dateStat <- as.Date(phe_1sp_2018$dateStat)



## ----stacked-plots, fig.cap="One graphic showing two plots arranged vertically by using the grid.arrange function form the gridExtra package. The top plot shows a bar plot of the counts of Liriodendrum tulipifera (LITU) individuals at the Smithsonian Conservation Biology Institute (SCBI) for the year 2018. The bottom plot shows a scatter plot of daily maximum temperatures(of 30 minute interval means) for the year 2018 at the Smithsonian Conservation Biology Institute (SCBI)."----
# first, create one plot 
phenoPlot <- ggplot(phe_1sp_2018, aes(dateStat, countYes)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("") + ylab("Number of Individuals")

# create second plot of interest
tempPlot_dayMax <- ggplot(temp_day, aes(Date, dayMax)) +
    geom_point() +
    ggtitle("Daily Max Air Temperature") +
    xlab("Date") + ylab("Temp (C)")

# Then arrange the plots - this can be done with >2 plots as well.
grid.arrange(phenoPlot, tempPlot_dayMax) 



## ----format-x-axis-labels, fig.cap="Graphic showing the arranged plots created in the previous step, with the x-axis formatted to only read 'month' in both plots. However, it is important to note that this step only partially fixes the problem. The plots still have different ranges on the x-axis, which makes it harder to see trends. The top plot shows a bar plot of the counts of Liriodendrum tulipifera (LITU) individuals at the Smithsonian Conservation Biology Institute (SCBI) for the year 2018. The bottom plot shows a scatter plot of daily maximum temperatures(of 30 minute interval means) for the year 2018 at the Smithsonian Conservation Biology Institute (SCBI)."----
# format x-axis: dates
phenoPlot <- phenoPlot + 
  (scale_x_date(breaks = date_breaks("1 month"), labels = date_format("%b")))

tempPlot_dayMax <- tempPlot_dayMax +
  (scale_x_date(breaks = date_breaks("1 month"), labels = date_format("%b")))

# New plot. 
grid.arrange(phenoPlot, tempPlot_dayMax) 



## ----set-x-axis, fig.cap="Graphic showing the arranged plots created in the previous step, with the x-axis formatted to only read 'month', and scaled so they align with each other. This is achieved by adding the limits parameter to the scale_x_date function in the ggplot call. The top plot shows a bar plot of the counts of Liriodendrum tulipifera (LITU) individuals at the Smithsonian Conservation Biology Institute (SCBI) for the year 2018. The bottom plot shows a scatter plot of daily maximum temperatures(of 30 minute interval means) for the year 2018 at the Smithsonian Conservation Biology Institute (SCBI)."----
# first, lets recreate the full plot and add in the 
phenoPlot_setX <- ggplot(phe_1sp_2018, aes(dateStat, countYes)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("") + ylab("Number of Individuals") +
    scale_x_date(breaks = date_breaks("1 month"), 
                  labels = date_format("%b"),
                  limits = as.Date(c('2018-01-01','2018-12-31')))

# create second plot of interest
tempPlot_dayMax_setX <- ggplot(temp_day, aes(Date, dayMax)) +
    geom_point() +
    ggtitle("Daily Max Air Temperature") +
    xlab("Date") + ylab("Temp (C)") +
    scale_x_date(date_breaks = "1 month", 
                 labels=date_format("%b"),
                  limits = as.Date(c('2018-01-01','2018-12-31')))

# Plot
grid.arrange(phenoPlot_setX, tempPlot_dayMax_setX) 



## ----align-datasets-replot, fig.cap="Graphic of the arranged plots created in the previous steps with only the data that overlap. This was achieved by filtering the daily max temperature data by the observation date in the total individuals in Leaf dataset. The top plot shows a bar plot of the counts of Liriodendrum tulipifera (LITU) individuals at the Smithsonian Conservation Biology Institute (SCBI) for the year 2018. The bottom plot shows a scatter plot of daily maximum temperatures(of 30 minute interval means) for the year 2018 at the Smithsonian Conservation Biology Institute (SCBI)."----
# filter to only having overlapping data
temp_day_filt <- filter(temp_day, Date >= min(phe_1sp_2018$date) & 
                         Date <= max(phe_1sp_2018$date))

# Check 
range(phe_1sp_2018$date)
range(temp_day_filt$Date)

#plot again
tempPlot_dayMaxFiltered <- ggplot(temp_day_filt, aes(Date, dayMax)) +
    geom_point() +
    scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) +
    ggtitle("Daily Max Air Temperature") +
    xlab("Date") + ylab("Temp (C)")


grid.arrange(phenoPlot, tempPlot_dayMaxFiltered)



## ----two-y-axes-ggplot---------------------------------------------------------------------------------------------------

# Source: http://heareresearch.blogspot.com/2014/10/10-30-2014-dual-y-axis-graph-ggplot2_30.html

# Additional packages needed
library(gtable)
library(grid)


# Plot 1: Pheno data as bars, temp as scatter
grid.newpage()
phenoPlot_2 <- ggplot(phe_1sp_2018, aes(dateStat, countYes)) +
  geom_bar(stat="identity", na.rm = TRUE) +
  scale_x_date(breaks = date_breaks("1 month"), labels = date_format("%b")) +
  ggtitle("Total Individuals in Leaf vs. Temp (C)") +
  xlab(" ") + ylab("Number of Individuals") +
  theme_bw()+
  theme(legend.justification=c(0,1),
        legend.position=c(0,1),
        plot.title=element_text(size=25,vjust=1),
        axis.text.x=element_text(size=20),
        axis.text.y=element_text(size=20),
        axis.title.x=element_text(size=20),
        axis.title.y=element_text(size=20))


tempPlot_dayMax_corr_2 <- ggplot() +
  geom_point(data = temp_day_filt, aes(Date, dayMax),color="red") +
  scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) +
  xlab("") + ylab("Temp (C)") +
  theme_bw() %+replace% 
  theme(panel.background = element_rect(fill = NA),
        panel.grid.major.x=element_blank(),
        panel.grid.minor.x=element_blank(),
        panel.grid.major.y=element_blank(),
        panel.grid.minor.y=element_blank(),
        axis.text.y=element_text(size=20,color="red"),
        axis.title.y=element_text(size=20))

g1<-ggplot_gtable(ggplot_build(phenoPlot_2))
g2<-ggplot_gtable(ggplot_build(tempPlot_dayMax_corr_2))

pp<-c(subset(g1$layout,name=="panel",se=t:r))
g<-gtable_add_grob(g1, g2$grobs[[which(g2$layout$name=="panel")]],pp$t,pp$l,pp$b,pp$l)

ia<-which(g2$layout$name=="axis-l")
ga <- g2$grobs[[ia]]
ax <- ga$children[[2]]
ax$widths <- rev(ax$widths)
ax$grobs <- rev(ax$grobs)
ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(1, "npc") + unit(0.15, "cm")
g <- gtable_add_cols(g, g2$widths[g2$layout[ia, ]$l], length(g$widths) - 1)
g <- gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)

grid.draw(g)


# Plot 2: Both pheno data and temp data as line graphs
grid.newpage()
phenoPlot_3 <- ggplot(phe_1sp_2018, aes(dateStat, countYes)) +
  geom_line(na.rm = TRUE) +
  scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) +
  ggtitle("Total Individuals in Leaf vs. Temp (C)") +
  xlab("Date") + ylab("Number of Individuals") +
  theme_bw()+
  theme(legend.justification=c(0,1),
        legend.position=c(0,1),
        plot.title=element_text(size=25,vjust=1),
        axis.text.x=element_text(size=20),
        axis.text.y=element_text(size=20),
        axis.title.x=element_text(size=20),
        axis.title.y=element_text(size=20))

tempPlot_dayMax_corr_3 <- ggplot() +
  geom_line(data = temp_day_filt, aes(Date, dayMax),color="red") +
  scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) +
  xlab("") + ylab("Temp (C)") +
  theme_bw() %+replace% 
  theme(panel.background = element_rect(fill = NA),
        panel.grid.major.x=element_blank(),
        panel.grid.minor.x=element_blank(),
        panel.grid.major.y=element_blank(),
        panel.grid.minor.y=element_blank(),
        axis.text.y=element_text(size=20,color="red"),
        axis.title.y=element_text(size=20))

g1<-ggplot_gtable(ggplot_build(phenoPlot_3))
g2<-ggplot_gtable(ggplot_build(tempPlot_dayMax_corr_3))

pp<-c(subset(g1$layout,name=="panel",se=t:r))
g<-gtable_add_grob(g1, g2$grobs[[which(g2$layout$name=="panel")]],pp$t,pp$l,pp$b,pp$l)

ia<-which(g2$layout$name=="axis-l")
ga <- g2$grobs[[ia]]
ax <- ga$children[[2]]
ax$widths <- rev(ax$widths)
ax$grobs <- rev(ax$grobs)
ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(1, "npc") + unit(0.15, "cm")
g <- gtable_add_cols(g, g2$widths[g2$layout[ia, ]$l], length(g$widths) - 1)
g <- gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)

grid.draw(g)


