# List of required packages
required_packages <- c("tidyverse", "sf")

# Check if packages are installed
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

# If any packages are missing, install them
if (length(missing_packages) > 0) {
    install.packages(missing_packages)
}

library(sf)
library(tidyverse)
library(glamr)

#setup standard filers/folders for OHA
glamr::si_setup()

# run if shapefiles are saved as a zip file
unzip("Data/districts.zip", exdir = "Data/")

shape_file <- "Data/districts/NEW_161_Districts.shp"
coordinate_file <- "Data/sisma_us_gis.xlsx"
output_folder <- "Dataout/"


#' Use the SF package to find the snu and psnu for each coordinate. Flag any psnu that have 
#' a different PSNU to expected.
#'
#' @param shape_file must be a .shp file
#' @param coordinate_file contains coordinates, psnuuid and snuuid for all sites
#'
#' @return a tibble with all sites and if they PSNU matches
#' @export
#'
#' @examples
check_coords_in_psnu <- function(shape_file, coordinate_file){
    
    # Read the shapefile containing district boundaries
    districts <- sf::st_read(shape_file) %>% 
        select(shape_snu     = Province, 
               shape_psnu    = District, 
               shape_snuuid  = SNU1Uid, 
               shape_psnuuid = PSN_Uuid,
               geometry)
    
    # Read the Excel file containing facility coordinates
    facilities_file <- readxl::read_xlsx(coordinate_file)
    
    # prepare the facilities data and remove any sites without longitude/latitude
    facilities <- facilities_file %>%
        select(sitename,longitude, latitude,organisationunitid,
               sisma_snuuid  = snuuid,
               sisma_psnuuid = psnuuid,
               sisma_snu     = orgunitlevel2,
               sisma_psnu    = orgunitlevel3) %>% 
        tidyr::drop_na()

    
    # Convert facilities dataframe to sf object 
    facilities_sf <- sf::st_as_sf(x = facilities, 
                                  coords = c("longitude", "latitude"), 
                                  crs = st_crs(districts)) 
    
    
    # Perform spatial join between districts and facilities and remove the geometry column
    district_info <- st_join(districts, facilities_sf) %>% 
        sf::st_drop_geometry()
    
    #add a flag to check if the psnu is as expected
    output_file <- district_info %>% 
        mutate(check_psnu = case_when(sisma_psnuuid == shape_psnuuid ~ 0,
                                      .default = 1)
        ) %>% 
        select(sitename, organisationunitid, check_psnu, 
               shape_snuuid, shape_snu, shape_psnuuid, shape_psnu,
               sisma_snuuid, sisma_snu, sisma_psnuuid, sisma_psnu)
    
    return(output_file)
}


all_data <- check_coords_in_psnu(shape_file, coordinate_file) %>% 
    write_excel_csv(glue::glue("{output_folder}all_data.csv"))

wrong_psnu <- all_data %>% 
    filter(check_psnu == 1) %>% 
    write_excel_csv(glue::glue("{output_folder}check_psnu_gis.csv"))



