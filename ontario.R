library(plyr)
library(dplyr)
library(leaflet)
library(RCurl)
library(RJSONIO)
library(purrr)
library(readr)

lon <- 56.130366
lat <- -106.346771

cases <- read_csv("src/nderraugh/ontario_covid/cases.csv", skip = 3)

phus <- cases %>% distinct(health_region, province)

url <- function(address, return.call = "json", sensor = "false") {
  root <- "https://maps.googleapis.com/maps/api/geocode/"
  u <- paste(root, return.call, "?address=", address, "&sensor=", sensor, "&key=", Sys.getenv("GOOGLE_MAPS_API_KEY"),  sep = "")
  return(URLencode(u))
}

geoCode <- function(address, verbose=FALSE) {
  if(verbose) cat(address,"\n")
  u <- url(address)
  print(u)
  doc <- getURL(u)
  x <- fromJSON(doc,simplify = FALSE)
  #print(x$status)
  if(x$status=="OK") {
    lat <- x$results[[1]]$geometry$location$lat
    lng <- x$results[[1]]$geometry$location$lng
    location_type <- x$results[[1]]$geometry$location_type
    formatted_address <- x$results[[1]]$formatted_address
    return(c(lat=lat, lon=lng, loc_type=location_type, address=formatted_address))
  } else {
    return(c(NA,NA,NA, NA))
  }
}

f <- function(a, b) {
  c(health_region=a, 
    province=b, 
    geoCode(paste(a, b, "Canada", sep=",")), T)
}

phus_lat_lon <- ldply(map2(phus$health_region, phus$province, f))

d <- inner_join(cases, phus_lat_lon) %>% mutate(lat = as.numeric(lat), lon=as.numeric(lon))

leaflet() %>% 
  addTiles() %>% 
  setView(lat, lon, zoom = 4) %>% 
  addCircleMarkers(
    d$lon, 
    d$lat, 
    popup = d$health_region,
    fill=TRUE,
    fillOpacity = 0.5,
    stroke = 0,
    clusterOptions = markerClusterOptions(spiderfyOnMaxZoom=F)
  )
