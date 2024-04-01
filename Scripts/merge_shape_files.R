library(tidyverse)
library(sf)


# Specify the path to the zip file
zip_file_path_eswatini <- "Data_public/gadm41_SWZ_shp.zip"
# Specify the directory where you want to extract the contents
destination_dir_eswatini <- "Data/eswatini"

# Unzip the folder
unzip(zipfile = zip_file_path_eswatini, exdir = destination_dir_eswatini)



eswatini_example <- "Data/eswatini/gadm41_SWZ_1.shp"


# Specify the path to the zip file
zip_file_path_sa <- "Data_public/gadm41_ZAF_shp.zip"
# Specify the directory where you want to extract the contents
destination_dir_sa <- "Data/sa"

# Unzip the folder
unzip(zipfile = zip_file_path_sa, exdir = destination_dir_sa)



sa_example <- "Data/sa/gadm41_ZAF_1.shp"


shapefile1 <- eswatini_example
shapefile2 <- sa_example


# Read the shapefiles
sf1 <- st_read(shapefile1)
sf2 <- st_read(shapefile2)

# Merge the shapefiles
merged_sf <- rbind(sf1, sf2)

# Write the merged shapefile to disk
merged_shapefile <- "Dataout/merged.shp"
st_write(merged_sf, dsn = merged_shapefile)

# Optionally, plot the merged shapefile
plot(merged_sf)


