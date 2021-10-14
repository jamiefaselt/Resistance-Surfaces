# Conservation Easements Montana
# Montana Cadastral Data
# this is trash
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

states <- tigris::states()
mt<- states %>% filter(., NAME=="Montana", drop=TRUE) %>% 
  st_buffer(., dist = 50)
plot(mt)
mt <- counties("Montana", cb = TRUE)

conease <- st_read("Data/MontanaCadastral_SHP/Montana_Cadastral/CONSERVATIONEASEMENTS.shp")
plot(conease)

mt$geometry <- mt$geometry %>%
  s2::s2_rebuild() %>%
  sf::st_as_sfc()

mt <- st_as_sf(mt)
conease.reproject <- st_as_sf(conease.reproject)

st_crs(mt.reproject) == st_crs(conease.reproject)
mt.reproject <- st_transform(mt, crs(conease))

coneaseshp <- st_join(conease.reproject, mt.reproject)
plot(coneaseshp)
