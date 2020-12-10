# mapas con ggplot y tmap paquete para mapas temáticos

library(tmap)
library(sf)
library(raster)
library(tidyverse)
library(rworldxtra)


# mapas con ggplot --------------------------------------------------------

# cargar un raster de altitud (MNA) África occidental
alt <- raster('datos/raster/DEM/alt100m.tif')
plot(alt)


# leer coordenadas de estaciones meteo
estMet <- read.csv('datos/tabular/est.csv') %>% 
  st_as_sf(coords = c('x','y'), 
           crs = '+proj=longlat +datum=WGS84 +no_defs')
            

# adjuntar los puntos al DEM
plot(estMet, add = T, 
     type = 'p', pch = 16, col = 'blue')



# cargar poligino de datos globales 
data("countriesHigh")
names(countriesHigh)

# convertir a simple feature
mundo <- sf::st_as_sf(countriesHigh)

# seleccionar la región de Africa Occidental 
westAfr <- mundo %>% 
  filter(GEO3 == 'Western Africa') 

# plotear la región
plot(westAfr$geometry)

# vector de la cuenca 
cncBafing <- st_read('datos/vector/cncBafing.shp')
plot(cncBafing, add = T, col = 'red')

# vector de rio
rioSenegal <- st_read('datos/vector/rioSenegal.shp')
plot(rioSenegal, add = T, col = 'blue')

# convertir a puntos 
alt_points <- rasterToPoints(alt) %>% data.frame()


mapaWestAfr <-  ggplot() + 
  # polígono de Africa occidental
  geom_sf(data = westAfr) +
  # raster del DEM agregado ~1km
  geom_tile(data = alt_points, aes(x, y, fill = alt100m)) +
  # polígono de la cuenca Bafing Makana
  geom_sf(data = cncBafing, aes(colour = 'Cuenca'), fill = 'red', #alpha = 0,
          show.legend = 'polygon') +
  
  geom_sf(data = rioSenegal, aes(colour = 'Río'), 
          show.legend = 'line') +
  geom_sf(data = estMet, aes(colour = 'Estaciones'), 
          show.legend = 'point') +
  
  scale_colour_manual(values = c('Cuenca' = 'red', 'Río' = 'blue', 
                                 'Estaciones' = 'green'), 
                      guide = guide_legend(override.aes = 
                                             list(linetype = c(1, 0, 1),
                                                  shape = c(NA, 16, NA),
                                                  fill = c('red', NA, NA)))) +
  
  # cambio de color en el raster (color de terreno)
  scale_fill_gradientn(colours = grDevices::terrain.colors(10),
                       breaks = round(seq(min(alt_points$alt100m),
                                          max(alt_points$alt100m),
                                          by = 400),
                                      0)) +
  # guides( fill = guide_legend()) +
  labs(x = '', y = '', 
       fill = 'msnm',
       title = 'Africa Occidental',
       colour = '') +
  ggsn::north(data = westAfr, symbol = 16) +
  ggsn::scalebar(data = westAfr, dist = 250, dist_unit = 'km', st.size = 2, 
                 transform = T, model = 'WGS84',location = 'bottomright') +
  theme_bw() +
  theme(panel.grid = element_line(colour = 'grey75'),
        panel.ontop = T, panel.background = element_rect(color = NA, fill = NA)) + 
  theme(legend.position = 'bottom',
        legend.background = element_blank(),
        legend.direction = 'horizontal') 

mapaWestAfr

# guardar el mapa
ggsave(filename = 'mapaWestAfr.png', 
       plot = mapaWestAfr, 
       device = 'png',
       path = 'resultados/mapas',
       width = 18, height = 16, units = 'cm', dpi = 600)





# mapas con tmap ----------------------------------------------------------



# download.file(url = "http://www.conabio.gob.mx/informacion/gis/maps/geo/dipoest00gw.zip",
#               destfile = "datos/vector/dipoest00gw.zip")
# unzip("datos/vector/dipoest00gw.zip", exdir = "datos/vector/dipoest00gw")


# datos espaciales de municipios de México
mex <- st_read('datos/vector/dipoest00gw/dipoest00gw.shp')

# nombres de los campos
names(mex)

# dos formas de plotear (1) qtm quickly thematic maps y (2) con elementos

# existe el mode plot y view
tmap_mode(mode = 'plot')

# área en km2
qtm(mex, fill = 'SUP00')

# filtrar un estado
EstMex <- filter(mex, ESTADO == 'MEXICO')

# Estado de México
qtm(EstMex)

# población del EdoMex
qtm(EstMex, fill = 'POTO00') 

# cambio de plot a view
tmap_mode(mode = 'view')

# área en miles de km2
mex <- mex %>% mutate(area = SUP00/1000)  

# elementos o capas tm_shape(raster y vectores)
tm_shape(mex) +
  tm_borders('white') +
  tm_text(text = 'area', size = 0.8) +
  tm_fill(col = 'area', title = 'Área [miles de km2]',
          title.col = 'Superficie', id = "ESTADO",
          popup.vars = c('Superficie' = 'area'),
          popup.format = list(area = list(digits = 1))) 


# población en millones 
mex$Pob <- round(mex$POTO00/1000000,1)

tm_shape(mex) +
  tm_borders('grey50') +
  tm_text(text = 'Pob') + 
  tm_fill(col = 'Pob',  title = "Población [millones (2000)]",
          title.col = 'Población', id = "ESTADO", 
          popup.vars = c('Poblacion' = "Pob"),
          popup.format = list(Pob = list(digits = 1)))




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
           crs = '+proj=longlat +ellps=WGS84 +no_defs')

tmap_mode(mode = 'plot')




# plot -----------------------------------------

tmap_mode(mode = 'plot')

# crea un polígono bbox
box <- st_bbox(westAfr) %>% st_as_sfc()

# objeto box
AfrTmap <- tm_shape(box) +
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
  tm_add_legend(type = 'symbol', shape = 16, size = 0.4,
                border.col = 'blue',
                labels = 'Estaciones', 
                col = 'blue') +
  
  # polígono de cuenca
  tm_shape(cncBafing) +
  tm_borders(col = 'red') +
  tm_add_legend(type = 'fill',
                border.col = 'red',
                labels = 'Cuenca',
                col = NA) +
  # escala y norte
  tm_layout(legend.title.size = 0.9, 
            legend.text.size = 0.7) + 
  tm_scale_bar(position = c(0.01, 0.01)) + 
  tm_compass(size = 2, type = "8star", position = c(0.82, 0.04)) 

AfrTmap

tmap_save(tm = AfrTmap, 
          filename = 'resultados/mapas/AfrTmap.png', 
          width = 12, height = 10, units = 'cm', dpi = 600)  
  
  





