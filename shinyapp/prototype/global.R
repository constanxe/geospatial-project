# R Packages
packages = c('shiny', 
             'shinydashboard', 
             'shinyWidgets', 
             'DT', 
             'leaflet',
             'tidyverse',
             'knitr',
             'stringr',
             'httr',
             'geojsonio', 
             'sp', 
             'dplyr', 
             'SpatialAcc', 
             'rgeos', 
             'spdplyr', 
             'KernSmooth', 
             'raster',
             'reshape2', 
             'sf',
             'rgdal',
             'spdep',
             'tmap'
             ) 

for (p in packages){
  if(!require(p, character.only = T)){ 
    install.packages(p)
  }
  library(p,character.only = T) 
}

memory.limit(size=56000)


# Data Paths

dp_g = "../data/geospatial" 
dp_a_prefix = "../data/aspatial/" 
dp_j_prefix = "../data/geojson/" 
dp_m_prefix = "../data/distancematrix/" 
dp_h_prefix = "../data/hansen/" 
dp_s_prefix = "../data/sam/" 

dp_a_jc = paste(dp_a_prefix, "jc.csv", sep="")
dp_a_hdb = paste(dp_a_prefix, "hdb-property-information.csv", sep="")
dp_a_zip = paste(dp_a_prefix, "sg_zipcode_mapper.csv", sep="")


# Data variables

jc_data <- read.csv(dp_a_jc)
hdb_data <- read.csv(dp_a_hdb)
zip_data <- read.csv(dp_a_zip)

# Data Wrangling

## Select

jc_data$POSTAL <- as.numeric(jc_data$POSTAL)
jc <- jc_data%>% 
  dplyr::select("SCHOOL"='SEARCHVAL', 'POSTAL', 'LATITUDE', 'LONGITUDE', 'X', 'Y', 'ROAD_NAME','ADDRESS')

hdb <- zip_data%>%
  dplyr::select('ADDRESS' = 'address', 'POSTAL'="postal", 'LATITUDE' = 'latitude', 'LONGITUDE' = 'longtitude', 'ROAD_NAME' = 'road_name')


## CRS

crsobj = CRS("+init=EPSG:3414")
coordinates(jc)<-~LONGITUDE+LATITUDE
proj4string(jc) = crsobj

coordinates(hdb)<-~LONGITUDE+LATITUDE
proj4string(hdb) = crsobj
