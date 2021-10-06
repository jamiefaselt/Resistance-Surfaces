# URL = URL=https://quickstats.nass.usda.gov/results/A38481AD-2F20-3BF8-9295-653190550348
# ag land value $ 


library(tigris)
library(ggplot2)
library(tidyverse)
library(sf)
library(sp)
library(raster)
library(dplyr)
library(rgdal)
library(ggmap)
library(stars)
library(fasterize)

mt <- counties("Montana", cb = TRUE)
mt.counties <- rename(mt, County = NAME)
colnames(mt.counties)
str(mt.counties)
st_crs(mt.counties)
mt.counties$County <- toupper(mt.counties$County)

agval <- read.csv("Data/ag_land_value_2017.csv")
str(agval)
agval$Value <- gsub(",","",agval$Value)

agval$Value <- as.numeric(agval$Value)


ag.val.sp <- left_join(agval, mt.counties)
ag.val.spat <-  st_as_sf(ag.val.sp, crs = crs(mt), agr = "constant")

st_crs(mt.counties) == st_crs(ag.val.spat)

ag.val.17 <- ag.val.spat %>% 
  filter(ag.val.spat$Year == 2017, drop = TRUE)

ag.val.sub <- ag.val.17 %>% 
  dplyr::select(geometry,Value,County)
# str(ag.val.sub)
plot(ag.val.sub)

x <- raster(ncol=5000, nrow=5000, xmn=-116.049155, xmx=-104.039563, ymn=44.357962, ymx=49.00139)
rtemp <- raster()
#r <- raster::raster(crs= proj4string(as(poly, "Spatial")), ext=raster::extent(as(poly, "Spatial")), resolution= 270)

#rstr<<-fasterize::fasterize(mrp.r, r, field = 'mrp_stm', fun = 'min' )

ag.val <- fasterize(ag.val.sub, x, field = "Value")
plot(ag.val)

temp.rast <- raster(xmn=-116.049155, xmx=-104.039563, ymn=44.357962, ymx=49.00139, res=5000, crs= CRS(mt))



rstr<-fasterize::fasterize(ag.val.sub, temp.rast, field = "Value")
plot(rstr)
write_csv(ag.val.sub, "2017_ag_land_value.csv")
st_write(ag.val.sub,"2017_ag_land_value.shp")
writeRaster(ag.val, "2017_ag_land_val.tif", overwrite=TRUE)

ag.val <- raster("2017_ag_land_val.tif")
ag.val.sub <- st_read("2017_ag_land_value.shp")


