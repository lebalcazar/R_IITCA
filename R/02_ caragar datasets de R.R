
# Cargar "data sets" en R -------------------------------------------------

# los paquetes de R tienen una base datos que se pueden utilizar 

# también se puede cargar la librería datasets 
library(datasets)

# conjunto de datos del género iris
iris

# conjuntos de datos marcas de vehículos
mtcars

# datos raster
library(raster)

# primero ubicar localmente el paquete
system.file(package = 'raster')

# leer el raster y plotear
plot(raster("C:/Users/lebal/Documents/R/win-library/4.0/raster/external/test.grd"))

# de otra manera 
rst <- system.file('external/test.grd', package = "raster") 
plot(raster(rst))



