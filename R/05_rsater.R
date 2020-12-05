# Sistemas de Información Geográfica con R

# SIG --------------------------------------------

library(raster)        # objetos raster
library(RColorBrewer)  # paleta de colores
library(grDevices)     # soporte de colores y fuentes
library(RStoolbox)     # plot raster 
library(sf)
library(rworldxtra)
library(ggsn)

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
plot(overlay(rst1, rst2, fun = sum))


# funciones matemáticas (sin, cos, abs, sqrt, round)
sin(rst2) %>% plot()

# revisar métodos de resúmenes (mean, max)
sum(rst2,500) %>% plot()

# extraer los valores de los pixels 
rasterToPoints(rst2)



# datos DEM SRTM de África Occidental a 3 arcos de segundos ~90-100 m
altWestAfr <- raster('datos/raster/DEM/AltAfrOcc.tif')
plot(altWestAfr)

# recortar el DEM para el área de estudio
alt <- crop(altWestAfr, rst1)
plot(alt)

# leer coordenadas de estaciones meteo
estMet <- read.csv('datos/tabular/est.csv')

# adjuntar los puntos al DEM
plot(estMet, add = T, 
     type = 'p', pch = 16, col = 'blue')

# extraer la altitud de los puntos 
extract(alt, estMet[, c('x', 'y')]) %>% 
  cbind(estMet, alt = .)

# cambiar la resolución 
alt10 <- raster::aggregate(alt, fact = 10, fun = mean)
plot(alt10)

# convertir a puntos 
alt_points <- rasterToPoints(alt10) %>% data.frame()
