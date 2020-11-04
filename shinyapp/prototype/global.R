# R Packages
packages = c('shiny', 'tidyverse', 'sf', 'rgdal', 'spdep', 'tmap', 'DT')
for (p in packages){
  if(!require(p, character.only = T)){ 
    install.packages(p)
  }
  library(p,character.only = T) 
}

# Data Paths
dp_prefix = "../../data/"
dp_prefix_a = dp_prefix + "aspatial/" 
dp_prefix_g = dp_prefix + "geopatial/" 

dp_a_sch = dp_prefix_a + "general-information-of-schools.csv"
dp_a_hdb = dp_prefix_a + "hdb-property-information.csv"

dp_g_mpsz = dp_prefix_g + "MP14_SUBZONE_WEB_PL.shp"
dp_g_co = dp_prefix_g + "CoastalOutline.shp"


# Data variables
data <- read.csv(dp_a_sch)
data <- read.csv(dp_a_hdb)

sf_mpsz = st_read(dp_g_mpsz)
sf_mpsz = st_read(dp_g_co)

