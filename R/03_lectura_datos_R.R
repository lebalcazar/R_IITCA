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




# lectura de datos externos -----------------------------------------------


# cargar los paquetes 
library(tidyverse)
library(lubridate)

# crear un lista de los archivos 
lf <- list.files('datos/tabular/meteo/', pattern = '.csv', full.names = T)

# leer los archivos con map valores faltantes (-1, -99)
data <- map(lf, ~read_csv(., col_names = F, na = c('-1', '-99'))) 

(prc.dia <- data %>% 
    # une los archivos en un data frame (tibble)
    bind_rows() %>% 
    # seleccionamos las columnas que nos interesan
    select(-c(X1, X7, X8)) %>% 
    # renombramos las variables
    rename(nombre = X2, dia = X3, mes = X4, anio = X5, obs = X6) %>% 
    # crear un vector de fechas
    mutate(fecha = make_date(year = anio, month = mes, day = dia)))


# datos mensuales ---------------------------------------------------------

# primero verificar datos faltantes 
(dia.Na <- prc.dia %>%
   mutate(na = ifelse(is.na(obs), 1, 0)) %>%
   dplyr::group_by(nombre, anio, mes) %>%
   dplyr::summarise(na = sum(na)))


# funcion para sumar datos restringiendo el núemro de NA's
sum.2 <- function(x,...){
  ifelse(sum(is.na(x)) > 2,
         return(NA),
         return(sum(x, na.rm = T)))
}

sum.2(c(2, 4, NA, NA, 6, NA, 9))

# obtener la precipitación mensual por estación 
(prc.mes <- prc.dia %>%  
    dplyr::group_by(nombre, anio, mes) %>% 
    dplyr::summarise(prcMes = sum.2(obs)))

# guardar los datos mensuales 
save(prc.mes, file = 'resultados/tablas/prc.mes.rds')

# datos anuales ---------------------------------------------------

(prc.anio <- prc.dia %>%   
   dplyr::group_by(nombre, anio, mes) %>% 
   dplyr::summarise(prcMes = sum.2(obs)) %>% 
   group_by(nombre, anio) %>% 
   summarise(prcAnio = sum(prcMes, na.rm = T)))


# EJERCICIO Usd.
# obtenga la prc media anual de cada estación 

(prc.medAnual <- prc.anio %>%
    group_by(nombre) %>% 
    summarise(prcMedAnual = mean(prcAnio)))






