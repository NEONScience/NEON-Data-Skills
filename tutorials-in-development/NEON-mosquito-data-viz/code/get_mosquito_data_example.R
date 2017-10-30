# Clean starting environment
rm(list = ls())

# My working directory
if(file.exists('~/GitHub/mosquito-intern')){
  repo_location = '~/GitHub/mosquito-intern/code'
}
if(!exists('repo_location')){stop('Set the location of the neon_data repository.')}

# Functions to pull NEON data
source(paste(repo_location, 'get_NEON_data_by_productID.R', sep='/'))

# Pulls all data by DPID
# Requires: a known DPID, the folder location of the 'get_NEON_data_by_productID.R' script, andthe table names to pull
# Note: table names are pulled by grepl, so you just need enough of the name to get a unique table name

# Mosquito diversity data "DP1.10043.001"
# contains 6 tables: 'mos_trapping', 'mos_sorting', 'mos_expertTaxonomistIDProcessed', 'mos_expertTaxonomistIDRaw','mos_archivepooling', 'mos_barcoding'
mos = get_data_product(productID = "DP1.10043.001", 
                       df = c('mos_trapping', 'mos_sorting', 'mos_expertTaxonomistIDProcessed', 'mos_expertTaxonomistIDRaw','mos_archivepooling', 'mos_barcoding'))

# Rename table outputs for Charlotte's script
trap = mos$mos_trapping
sort = mos$mos_sorting
id = mos$mos_expertTaxonomistIDProcessed