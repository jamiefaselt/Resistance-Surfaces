# HSI Revisit

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

states <- tigris::states()
mt <- states %>% filter(., NAME=="Montana", drop=TRUE)

# EVI is in title but it still the correct file
hsi <- raster("Data/DRAFT_Bison_Summer_EVI_8bit.tif")
plot(hsi)
summerhsi <- raster("Data/hsiresist copy.tif")
plot(summerhsi)


hsi.proj <- st_transform(mt, crs(hsi))
hsi.crop <- crop(hsi, as(hsi.proj, "Spatial"))
hsi.mask <- mask(hsi.crop, as(hsi.proj, "Spatial"))

plot(hsi.mask)
