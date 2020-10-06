## ----set-up-env, eval=F------------------------------------------------------------------------------------
## # Install neonUtilities package if you have not yet.
## install.packages("neonUtilities")
## install.packages("ggplot2")
## install.packages("dplyr")
## install.packages("padr")


## ----load-packages-----------------------------------------------------------------------------------------
# Set global option to NOT convert all character variables to factors
options(stringsAsFactors=F)

# Load required packages
library(neonUtilities)
library(ggplot2)
library(dplyr)
library(padr)


## ----download-data-waq, results='hide'---------------------------------------------------------------------
# download data of interest - Water Quality
waq <- loadByProduct(dpID="DP1.20288.001", site="PRIN", 
                     startdate="2020-02", enddate="2020-02", 
                     package="expanded", 
                     token = Sys.getenv("NEON_TOKEN"),
                     check.size = F)



## ----download-data-nsw, results='hide'---------------------------------------------------------------------
# download data of interest - Nitrate in Suface Water
nsw <-  loadByProduct(dpID="DP1.20033.001", site="PRIN", 
                      startdate="2020-02", enddate="2020-02", 
                      package="expanded", 
                      token = Sys.getenv("NEON_TOKEN"),
                      check.size = F)

# #1. 2.0 MiB
# #2. You can change check.size to True (T), and compare "basic" vs "expaneded"
# package types. The basic package is 37.0 KiB, and the expanded is 42.4 KiB. 



## ----download-data-eos, results='hide'---------------------------------------------------------------------
# download data of interest - Elevation of surface water
eos <- loadByProduct(dpID="DP1.20016.001", site="PRIN",
                     startdate="2020-02", enddate="2020-02",
                     package="expanded",
                     token = Sys.getenv("NEON_TOKEN"),
                     check.size = F)





## ----loadBy-list-------------------------------------------------------------------------------------------
# view all components of the list
names(waq)

# View the dataFrame
View(waq$waq_instantaneous)



## ----unlist-vars-------------------------------------------------------------------------------------------
# unlist the variables and add to the global environment
list2env(waq, .GlobalEnv)


## ----unlist-remainder--------------------------------------------------------------------------------------
list2env(nsw, .GlobalEnv)
list2env(eos, .GlobalEnv)


## ----waq-hor-num-locations---------------------------------------------------------------------------------
# which sensor locations exist for water quality, DP1.20288.001?
print("Water quality horizontal positions:")
unique(waq_instantaneous$horizontalPosition)


## ----all-hor-num-locations---------------------------------------------------------------------------------
# which sensor locations exist for other data products?
print("Nitrate in Surface Water horizontal positions: ")
unique(NSW_15_minute$horizontalPosition)

print("Elevation of Surface Water horizontal positions: ")
unique(EOS_30_min$horizontalPosition)


## ----split-hor---------------------------------------------------------------------------------------------
# Split data into separate dataframes by upstream/downstream locations.

waq_up <- 
  waq_instantaneous[(waq_instantaneous$horizontalPosition=="101"),]
waq_down <- 
  waq_instantaneous[(waq_instantaneous$horizontalPosition=="102"),]

# Note: The surface water nitrate sensor is only stationed at one location.

eos_up <- EOS_30_min[(EOS_30_min$horizontalPosition=="110"),]
eos_down <- EOS_30_min[(EOS_30_min$horizontalPosition=="132"),]


## ----column-names------------------------------------------------------------------------------------------
# One option is to view column names in the data frame
colnames(waq_instantaneous)

# Alternatively, view the variables object corresponding to the data product for more information
View(variables_20288)


## ----plot-wqual--------------------------------------------------------------------------------------------
# plot
wqual <- ggplot() +
	geom_line(data = waq_up, 
	          aes(endDateTime, dissolvedOxygen,color="a"), 
	          na.rm=TRUE ) +
	geom_line(data = waq_down, 
	          aes(endDateTime, dissolvedOxygen, color="b"), 
	          na.rm=TRUE) +
	geom_line(na.rm = TRUE) +
	ylim(0, 20) + ylab("Dissolved Oxygen (mg/L)") +
	xlab(" ") +
  scale_color_manual(values = c("blue","red"),
                     labels = c("upstream","downstream")) +
  labs(colour = "") + # Remove legend title
  theme(legend.position = "top") +
  ggtitle("PRIN Upstream and Downstream DO")
  
  

wqual



## ----plot-fdom-ucert---------------------------------------------------------------------------------------
# plot
fdomUcert <- ggplot() +
	geom_line(data = waq_down, 
	          aes(endDateTime, fDOM), 
	          na.rm=TRUE, color="orange") +
  geom_ribbon(data=waq_down, 
              aes(x=endDateTime, 
                  ymin = (fDOM - fDOMExpUncert), 
                  ymax = (fDOM + fDOMExpUncert)), 
              alpha = 0.4, fill = "grey75") +
	geom_line( na.rm = TRUE) +
	ylim(0, 200) + ylab("fDOM (QSU)") +
	xlab(" ") +
  ggtitle("PRIN Downstream fDOM with Expected Uncertainty Bounds") 

fdomUcert



## ----challenge-explore-nsw, results='hide'-----------------------------------------------------------------
# recall dataframes created in list2env() command, including NSW_15_minute

# which sensor locations?
unique(NSW_15_minute$horizontalPosition)

# what is the column name of the data stream of interest?
names(NSW_15_minute)


## ----challenge-plot-nsw------------------------------------------------------------------------------------
# plot
plot_NSW <- ggplot(data = NSW_15_minute,
                   aes(endDateTime, surfWaterNitrateMean)) +
                   geom_line(na.rm=TRUE, color="blue") + 
                   ylab("NO3-N (uM)") + xlab(" ") +
                   ggtitle("PRIN Downstream Nitrate in Surface Water")

plot_NSW



## ----view-qf-----------------------------------------------------------------------------------------------
waq_qf_names <- names(waq_down)[grep("QF", names(waq_down))]

print(paste0("Total columns in DP1.20288.001 expanded package = ", 
             as.character(length(waq_qf_names))))

# water quality has 96 data columns with QF in the name, 
# so let's just look at those corresponding to fDOM
print("fDOM columns in DP1.20288.001 expanded package:")
print(waq_qf_names[grep("fDOM", waq_qf_names)])



## ----view-qf-fdom------------------------------------------------------------------------------------------
waq_qf_names <- names(waq_down)[grep("QF", names(waq_down))]

print(paste0("Total QF columns: ",length(waq_qf_names)))

# water quality has 96 data columns with QF in the name, 
# so let us just look at those corresponding to fDOM
fdom_qf_names <- waq_qf_names[grep("fDOM",waq_qf_names)]

for(col_nam in fdom_qf_names){
  print(paste0(col_nam, " unique values: ", 
               paste0(unique(waq_down[,col_nam]), 
                      collapse = ", ")))
}



## ----view-variables-waq, echo =TRUE------------------------------------------------------------------------
print(variables_20288$description[which(variables_20288$fieldName == "fDOMAbsQF")])


## ----dig-into-qf, echo=TRUE--------------------------------------------------------------------------------
# Loop across the fDOM QF column names. 
#  Within each column, count the number of rows that equal '1'.
print("FLAG TEST - COUNT")
for (col_nam in fdom_qf_names){
  totl_qf_in_col <- length(which(waq_down[,col_nam] == 1))
  print(paste0(col_nam,": ",totl_qf_in_col))
}

# Let's also check out how many fDOMAbsQF = 2 exist
print(paste0("fDOMAbsQF = 2: ",
             length(which(waq_down[,"fDOMAbsQF"] == 2))))

print(paste0("Total fDOM observations: ", nrow(waq_down) ))


## ----check-vars--------------------------------------------------------------------------------------------
print(variables_20288[which(variables_20288$fieldName == "fDOMAbsQF"),])


## ----omit-finalqf------------------------------------------------------------------------------------------
# Map QF label names for the plot for the fDOMFinalQF grouping
group_labels <- c("fDOMFinalQF = 0", "fDOMFinalQF = 1")
names(group_labels) <- c("0","1")

# Plot fDOM data, grouping by the fDOMFinalQF value
ggplot2::ggplot(data = waq_down, 
                aes(x = endDateTime, y = fDOM, group = fDOMFinalQF)) +
  ggplot2::geom_step() +
  facet_grid(fDOMFinalQF ~ ., 
             labeller = labeller(fDOMFinalQF = group_labels)) +
  ggplot2::ggtitle("PRIN Sensor Set 102 fDOM final QF comparison")



## ----check-fdom-qf-----------------------------------------------------------------------------------------
# Find row indices around February 22:
idxs_Feb22 <- base::which(waq_down$endDateTime > as.POSIXct("2020-02-22"))[1:1440]

print("FLAG TEST - COUNT")
for (col_nam in fdom_qf_names){
  totl_qf_in_col <- length(which(waq_down[idxs_Feb22,col_nam] == 1))
  print(paste0(col_nam,": ",totl_qf_in_col))
}



## ----view-absQF--------------------------------------------------------------------------------------------
ggplot2::ggplot(data = waq_down, 
                aes(x = endDateTime, y = fDOM, group = fDOMAbsQF)) +
  ggplot2::geom_step() +
  facet_grid(fDOMAbsQF ~ .) +
  ggplot2::ggtitle("PRIN Sensor Set 102 fDOMAbsQF comparison")


## ----look-at-n03-again-------------------------------------------------------------------------------------
plot_NSW


## ----ignore-absQF------------------------------------------------------------------------------------------
# Remove the absorbance and aggregated quality flag tests from list of fDOM QF tests:
fdom_qf_non_abs_names <- fdom_qf_names[which(!fdom_qf_names %in% c("fDOMAlphaQF","fDOMBetaQF","fDOMAbsQF","fDOMFinalQF"))]

# Create a custom quality flag column as the maximum QF value within each row
waq_down$aggr_non_abs_QF <- apply( waq_down[,fdom_qf_non_abs_names],1,max, na.rm = TRUE)
# The 'apply' function above allows us avoid a for-loop and more efficiently 
#  iterate over each row.

# Plot fDOM data, grouping by the custom quality flag column's value
ggplot2::ggplot(data = waq_down, 
                aes(x = endDateTime, y = fDOM, 
                    group = aggr_non_abs_QF)) +
  ggplot2::geom_step() +
  facet_grid(aggr_non_abs_QF ~ .) +
  ggplot2::ggtitle("PRIN Sensor Set 102 fDOM custom QF aggregation")



## ----aggregate-waq-prep------------------------------------------------------------------------------------
# Recall we already created the downstream object for water quality, waq_down

# We first need to name each data stream within water quality. 
# One trick is to find all the variable names by searching for "BetaQF"
waq_strm_betaqf_cols <- names(waq_down)[grep("BetaQF",names(waq_down))]
print(paste0("BetaQF column names: ",
             paste0(waq_strm_betaqf_cols, collapse = ", ")))

# Now let's remove the BetaQF from the column name:
waq_strm_cols <- base::gsub("BetaQF","",waq_strm_betaqf_cols)
# To keep column names short, some variable names had to be shortened
# when appending "BetaQF", so let's add "uration" to "dissolvedOxygenSat"
waq_strm_cols <- base::gsub("dissolvedOxygenSat",
                            "dissolvedOxygenSaturation",waq_strm_cols)
print(paste0("Water quality sensor data stream names: ", 
             paste0(waq_strm_cols, collapse = ", ")))

# We will also aggregate the final quality flags:
waq_final_qf_cols <- names(waq_down)[grep("FinalQF",names(waq_down))]

# Let's check to make sure our time column is in POSIXct format, which is 
# needed if you download and read-in NEON data files without using the 
# neonUtilities package.
if("POSIXct" %in% class(waq_down$endDateTime)){
  print("Time column in waq_down is appropriately in POSIXct format")
} else {
  print("Converting waq_down endDateTime column to POSIXct")
  waq_down$endDateTime <- as.POSIXct(waq_down$endDateTime, tz = "UTC")
}



## ----aggr-waq-padr-----------------------------------------------------------------------------------------
# Aggregate water quality data columns to 30 minute intervals, 
# taking the mean of non-NA values within each 30-minute period. 
# We explain each step in the dplyr piping operation in code 
# comments:

waq_30min_down <- waq_down %>% 
              # pass the downstream data frame to the next function
              # padr's thicken function adds a new column, roundedTime, 
              # that shows the closest 30 min timestamp to
              # to a given observation in time
  
              padr::thicken(interval = "30 min",
                            by = "endDateTime",
                            colname = "roundedTime",
                            rounding = "down") %>%
              # In 1-min data, there should now be sets of 30 
              # corresponding to each 30-minute roundedTime
              # We use dplyr to group data by unique roundedTime 
              # values, and summarise each 30-min group
              # by the the mean, for all data columns provided 
              # in waq_strm_cols and waq_final_qf_cols
  
              dplyr::group_by(roundedTime) %>% 
                dplyr::summarise_at(vars(dplyr::all_of(c(waq_strm_cols, 
                                                  waq_final_qf_cols))), 
                                    mean, na.rm = TRUE)

# Rather than binary values, quality flags are more like "quality 
# metrics", defining the fraction of data flagged within an 
# aggregation interval.



## ----combine-nsw-waq---------------------------------------------------------------------------------------
# We have to specify the matching column from each dataframe
all_30min_data_down <- base::merge(x = waq_30min_down, 
                                   y = eos_down, 
                                   by.x = "roundedTime", 
                                   by.y = "endDateTime")

# Let's take a peek at the combined data frame's column names:
colnames(all_30min_data_down)



## ----plot-eos-waq------------------------------------------------------------------------------------------

ggplot(data = all_30min_data_down, 
       aes(x = surfacewaterElevMean, y = specificConductance)) +
  geom_point() + 
  ggtitle("PRIN specific conductance vs. surface water elevation") + 
  xlab("Elevation [m ASL]") + 
  ylab("Specific conductance [uS/cm]")

