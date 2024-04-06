library(tidyverse)
library(sf)


#PATH-------------------------------

INPUT_PATH <- "Data_public/"
OUTPUT_PATH <- "Dataout/temp/"

#unzip all files
zip_files <- list.files(INPUT_PATH, pattern = "\\.zip$", full.names = TRUE) %>% 
    map(unzip, exdir = OUTPUT_PATH)

#Read in all .shp files and merge
shapefiles <- list.files(OUTPUT_PATH, pattern = "\\.shp$", full.names = TRUE)
sf_list <- map(shapefiles, st_read)

# Merge the sf objects into a single sf object
merged_sf <- bind_rows(sf_list)

st_write(merged_sf, dsn = "Dataout/merged_SADC.shp")
plot(merged_sf)