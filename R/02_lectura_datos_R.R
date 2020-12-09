# Datos externos
# los paquetes de R tienen una base datos que se pueden utilizar 

# también se puede cargar la librería datasets 
library(datasets)


# Cargar "data sets" en R -------------------------------------------------

# conjunto de datos del género iris
iris


# conjuntos de datos marcas de vehículos
str(mtcars)

# datos raster
library(raster)
library(sp)

# primero ubicar localmente el paquete
system.file(package = 'raster')

# leer el raster  
rst <- system.file('external/test.grd', package = "raster") 
plot(raster(rst))

plot(raster("C:/Users/lebal/Documents/R/win-library/4.0/raster/external/test.grd"))

# hacer un resumen estadístico con los datos iris
summary(iris)

# seleccionar de la especie versicolor longitud sépalo mayor a 6.5
(versi.mayor6.5 <- iris[iris$Species == 'versicolor' & iris$Sepal.Length > 6.5, ])


# guardar los datos   
# csv
write.csv(iris, 
          'resultados/tablas/datos_iris.csv')

# formato nativo de R: Rdata, rds, rda 
save(iris, mtcars, 
     file = 'resultados/tablas/datos_save.Rdata')

# cargar los datos guardados
load('resultados/tablas/datos_save.Rdata')


# leer datos csv
dat <- read_csv('datos/tabular/Sikasso.csv')





# lectura de datos externos -----------------------------------------------










