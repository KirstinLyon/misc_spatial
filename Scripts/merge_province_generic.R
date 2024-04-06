library(sf)
library(janitor)
library(tidyverse)

PATH <-  "Data/provinces/MOz_Provinces.shp"
PROVINCES_TO_MERGE <- c("Maputo", "Maputo City")
NAME <-  "Maputo"
COUNTRY <- "Mozambique"
GID_0 <- "MOZ"
OUTPUT <- "Dataout/merged_province/"


#' Create merged province spatial file
#'
#' @param province_df original spatial file with all provinces
#' @param provinces  list of provinces to be merged
#'
#' @return a spatial file with provinces merged
#' @export
#'
#' @examples
merge_province <- function(province_df, provinces, name, country, gid_0){
    
    temp <- province_df %>% 
        filter(name_1 %in% provinces) %>% 
        sf::st_union()   #combines the provinces
    
    #creates a spatial object and adds geometry
    temp <- sf::st_sf(name_1 = name, geometry = temp) %>% 
        mutate(country = COUNTRY,
               gid_0 = GID_0)
    
    #removes the provinces that have been merged
    old_province <- province_df %>%
        filter(!name_1 %in% provinces)
    
    #combines the old provinces with the merged province
    temp <- bind_rows(old_province, temp)
    
    return(temp)
    
}


# Specify the path to the zip file
zip_file_path <- "Data_public/gadm41_MOZ_shp.zip"
# Specify the directory where you want to extract the contents
destination_dir <- "Data/Moz"

# Unzip the folder
unzip(zipfile = zip_file_path, exdir = destination_dir)

moz_example <- "Data/Moz/gadm41_MOZ_1.shp"


# Read in the shapefile containing the provinces of Mozambique
original_provinces <- st_read(moz_example) %>%
    sf::st_sf() %>% #creates a SF object 
    clean_names() 

plot(original_provinces)

new_provinces <- original_provinces %>% 
    merge_province(PROVINCES_TO_MERGE, NAME, COUNTRY, GID_0) 

#show merged provinces
    plot(new_provinces)

#write all spatial files
sf::write_sf(new_provinces, paste0(OUTPUT,"merged_province.shp"))
sf::st_write(new_provinces, paste0(OUTPUT,"merged_province.gpkg"))
sf::st_write(new_provinces, paste0(OUTPUT,"merged_province.geojson"))
