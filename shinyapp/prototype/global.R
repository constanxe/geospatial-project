# R Packages
packages = c('shiny', 'tidyverse', 'sp', 'sf', 'rgdal', 'spdep', 'tmap', 'DT')
for (p in packages){
  if(!require(p, character.only = T)){ 
    install.packages(p)
  }
  library(p,character.only = T) 
}

# Data Paths
dp_prefix_a = "../data/aspatial/" 
dp_prefix_g = "../data/geospatial" 

dp_a_sch = paste(dp_prefix_a, "general-information-of-schools.csv", sep="")
dp_a_hdb = paste(dp_prefix_a, "hdb-property-information.csv", sep="")
dp_a_zip = paste(dp_prefix_a, "sg_zipcode_mapper.csv", sep="")

# Data variables
data <- read.csv(dp_a_sch)
data <- read.csv(dp_a_hdb)
data <- read.csv(dp_a_zip)

sf_mpsz = st_read(dsn = dp_prefix_g, layer = "MP14_SUBZONE_WEB_PL")

mpsz <- as(sf_mpsz, "Spatial")
