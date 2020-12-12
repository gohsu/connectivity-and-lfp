library(cancensus)
clibrary(dplyr)
library(sf)
api_filename <- 'api_key.txt'
api_key <- readChar(api_filename, file.info(api_filename)$size)
options(cancensus.api_key = api_key)

# get gpkg of census tract CTs to send to chris for aggregation data
make_gpkg <- function(){
  all_cts <- get_census(dataset='CA16',
                        regions=list(C=c("01")),              # all of canada
                        geo_format='sf', level='CT')          # census tracts
  st_write(all_cts, "data/CA16_CTs_geometries.gpkg")
}

# get census data for CTs
get_ct_data <- function(){
  census_vars <- c("v_CA16_425",  # Average household size
                   "v_CA16_497",  # Lone-parent census families in private households with children 
                   "v_CA16_493",  # couple census families in private households with children
                   "v_CA16_2397", # Median total income of households in 2015 ($)
                   "v_CA16_4855", # Average number of rooms per dwelling
                   "v_CA16_5614", # LFP; female
                   "v_CA16_5796", # commuting mode: car as driver; male
                   "v_CA16_5797", # commuting mode: car as driver; female
                   "v_CA16_5802", # commuting mode: public transit; male
                   "v_CA16_5803", # commuting mode: public transit; female
                   "v_CA16_5805", # commuting mode: walk; male
                   "v_CA16_5806", # commuting mode: walk; female
                   "v_CA16_5808", # commuting mode: bicycle; male
                   "v_CA16_5809", # commuting mode: bicycle; female
                   "v_CA16_5817", # commuting duration: < 15 min; male
                   "v_CA16_5818", # commuting duration: < 15 min; female
                   "v_CA16_5820", # commuting duration: 15-29 min; male
                   "v_CA16_5821", # commuting duration: 15-29 min; female
                   "v_CA16_5823", # commuting duration: 30-44 min; male
                   "v_CA16_5824", # commuting duration: 30-44 min; female
                   "v_CA16_5826", # commuting duration: 45-59 min; male
                   "v_CA16_5827", # commuting duration: 45-59 min; female
                   "v_CA16_5829", # commuting duration: >60 min; male
                   "v_CA16_5830" # commuting duration: >60 min; female
                   ) 
  
  census_cts <- get_census(dataset='CA16', 
                           regions=list(C=c("01")),              
                           vectors = census_vars,
                           geo_format=NA, level='CT')  
  colnames(census_cts) <- tolower(colnames(census_cts))
  colnames(census_cts)[3:4] <- c('region_name', 'area')
  colnames(census_cts)[12:35] <- c("avg_hh_size", 
                                   "hh_with_children_single_parents",
                                   "hh_with_children_couples",
                                   "med_hh_income",
                                   "avg_rooms_per_dwelling",
                                   "lfp_female",
                                   "commute_car_male",
                                   "commute_car_female",
                                   "commute_publictransit_male",
                                   "commute_publictransit_female",
                                   "commute_walk_male",
                                   "commute_walk_female",
                                   "commute_bicycle_male",
                                   "commute_bicycle_female",
                                   "commute_time_lt15_male",
                                   "commute_time_lt15_female",
                                   "commute_time_15to29_male",
                                   "commute_time_15to29_female",
                                   "commute_time_30to44_male",
                                   "commute_time_30to44_female",
                                   "commute_time_45to59_male",
                                   "commute_time_45to59_female",
                                   "commute_time_gt60_male",
                                   "commute_time_gt60_female"
                                   )
  write.csv(census_cts, "data/CA16_CTs_cancensus.csv")
}

# merge sns and census data
make_combined_data <- function(){
  sns_cts <- read.table(file = 'data/CA16_CTs_sns.tsv', sep = '\t', header = TRUE)
  sns_cts <- sns_cts[c("geouid", "degree_stock", "fraction_deadend_stock", "fraction_1_3_stock", 
                       "pca1_stock", "distanceratio_500_1000_stock", "length_m_stock", "n_nodes_stock")]
  census_cts <- read.csv(file = 'data/CA16_CTs_cancensus.csv')
  census_cts$X <- NULL
  sns_cts$geouid <- as.numeric(sns_cts$geouid) 
  combined_data <- merge(census_cts, sns_cts, by='geouid')
  write.csv(combined_data, "data/CA16_CTs_all.csv")
}
