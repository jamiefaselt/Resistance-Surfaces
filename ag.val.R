# URL = URL=https://quickstats.nass.usda.gov/results/A38481AD-2F20-3BF8-9295-653190550348
# ag land value $ 

# bring in state of montana
library(tigris)
library(ggplot2)
library(tidyverse)
library(sf)
library(sp)
library(raster)
library(terra)
library(dplyr)
library(rgdal)

mt <- counties("Montana", cb = TRUE)
mt <- as_tibble(mt)
mt.counties <- rename(mt, County = NAME)
colnames(mt.counties)


agval <- read.csv("Data/ag_land_value_2017.csv")
str(agval)

ag.val.sp <- left_join(agval, mt.counties)

st_as_sf(ag.val.sp)

str(ag.val.sp)
st_crs(ag.val.sp)


ag.val.crs <- st_transform(ag.val.sp, crs(mt.counties))
