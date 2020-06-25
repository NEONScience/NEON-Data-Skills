library(downloader)
library(httr)
library(jsonlite)
library(dplyr)

add_woody_tree_data <- function(in_data, site){
  
  SERVER <- 'http://data.neonscience.org/api/v0/'
  PRODUCTCODE <- 'DP1.10098.001'
  
  
  
  DATE <- get_most_recent_date(SITECODE = site, PRODUCTCODE = PRODUCTCODE)
  
  list2Env(loadByProduct(dpID=PRODUCTCODE, site=site, package="basic", check.size = F), .GlobalEnv)
  
  
  
  
  #ADD GENUs COUNTS#

  in_data$genus_count <- NA
  
  
  for(i in 1:nrow(DF)){
    
    #Extract plot id
    plot_id <- DF[i,'plotID']
    
    #IF mapping and tagging has entries for that plot
    if((plot_id %in% vst_mappingandtagging$plotID)){

      
      maptag <- vst_mappingandtagging[vst_mappingandtagging$plotID == plot_id,]
      
      #THEN Get all unique sicentific names at plot, and prepare empty vector
      scientific <- unique(maptag$scientificName)
      genus <- rep('', length(scientific))
      
      #Split scientific names
      scientific <- strsplit(scientific, ' ')
      
      for(j in 1:length(genus)){
        genus[j] <- scientific[[j]][[1]]
      }
      
      #Filter out repeated and unknown genera
      genus <- unique(genus)
      genus <- genus[genus != 'Unknown']
      
      #Record genera counts
      DF[i,'genus_count'] <- length(genus)
    }
  }

  
  
  
  
  
  
  #ADD TREE PARAMETERS#
  
  
  
  #  Add empty columns
  DF$wood_plants.count <- NA
  DF$trees.count <- NA
  DF$tree_to_woody_plant.ratio <- NA
  DF$tree.mean_height <- NA
  DF$tree.max_measured_height <- NA
  
  
  
  for(i in 1:nrow(DF)){
    
    
    #IF there are entries in the apparent Individual dataframe with same plotID as current row
    if(DF[i, 'plotID'] %in% unique(vst_apparentindividual$plotID)){
      #THEN:
      
      #Filter apparentIndividual dataframe to rows matching plot ID
      in_plants <- vst_apparentindividual[vst_apparentindividual$plotID == in_data[i,'plotID'],]
      
      #Remove dead individuals
      in_plants <- in_plants[in_plants$plantStatus == 'Live',]
      
      #Extract rows measuring trees
      in_trees <- in_plants[which(in_plants$growthForm %in% c('small tree','sapling','single-bole tree', 'multi-bole tree')),]
      
      #Calculate metrics
      in_data[i, 'wood_plants.count'] <- nrow(in_plants)
      in_data[i,'trees.count'] <- nrow(in_trees)
      in_data[i,'tree_to_woody_plant.ratio'] <- round(DF[i, 'trees.count']/DF[i,'wood_plants.count'], 2)
      in_data[i, 'tree.mean_height'] <- round(mean(in_trees$height, na.rm = T), 2)
      in_data[i, 'tree.max_measured_height'] <- max(in_trees$height, na.rm = T)
      
      
      
    }
  } 
  
  return(DF)
}

