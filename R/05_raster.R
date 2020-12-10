# Sistemas de Información Geográfica con R

# SIG --------------------------------------------

library(raster)        # objetos raster
library(sf)


# crear un raster ingresando la resolución 
rst1 <- raster(ext = extent(-13, -9,  10, 13.25), 
               res = c(0.25, 0.25)
)
values(rst1) <- 1:ncell(rst1)
plot(rst1)


# crear un raster ingresando el número de filas y columnas
rst2 <- raster(ext = extent(-13, -9,  10, 13.25),
               ncol = 16, nrow = 13)
values(rst2) <- rweibull(ncell(rst2), shape = 1, scale = 1)
plot(rst2)


# Algrebra de mapas
# funciones aritméticas (+, -, *, ^, %%, %/%, /)

# multiplicar por un escalar
rst2 <- rst2 * 80

# sumar dos imágenes
plot(rst1 + rst2)

# overlay 
rst3 <- overlay(rst1, rst2, fun = mean) 

# funciones matemáticas (sin, cos, abs, sqrt, round)
sin(rst2) %>% plot()

# utilizando un escalar
sum(rst2,500) %>% plot()

# extraer los valores de los pixels 
rasterToPoints(rst2)

# agrupar imágenes
rst.stk <- stack(rst1, rst2, rst3)
plot(rst.stk)


# datos DEM SRTM de África Occidental a 3 arcos de segundos ~90-100 m
altWestAfr <- raster('datos/raster/DEM/DEM_Senegal/AltSenegal.rst')
plot(altWestAfr)

# recortar el DEM para el área de estudio
alt <- crop(altWestAfr, rst1)
plot(alt)

# leer coordenadas de estaciones meteo
estMet <- read.csv('datos/tabular/est.csv') %>% 
  st_as_sf(coords = c('x','y'), 
           crs = '+proj=longlat +datum=WGS84 +no_defs')
             
plot(estMet, add = T, col = 'blue', pch = 16)

# extraer la altitud de los puntos 
data <- extract(alt, estMet) %>% 
  cbind(estMet, alt = .)

# cambiar la resolución 
alt10 <- raster::aggregate(alt, fact = 10, fun = mean)
plot(alt10)

# leer un vector de cuenca
cncBafing <- st_read('datos/vector/cncBafing.shp')
plot(cncBafing, add = T, col = NA)

# cortar el MDE 
altBafing <- mask(alt10, cncBafing)
plot(altBafing)

# convertir a puntos 
alt_points <- rasterToPoints(altBafing) %>% data.frame()
head(alt_points)
