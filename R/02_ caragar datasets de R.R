
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
library(sp)

# primero ubicar localmente el paquete
system.file(package = 'raster')

# de otra manera 
rst <- system.file('external/test.grd', package = "raster") 
plot(raster(rst))

# leer el raster y plotear
rst <- raster("C:/Users/lebal/Documents/R/win-library/4.0/raster/external/test.grd")
plot(rst)

# hacer un resumen estadístico con los datos iris
summary(iris)

# obtener un 


