library(cancensus)
library(dplyr)
library(sf)
api_filename <- 'api_key.txt'
api_key <- readChar(api_filename, file.info(api_filename)$size)
options(cancensus.api_key = api_key)

# get census data for CTs
census_vars <- c("v_CA16_425",  # Average household size
                 "v_CA16_504",  # total no. of private households
                 "v_CA16_507",  # no. of census families in private households with children
                 "v_CA16_2397", # Median total income of households in 2015 ($)
                 "v_CA16_4855", # Average number of rooms per dwelling
                 "v_CA16_5613", # LFP; male
                 "v_CA16_5614", # LFP; female
                 "v_CA16_5792", # commuting mode: total no. respondents
                 "v_CA16_5796", # commuting mode: car as driver; male
                 "v_CA16_5797", # commuting mode: car as driver; female
                 "v_CA16_5799", # commuting mode: car as passenger; male
                 "v_CA16_5800", # commuting mode: car as passenger; female
                 "v_CA16_5802", # commuting mode: public transit; male
                 "v_CA16_5803", # commuting mode: public transit; female
                 "v_CA16_5805", # commuting mode: walk; male
                 "v_CA16_5806", # commuting mode: walk; female
                 "v_CA16_5813", # commuting duration: total no. respondents
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
                         geo_format='sf', level='CT')  
colnames(census_cts) <- tolower(colnames(census_cts))
colnames(census_cts) <- gsub(" ", "_", colnames(census_cts))
colnames(census_cts)[13] <- c('area_km_sq')
colnames(census_cts)[14:40] <- c("avg_hh_size", 
                                 "hh_total",
                                 "hh_with_children",
                                 "med_hh_income_1000",
                                 "avg_rooms_per_dwelling",
                                 "lfp_male",
                                 "lfp_female",
                                 "commute_mode_all",
                                 "commute_driver_male",
                                 "commute_driver_female",
                                 "commute_passenger_male",
                                 "commute_passenger_female",
                                 "commute_publictransit_male",
                                 "commute_publictransit_female",
                                 "commute_walk_male",
                                 "commute_walk_female",
                                 "commute_time_all",
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
census_cts$med_hh_income_1000 <- census_cts$med_hh_income_1000 / 1000

census_cts_nogeom <- st_set_geometry(census_cts, NULL) 
write.csv(census_cts_nogeom, "data/CA16_CTs_cancensus.csv")
st_write(census_cts, "data/CA16_CTs_cancensus.gpkg", driver="GPKG", append=FALSE)

sns_cts <- read.table(file = 'data/CA16_CTs_sns.tsv', sep = '\t', header = TRUE)
sns_cts <- sns_cts[c("geouid", "degree_stock", "fraction_deadend_stock", "fraction_1_3_stock", 
                     "pca1_stock", "distanceratio_500_1000_stock", "length_m_stock", "n_nodes_stock")]

census_cts$geouid <- as.numeric(census_cts$geouid)
combined_data <- merge(census_cts, sns_cts, by='geouid')
combined_data <- na.omit(combined_data)
st_write(combined_data, "data/CA16_CTs_all.gpkg", driver="GPKG", append=FALSE)
