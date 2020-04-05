library(dplyr)
library(leaflet)

lon <- 48.955269
lat <- -84.741725

# https://data.ontario.ca/en/dataset/confirmed-positive-cases-of-covid-19-in-ontario
on_geojson <- rgdal::readOGR("json/conposcovidloc.geojson")

d <- on_geojson@data %>% 
  group_by(Reporting_PHU_City, Reporting_PHU_Latitude, Reporting_PHU_Longitude) %>% 
  summarise(case_count = n())

leaflet(on_geojson) %>% 
  addTiles() %>% 
  setView(lat, lon, zoom = 5) %>% 
  addCircleMarkers(
    d$Reporting_PHU_Longitude, 
    d$Reporting_PHU_Latitude, 
    d$case_count/mean(d$case_count), 
    popup = d$Reporting_PHU_City,
    fill=TRUE,
    fillOpacity = 0.5
    )
