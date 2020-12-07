# tmap paquete para mapas temáticos

library(tmap)
library(sf)
library(raster)
library(tidyverse)
library(rworldxtra)



# datos espaciales de municipios de México
mex <- st_read('datos/vector/dipoest00gw/dipoest00gw.shp')

# nombres de los campos
names(mex)

# dos formas de plotear (1) qtm quickly thematic maps y (2) con elementos

# área en miles de km2
qtm(mex, fill = 'AREA')

# elementos o capas tm_shape(raster y vectores)
tm_shape(mex) +
  tm_fill('AREA') +
  tm_borders('white') +
  tm_text('POTO00', size = 0.8)

# tmap tiene dos modos (plot y view)
tmap_mode(mode = 'view')

# Población total (en millones) de la entidad federativa, 2000.
qtm(mex, fill = 'POTO00')

# cambiar a plot -> view y viceversa
ttm()

# filtrar un estado
EstMex <- filter(mex, ESTADO == 'MEXICO')

# Estado de México
qtm(EstMex)

qtm(EstMex, fill = 'POTO00') 
  




# mapa Africa con tmap ----------------------------------------------------

# cargar los datos 
# raster DEM
alt <- raster('datos/raster/DEM/alt100m.tif')

# vector de la cuenca 
cncBafing <- st_read('datos/vector/cncBafing.shp')

# cargar poligino de datos globales 
data("countriesHigh")

# convertir a simple feature
mundo <- sf::st_as_sf(countriesHigh)

# seleccionar la región de Africa Occidental 
westAfr <- mundo %>% 
  filter(GEO3 == 'Western Africa') 

# vector de rio
rioSenegal <- st_read('datos/vector/rioSenegal.shp')

# estaciones meteorológicas
estMet <- read.csv('datos/tabular/est.csv') %>% 
  st_as_sf(coords = c('x','y'), 
           crs = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0')


# graficar 
qtm(westAfr, fill = NULL) +
  qtm(alt, legend.outside = TRUE, ) +
  qtm(cncBafing, fill = NULL, borders = 'red', legend.outside = T) +
  qtm(rioSenegal, lines.col = 'blue')



# otra manera de hacerlo con tmap -----------------------------------------

# crea un polígono bbox
box <- st_bbox(westAfr) %>% st_as_sfc()

# objeto box
tm_shape(box) +
  tm_polygons(col = 'white', border.col = 'black', lwd = 2) +

# polígono de Africa occidental
tm_shape(westAfr) +
  tm_borders() +
  tm_graticules(ticks = F) +
  
  # adjuntar el raster
  tm_shape(alt) +
  tm_raster(title = 'msnm', style = 'cont',
            breaks = seq(100, 1500, 400),
            palette = colorspace::terrain_hcl(6)) +
  
  # ríos 
  tm_shape(rioSenegal) +
  tm_lines(col = 'blue') +
  tm_add_legend(type = c('line'),
                labels = c('Ríos'), 
                col = c('blue')) +
  
  # puntos de estaciones
  tm_shape(estMet) +
  tm_dots(size = 0.2, col = 'blue') +
  tm_layout(legend.outside = T,
            legend.frame = T) +
  tm_add_legend(type = c('symbol'),
                labels = c('Estaciones'), 
                col = c('blue')) +
  
  # polígono de cuenca
  tm_shape(cncBafing) +
  tm_borders(col = 'red') +
  tm_add_legend(type = 'fill',
                labels = 'Cuenca',
                col = 'red') +
  # layout
  tm_layout(legend.outside = T, 
            legend.title.size = 0.8, 
            legend.text.size = 0.5) + 
  tm_scale_bar(position = c(0.01, 0.01)) + 
  tm_compass(size = 2, type = "8star", position = c(0.82, 0.04)) 
  
  
  





