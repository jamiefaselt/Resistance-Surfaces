# Ag Val/Acre for Con US
# URL=https://quickstats.nass.usda.gov/results/387739E0-1063-314E-B616-B74D15FA1D32

library(tigris)
library(ggplot2)
library(tidyverse)
library(sf)
library(sp)
library(raster)
library(dplyr)
library(rgdal)
library(ggmap)
library(usmap)
library(fasterize)

#this is a projection I'm using from the wildlife pref repo
albers <- "+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

#bring in counties
counties <- tigris::counties()
counties<-counties %>% filter(!STATEFP %in%  c("02", "60", "66", "69", "72", "78", "15"))
counties<-st_transform(counties,st_crs(albers))
st_crs(counties)


# make columns match to ag.val
counties$NAME <- toupper(counties$NAME)
counties <- rename(counties, State.ANSI = STATEFP)
counties <- rename(counties, County.ANSI = COUNTYFP)
counties$State.ANSI <- as.numeric(counties$State.ANSI)
counties$County.ANSI <- as.numeric(counties$County.ANSI)


#plot(counties) #checking and this doesn't have weird gaps yet
# bring in ag val and make values a numeric variable
agval <- read.csv("/Users/jamiefaselt/Resistance-Surfaces/Data/ag_val_conus.csv")
agval$Value <- gsub(",","",agval$Value)
agval$Value <- as.numeric(agval$Value)

# join
agval.spatial <- left_join(counties, agval) #some reason getting more obs from this

# double check projection
st_crs(counties) == st_crs(agval.spatial) #true

#subset to relevant variables
ag.val.sub <- agval.spatial %>% 
  dplyr::select(geometry,Value,County.ANSI,State.ANSI)

#create temp raster to make agval a raster
poly <- st_as_sfc(st_bbox(c(xmin = st_bbox(counties)[[1]], xmax = st_bbox(counties)[[3]], ymax = st_bbox(counties)[[4]], ymin = st_bbox(counties)[[2]]), crs = st_crs(counties)))
r <- raster(crs= proj4string(as(poly, "Spatial")), ext=raster::extent(as(poly, "Spatial")), resolution= 270)

rstr<<-fasterize::fasterize(ag.val.sub, r, field = 'Value')

plot(rstr) 

st_write(ag.val.sub,"ag_land_value.shp", overwrite=TRUE)
writeRaster(rstr, "2017_ag_land_val.tif", overwrite=TRUE)

