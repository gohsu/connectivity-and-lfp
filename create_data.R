library(cancensus)
library(dplyr)
library(sf)
api_filename <- 'api_key.txt'
api_key <- readChar(api_filename, file.info(api_filename)$size)
options(cancensus.api_key = api_key)

# get gpkg of census tract CTs to send to chris for aggregation data
make_gpkg <- function(){
  all_cts <- get_census(dataset='CA16',
                        regions=list(C=c("01")),              # all of canada
                        geo_format='sf', level='CT')          # census tracts
  st_write(all_cts, "data/CA16_CTs_all.gpkg")
}


# get census data for CTs
get_ct_data <- function(){
  census_vars <- c("v_CA16_4958","v_CA16_4959","v_CA16_493","v_CA16_5613","v_CA16_5614","v_CA16_5619","v_CA16_5620","v_CA16_406","v_CA16_5052","v_CA16_5053","v_CA16_5778","v_CA16_5779","v_CA16_5814","v_CA16_5815","v_CA16_5793","v_CA16_5794") 
  
  census_cts <- get_census(dataset='CA16', 
                           regions=list(C=c("01")),              
                           vectors = census_vars,
                           geo_format=NA, level='CT')          
  
  write.csv(census_cts, "data/CA16_CTs_variables.csv")
}

sns_cts <- read.table(file = 'data/CA16_CTs_all.tsv', sep = '\t', header = TRUE)
census_cts <- read.table(file = 'data/CA16_CTs_variables.csv', header = TRUE)

colnames(census_cts)[1] <- 'geouid'
sns_cts$geouid <- as.character(sns_cts$geouid) # yikes??? 

census_cts %>% inner_join(sns_cts)  # BIG yieks around 2000 rows disappeared
