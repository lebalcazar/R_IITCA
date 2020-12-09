# Datos externos
# los paquetes de R tienen una base datos que se pueden utilizar 

# también se puede cargar la librería datasets 
library(datasets) # en inglés
library(datos)    # es español


# Cargar "data sets" en R -------------------------------------------------

# conjunto de datos del género iris
data(iris)
summary(iris)   
head(iris)      

# datos de economía de combustible
millas
str(millas)

# datos raster
library(raster)
library(sp)

# leer datos de la libraría raster  
rst <- system.file('external/test.grd', package = "raster") 
plot(raster(rst))



# guardar los datos   
# csv
write.csv(iris, 
          'resultados/tablas/datos_iris.csv')

# formato nativo de R: Rdata, rds, rda 
save(iris, mtcars, 
     file = 'resultados/tablas/datos_save.Rdata')

# cargar los datos guardados
load('resultados/tablas/datos_save.Rdata')



# lectura de datos externos -----------------------------------------------
# leer datos csv
dat <- read.csv('datos/tabular/Sikasso.csv')
head(dat)

# selecciona las variables con datos
datos <- dat[ ,c(1:3, seq(4, ncol(dat), 2))]

# datos texto 
dakar <- read.fwf(file = 'datos/tabular/Dakar_PCP.ts3', 
                  skip = 28, 
                  widths = c(10, 6, 2)
                  )

# asignar nombres a las variables
names(dakar) <- c('fecha', 'tiempo', 'prc')
head(dakar)

# arreglar la fechas
dakar$fecha <- as.Date(dakar$fecha, '%Y/%m/%d')
head(dakar)

# eliminar la columna tiempo 
dakar$tiempo <- NULL
head(dakar)

# JSON, GeoJSON, shp, xml, sav, ..., etc







