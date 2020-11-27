# R Packages
packages = c('shiny', 
             'shinydashboard', 
             'shinyWidgets', 
             'DT', 
             'leaflet',
             'tidyverse',
             'knitr',
             'sp', 
             'tmap'
            )

for (p in packages){
    if(!require(p, character.only = T)){ 
        install.packages(p)
    }
    library(p,character.only = T) 
}

memory.limit(size=56000)

# Folder Paths
dp_a_prefix = "../data/aspatial/" 
dp_j_prefix = "../data/geojson/" 
dp_m_prefix = "../data/distancematrix/" 
dp_h_prefix = "../data/hansen/" 
dp_s_prefix = "../data/sam/" 

# Data Paths
dp_a_jc = paste(dp_a_prefix, "jc.csv", sep="")
dp_a_zip = paste(dp_a_prefix, "sg_zipcode_mapper.csv", sep="")

# Data variables
jc_data <- read.csv(dp_a_jc)
zip_data <- read.csv(dp_a_zip)

# Data Wrangling
jc_data$POSTAL <- as.numeric(jc_data$POSTAL)
jc <- jc_data%>% 
    dplyr::select("SCHOOL"='SEARCHVAL', 'POSTAL', 'LATITUDE', 'LONGITUDE', 'X', 'Y', 'ROAD_NAME','ADDRESS', 'REGION')
jc$SCHOOL <- rapportools::tocamel(tolower(jc$SCHOOL), upper=TRUE, sep=" ")
jc$ADDRESS <- rapportools::tocamel(tolower(jc$ADDRESS), upper=TRUE, sep=" ")
jc$ROAD_NAME <- rapportools::tocamel(tolower(jc$ROAD_NAME), upper=TRUE, sep=" ")
jc$REGION <- rapportools::tocamel(tolower(jc$REGION), upper=TRUE, sep=" ")

hdb <- zip_data %>%
    dplyr::select('ADDRESS' = 'address', 'POSTAL'="postal", 'LATITUDE' = 'latitude', 'LONGITUDE' = 'longtitude', 'ROAD_NAME' = 'road_name')
hdb$ADDRESS <- rapportools::tocamel(tolower(hdb$ADDRESS), upper=TRUE, sep=" ")
hdb$ROAD_NAME <- rapportools::tocamel(tolower(hdb$ROAD_NAME), upper=TRUE, sep=" ")


# CRS
crsobj = CRS("+init=EPSG:3414")

coordinates(jc)<-~LONGITUDE+LATITUDE
proj4string(jc) = crsobj

coordinates(hdb)<-~LONGITUDE+LATITUDE
proj4string(hdb) = crsobj


# UI
schIcon <- makeIcon(
    iconUrl = "schIcon.png",
    iconWidth = 20, iconHeight = 30,
    iconAnchorX = 10, iconAnchorY = 30,
)