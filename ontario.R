library(dplyr)
library(leaflet)
library(purrr)
library(geonames)
options(geonamesUsername="nderraugh")

lon <- 48.955269
lat <- -84.741725

# https://data.ontario.ca/en/dataset/confirmed-positive-cases-of-covid-19-in-ontario
on_geojson <- rgdal::readOGR("https://data.ontario.ca/dataset/f4112442-bdc8-45d2-be3c-12efae72fb27/resource/4f39b02b-47fe-4e66-95b6-e6da879c6910/download/conposcovidloc.geojson") #"json/conposcovidloc.geojson")


library(readr)
cases <- read_csv("src/nderraugh/ontario_covid/cases.csv", skip = 3) %>% filter(province == "Ontario")

findPHU <- function(name) { 
  res <- GNsearch(name_equals = name, adminCode1 = "08", country = "CA")
  res %>% select(name, lat, lng)
}

phus <- cases %>% distinct(health_region, province)

i <- 4; findPHU(phus[i,1])

c("Algoma", 47.833092, -83.640780)

for(i in 1:nrow(phus)) {
  print(findPHU(phus[i,1], phus[i,2]))
}
"Algoma"
  #findPHU(row$health_region, row$province)



# https://data.ontario.ca/en/dataset/confirmed-positive-cases-of-covid-19-in-ontario/resource/455fd63b-603d-4608-8216-7d8647f43350

d <- on_geojson@data 

leaflet(on_geojson) %>% 
  addTiles() %>% 
  setView(lat, lon, zoom = 5) %>% 
  addCircleMarkers(
    d$Reporting_PHU_Longitude, 
    d$Reporting_PHU_Latitude, 
    popup = d$Reporting_PHU_City,
    fill=TRUE,
    fillOpacity = 0.5,
    stroke = 0,
    clusterOptions = markerClusterOptions(spiderfyOnMaxZoom=F)
    )
