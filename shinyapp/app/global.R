# R Packages (comment out at deployment)
packages = c("shiny",
             "shinydashboard",
             "shinyWidgets",
             "DT", 
             "leaflet",
             "tidyverse",
             "knitr",
             "sp", 
             "tmap",
             "sf",
             "ggstatsplot"
            )

for (p in packages){
    if(!require(p, character.only = T)){ 
        install.packages(p)
    }
    library(p, character.only = T) 
}

memory.limit(size=56000)

# Folder Paths
dp_a_prefix = "data/aspatial/" 
dp_j_prefix = "data/geojson/" 
dp_m_prefix = "data/distancematrix/" 
dp_h_prefix = "data/hansen/" 
dp_s_prefix = "data/sam/" 
dp_g_prefix = "data/geospatial" 

# Data Paths
dp_a_jc = paste(dp_a_prefix, "jc.csv", sep="")
dp_a_zip = paste(dp_a_prefix, "sg_zipcode_mapper.csv", sep="")

# Data variables
jc_data <- read.csv(dp_a_jc)
zip_data <- read.csv(dp_a_zip)
mpsz_data <- st_read(dp_g_prefix, layer = "MP14_SUBZONE_WEB_PL")

mpsz <- st_as_sf(mpsz_data, crs=3414, coords=c('X_ADDR', 'Y_ADDR'), sf_column_name="geometry")
mpsz <- st_transform(mpsz, 3414)

# Data Wrangling
jc_data$POSTAL <- as.numeric(jc_data$POSTAL)
jc <- jc_data
jc <- jc_data%>% 
    dplyr::select("SCHOOL"="SEARCHVAL", "POSTAL", "LATITUDE", "LONGITUDE", "X", "Y", "ROAD_NAME","ADDRESS")
jc$SCHOOL <- rapportools::tocamel(tolower(jc$SCHOOL), upper=TRUE, sep=" ")
jc$ADDRESS <- rapportools::tocamel(tolower(jc$ADDRESS), upper=TRUE, sep=" ")
jc$ROAD_NAME <- rapportools::tocamel(tolower(jc$ROAD_NAME), upper=TRUE, sep=" ")
jc_sf <- st_as_sf(jc, crs=3414, coords=c('X', 'Y'), sf_column_name="geometry")
jc_svy21 <- st_transform(jc_sf, 3414)

jc_mpsz <- st_join(jc_svy21, mpsz, join = st_intersects)

jc_mpsz$REGION_N <- sub(" REGION", "", jc_mpsz$REGION_N)

jc_mpsz <- jc_mpsz %>%
    dplyr::select("SCHOOL", 'POSTAL', 'LATITUDE', 'LONGITUDE', 'ROAD_NAME','ADDRESS', "REGION"='REGION_N')

jc <- jc_mpsz

jc$REGION <- rapportools::tocamel(tolower(jc$REGION), upper=TRUE, sep=" ")

hdb <- zip_data %>%
    dplyr::select("ADDRESS" = "address", "POSTAL"="postal", "LATITUDE" = "latitude", "LONGITUDE" = "longtitude", "ROAD_NAME" = "road_name")
hdb$ADDRESS <- rapportools::tocamel(tolower(hdb$ADDRESS), upper=TRUE, sep=" ")
hdb$ROAD_NAME <- rapportools::tocamel(tolower(hdb$ROAD_NAME), upper=TRUE, sep=" ")


# CRS
jc <- st_transform(jc, CRS("+init=epsg:3414"))
jc <- sf:::as_Spatial(jc)

coordinates(hdb) <-~ LONGITUDE + LATITUDE
proj4string(hdb) <- CRS("+proj=longlat +datum=WGS84")

p <- spTransform(hdb, CRS("+init=epsg:3414"))
hdb_df<- tbl_df(hdb)

#add x and y coordinates for hdb
coordinates_val<-coordinates(p)
colnames(hdb_df)[6] <- "X"
colnames(hdb_df)[7] <- "Y"
hdb_df$X <- coordinates_val[,1]
hdb_df$Y <- coordinates_val[,2]

hdb_df$ADDRESS <- rapportools::tocamel(tolower(hdb_df$ADDRESS), upper=TRUE, sep=" ")
hdb<-hdb_df


# UI
schIcon <- makeIcon(
    iconUrl = "schIcon.png",
    iconWidth = 20, iconHeight = 30,
    iconAnchorX = 10, iconAnchorY = 30,
)