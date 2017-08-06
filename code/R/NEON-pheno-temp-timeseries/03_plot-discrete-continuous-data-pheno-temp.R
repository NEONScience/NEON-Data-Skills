## ----import-data---------------------------------------------------------

# Load required libraries
library(ggplot2)
library(dplyr)
library(lubridate)
library(gridExtra)
library(scales)  # use with date_breaks

# set working directory to ensure R can find the file we wish to import
# setwd("working-dir-path-here")

# Read in data -> if in series this is unnecessary
temp_day <- read.csv('NEON-pheno-temp-timeseries/temp/NEONsaat_daily_SCBI_2016.csv',
		stringsAsFactors = FALSE)

phe_1sp_2016 <- read.csv('NEON-pheno-temp-timeseries/pheno/NEONpheno_LITU_Leaves_SCBI_2016.csv',
		stringsAsFactors = FALSE)

# Convert dates
temp_day$sDate <- as.Date(temp_day$sDate)
phe_1sp_2016$date <- as.Date(phe_1sp_2016$date)


## ----stacked-plots-------------------------------------------------------

phenoPlot <- ggplot(phe_1sp_2016, aes(date, n.y)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("Date") + ylab("Number of Individuals") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

phenoPlot

tempPlot_dayMax <- ggplot(temp_day, aes(sDate, dayMax)) +
    geom_point() +
    ggtitle("Daily Max Air Temperature") +
    xlab("") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

tempPlot_dayMax


# Output with both plots
grid.arrange(phenoPlot, tempPlot_dayMax) 


## ----format-x-axis-labels------------------------------------------------
# format x-axis: dates
phenoPlot <- phenoPlot + 
  (scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")))

phenoPlot

tempPlot_dayMax <- tempPlot_dayMax +
  (scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")))

tempPlot_dayMax

# Output with both plots
grid.arrange(phenoPlot, tempPlot_dayMax) 


## ----align-datasets-replot-----------------------------------------------
# align dates
temp_day_fit <- filter(temp_day, sDate >= min(phe_1sp_2016$date) & sDate <= max(phe_1sp_2016$date))

# Check it
range(phe_1sp_2016$date)
range(temp_day_fit$sDate)

#plot again
tempPlot_dayMax_corr <- ggplot(temp_day_fit, aes(sDate, dayMax)) +
    geom_point() +
    scale_x_date(breaks = date_breaks("months"), labels = date_format("%b")) +
    ggtitle("Daily Max Air Temperature") +
    xlab("") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

grid.arrange(phenoPlot, tempPlot_dayMax_corr)


## ----two-y-axes-ggplot---------------------------------------------------

# Source: http://heareresearch.blogspot.com/2014/10/10-30-2014-dual-y-axis-graph-ggplot2_30.html

# Additional packages needed
library(gtable)
library(grid)


#Pheno data as bars, temp as scatter
grid.newpage()
phenoPlot_2 <- ggplot(phe_1sp_2016, aes(date, n.y)) +
  geom_bar(stat="identity", na.rm = TRUE) +
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


tempPlot_dayMax_corr_2 <- ggplot() +
  geom_point(data = temp_day_fit, aes(sDate, dayMax),color="red") +
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



#Both pheno data and temp data as line graphs
grid.newpage()
phenoPlot_3 <- ggplot(phe_1sp_2016, aes(date, n.y)) +
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
  geom_line(data = temp_day_fit, aes(sDate, dayMax),color="red") +
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



