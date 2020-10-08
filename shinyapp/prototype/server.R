packages = c('shiny', 'tidyverse')
for (p in packages){
    library(p, character.only = T)
}

data <- read.csv("../../data/aspatial/data.csv")


shinyServer(function(input, output) {

})
