library(sf)
library(janitor)
library(tidyverse)



PATH = "Data/provinces/MOz_Provinces.shp"



# Read in the shapefile containing the provinces of Mozambique
provinces <- st_read(PATH) %>%
    st_sf() %>%
    clean_names() %>% 
    select(-c(snu1uid, supported)) %>% 
    mutate(provincia = recode(provincia, "Zambezia" = "Zambézia"))

# Visualize the provinces to identify the ones you want to merge
plot(provinces)

# Select the provinces you want to merge
province_to_merge <- provinces %>%
    filter(provincia %in% c("Maputo", "Cidade De Maputo"))

# Merge the selected provinces
merged_province <- st_union(province_to_merge)
# Convert merged province to sf object with the same structure as provinces
merged_province_sf <- st_sf(provincia = "Maputo", geometry = merged_province) 

#merged_province_sf$shape_leng <- st_length(merged_province_sf)
#merged_province_sf$shape_area <- st_area(merged_province_sf$geometry)
# Get the shape lengths of the original provinces
shape_leng_province1 <- filter(province_to_merge, provincia == "Maputo")$shape_leng
shape_leng_province2 <- filter(province_to_merge, provincia == "Cidade De Maputo")$shape_leng


# Calculate the total length of the merged geometry
total_length_merged <- shape_leng_province1 + shape_leng_province2

# Update the merged province with the total length
merged_province_sf$shape_leng <- total_length_merged


#------
shape_area_province1 <- filter(province_to_merge, provincia == "Maputo")$shape_area
shape_area_province2 <- filter(province_to_merge, provincia == "Cidade De Maputo")$shape_area


# Calculate the total length of the merged geometry
total_area_merged <- shape_area_province1 + shape_area_province2

# Update the merged province with the total length
merged_province_sf$shape_area <- total_area_merged
merged_province_sf$shape_area <- round(merged_province_sf$shape_area, 1)


merged_province_sf = merged_province_sf %>% 
    mutate(objectid_1 = "12")


# Remove the original provinces from the dataset
provinces <- provinces %>%
    filter(!provincia %in% c("Maputo", "Cidade De Maputo"))


# Add the merged province back to the dataset
provinces <- rbind(provinces, merged_province_sf)


# Plot the updated dataset
plot(provinces)

sf::write_sf(provinces, "Dataout/provinces.shp")


#-------------teste





