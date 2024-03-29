library(sf)
library(janitor)
library(tidyverse)

PATH <-  "Data/provinces/MOz_Provinces.shp"
PROVINCES_TO_MERGE <- c("Maputo", "Cidade De Maputo")
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
merge_province <- function(province_df, provinces){
    
    temp <- province_df %>% 
        filter(provincia %in% provinces) %>% 
        sf::st_union()   #combines the provinces
    
    #creates a spatial object and adds geometry
    temp <- sf::st_sf(provincia = "Maputo", geometry = temp) %>% 
        mutate(shape_leng = st_length(.),
               shape_area = st_area(.),
               objectid_1 = "12"
        )
    
    #removes the provinces that have been merged
    old_province <- province_df %>%
        filter(!provincia %in% provinces)
    
    #combines the old provinces with the merged province
    temp <- rbind(old_province, temp)
    
    return(temp)
    
}

# Read in the shapefile containing the provinces of Mozambique
original_provinces <- st_read(PATH) %>%
    sf::st_sf() %>% #creates a SF object 
    clean_names() %>% 
    select(-c(snu1uid, supported))


new_provinces <- original_provinces %>% 
    merge_province(PROVINCES_TO_MERGE) %>% 
    mutate(provincia_other = recode(provincia, "Zambezia" = "Zambézia"))  #Zambezia can be spelt differently

#show merged provinces
    plot(new_provinces)

#write all spatial files
sf::write_sf(new_provinces, paste0(OUTPUT,"merged_province.shp"))
sf::st_write(new_provinces, paste0(OUTPUT,"merged_province.gpkg"))
sf::st_write(new_provinces, paste0(OUTPUT,"merged_province.geojson"))
