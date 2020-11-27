library(cancensus)
library(dplyr)
library(sf)
api_filename <- 'api_key.txt'
api_key <- readChar(api_filename, file.info(api_filename)$size)
options(cancensus.api_key = api_key)
all_cts <- get_census(dataset='CA16', 
           regions=list(C=c("01")),              # all of canada
           geo_format='sf', level='CT')          # census tracts
st_write(all_cts, "CA16_CTs_all.gpkg")