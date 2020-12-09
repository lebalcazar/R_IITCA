
# delimitación de cuencas hidrográficas -----------------------------------

# http://rstudio-pubs-static.s3.amazonaws.com/422453_f6e4d24dcbbd4cdd8b677f1686aff9e6.html

library(RSAGA)
library(sp)
library(rworldxtra)
library(raster)


data('countriesHigh')

# leer raster DEM a ~90 metros de resolución
alt <- raster('datos/raster/DEM/Alt_90_ll.tif')
plot(alt)


#  leer coordenadas de estaciones meteo
estMet <- read.csv('datos/tabular/ubicacion/sinopticas.csv') %>% 
  dplyr::select('x', 'y', 'name') %>%
  st_as_sf(coords = c('x','y'), 
           crs = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0')
plot(estMet, add = T, col = 'red')

# cargar poligino de datos globales 
data("countriesHigh")

