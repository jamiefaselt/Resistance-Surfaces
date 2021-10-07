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

#us.county <- counties(state = NULL, cb = FALSE, resolution = "500k", year = NULL)
us <- states()
states <-  us%>% filter(!STATEFP %in%  c("02", "60", "66", "69", "72", "78", "15"))
states<-st_transform(states,st_crs(albers))
#us.counties <- st_join(us.county, us)

# bring in shapefile of US counties and select to conus
US.County <- read_sf("/Users/jamiefaselt/Resistance-Surfaces/Data/cb_2018_us_county_20m/cb_2018_us_county_20m.shp")
albers <- "+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
#filter out AK , Guam, etc 
US.County<-US.County %>% filter(!STATEFP %in%  c("02", "60", "66", "69", "72", "78", "15"))
US.County<-st_transform(US.County,st_crs(albers))


# make sure valid geometries and crs match
st_is_valid(US.County) #true
st_is_valid(states) #true
st_crs(states)==st_crs(US.County) #true

#left join to get state names added
conuscounties <- st_join(US.County, states) #this has duplicates

#drop duplicates
us.counties <- distinct(conuscounties, GEOID.x, .keep_all = TRUE) #this seems to have worked

# make columns match to ag.val
us.counties$NAME.y <- toupper(us.counties$NAME.y)
us.counties$NAME.x <- toupper(us.counties$NAME.x)
us.counties <- rename(us.counties, County = NAME.x)
us.counties <- rename(us.counties, State = NAME.y)

# bring in ag val and make values a numeric variable
agval <- read.csv("/Users/jamiefaselt/Resistance-Surfaces/Data/ag_val_conus.csv")
agval$Value <- gsub(",","",agval$Value)
agval$Value <- as.numeric(agval$Value)

# join
agval.join <- left_join(agval, us.counties)
class(agval.join)
agval.spatial <-  st_as_sf(agval.join, crs = crs(us.counties), agr = "constant")
class(agval.spatial) #now it is an sf df

# double check projection
st_crs(us.counties) == st_crs(agval.spatial) #true
plot(agval.spatial)

#subset to relevant variables
ag.val.sub <- agval.spatial %>% 
  dplyr::select(geometry,Value,County,State)
# str(ag.val.sub)
plot(ag.val.sub) # this and regular agval.spat plot with gaps

poly <- st_as_sfc(st_bbox(c(xmin = st_bbox(us.counties)[[1]], xmax = st_bbox(us.counties)[[3]], ymax = st_bbox(us.counties)[[4]], ymin = st_bbox(us.counties)[[2]]), crs = st_crs(us.counties)))
r <- raster(crs= proj4string(as(poly, "Spatial")), ext=raster::extent(as(poly, "Spatial")), resolution= 270)

rstr<<-fasterize::fasterize(ag.val.sub, r, field = 'Value')

plot(rstr) #wellp
