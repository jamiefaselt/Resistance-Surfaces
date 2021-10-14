# Ag Val/Acre for Con US
# URL=https://quickstats.nass.usda.gov/results/387739E0-1063-314E-B616-B74D15FA1D32
# cropping to Montana with buffer for study area (really this just gives me a big box that includes montana)

hsi <- raster("hsiresist540.tif")

agval <- raster("2017_ag_land_val.tif")
plot(agval)
mtval <- raster("2017_mt_ag_land_val.tif")
plot(mtval)
st_crs(agval) == st_crs(mtval)
st_crs(agval)
st_crs(mtval)

agvalproj <- projectRaster(agval, crs = mtval)
plot(agvalproj)
agvalcrop <- crop(agvalproj, mtval)
plot(agvalcrop)
plot(mtval)
