# Sistemas de Información Geográfica con R

# SIG --------------------------------------------

library(raster)        # objetos raster
library(RColorBrewer)  # paleta de colores
library(grDevices)     # soporte de colores y fuentes
library(RStoolbox)     # plot raster 

# crear un raster ingresando la resolución 
rst1 <- raster(ext = extent(-13, -9,  10, 13), 
               res = c(0.25, 0.25)
)
values(rst1) <- 1:ncell(rst1)
plot(rst1)


# crear un raster ingresando el número de filas y columnas
rst2 <- raster(ext = extent(-13, -9,  10, 13),
               ncol = 16, nrow = 12)
values(rst2) <- rweibull(ncell(rst2), shape = 1)
plot(rst2)

# Algrebra de mapas
# funciones aritméticas (+, -, *, ^, %%, %/%, /)
plot(rst1 * rst2)
plot(rst1 %/% rst2)

# funciones matemáticas (abs, sqrt, sin, round)
sqrt(rst2) %>% plot()

# revisar métodos de resúmenes (mean, max)
sum(rst1,500) %>% plot()

# extraer los valore de los pixels 
rasterToPoints(rst2)

# overlay 



# cargar un raster de altitud (MNA)
alt <- raster('datos/raster/DEM/Alt.rst')
# plot(alt)

# descargar datos
alt2 <- getData(name = 'SRTM', lon = -11, lat = 11, download = T, 
                path = 'resultados')

alt10 <- raster::aggregate(alt, fact = 10, fun = mean)


# # area de estudio (AE)
r <- raster(ext = extent(-13, -9,  10, 13), 
            res = c(0.25, 0.25)
)
values(r) <- 1:ncell(r)
r <- projectRaster(r, crs= "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# cortar DEM para AE
altCnc <- raster::crop(alt10, r)
paleta <- grDevices::colorRampPalette(c('black', 'white'),7)
plot(altCnc, col = paleta(7))
plot(altCnc, col = brewer.pal(7, 'Greys'))

# guaradar DEM alt cuenca 
# writeRaster(x = altCnc, 
#             filename = 'D://r-curso-IITCA/datos/altCnc.tif')

alt_points <- rasterToPoints(altCnc) %>% data.frame()
# alt_points <- altCnc %>% as('SpatialPixelsDataFrame') %>% as.data.frame()

#altCnc.df <- data.frame(alt_points)


# poligono <- rasterToPolygons(r) %>% st_as_sf
# plot(poligono, add = T, crs= "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

#  leer coordenadas de estaciones meteo
estMet <- read.csv('D:/tesisT/datos/base_datos_africa/sinopticas.csv') %>% 
  dplyr::select('x', 'y', 'name') %>% 
  st_as_sf(coords = c('x','y'), 
           crs = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0')
# plot(estMet, add = T)
# plot(p, add = T)


# cargar poligino de datos globales 
data("countriesHigh")

# convertir a simple feature
mundo <- sf::st_as_sf(countriesHigh)

westAfr <- mundo %>% 
  filter(GEO3 == 'Western Africa') 

# vector de la cuenca 
cncBafing <- st_read('datos/vector/cncBafing.shp')

# vector de rio
rioSenegal <- st_read('datos/vector/rioSenegal.shp')

mapaWestAfr <- ggplot() + 
  geom_sf(data = westAfr) +
  geom_tile(data = alt_points, aes(x, y, fill = Alt)) +
  geom_sf(data = cncBafing, colour = 'red', alpha = 0) +
  scale_fill_gradientn(colours = grDevices::terrain.colors(10),
                       breaks = round(seq(min(alt_points$Alt),
                                          max(alt_points$Alt),
                                          by = 400),0)) +
  guides(fill = guide_legend()) +
    # geom_sf(data = poligono, colour = 'red', alpha = 0) +
  geom_sf(data = rioSenegal, colour = 'blue') +
  geom_sf(data = estMet, colour = 'blue') +
  labs(x = '', y = '', 
       fill = 'msnm',
       title = 'Africa Occidental') +
  north(data = westAfr, symbol = 16) +
  scalebar(westAfr, dist = 250, dist_unit = 'km', st.size = 4,
           transform = T, model = 'WGS84',location = 'bottomright',) +
  theme_bw() +
  # dark_theme_bw() +
  theme(panel.grid = element_line(colour = 'grey75'),
        panel.ontop = T, panel.background = element_rect(color = NA, fill = NA)) +
  theme(legend.position = c(0.08, 0.16),
        legend.background = element_blank(),
        legend.direction = 'vertical') 
  
mapaWestAfr
ggsave(filename = 'resultados/mapaWestAfr.png', 
       plot = mapaWestAfr, 
       device = 'png',
       path = '../resultados',
       width = 18, height = 16, units = 'cm', dpi = 300)




