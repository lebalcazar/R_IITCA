# Tidyverse -------------------------------------------------------
# es una familia de paquetes diseñado para manipulación de datos

library(tidyverse)
library(magrittr) #dplyr importa el pipe y otras funciones de este paquete
library(lubridate)


# pipe line %>% ----------------------------------------------------------------

(vx <- c(45, 46.8, -67, 34.6, 12, 34, 98))

# obtener la raíz cuadrada de la suma de un vector 
# forma tradicional
(suma.vx <- sum(vx))
(raiz.vx <- sqrt(suma.vx))
(redn.vx <- round(raiz.vx, 2))

# con paréntesis 
round(sqrt(sum(vx)),2)

# con pipe line
sum(vx) %>% sqrt() %>% round(2)

# análisis (datos iris)

# convierte a un tibble
iris <- tibble(iris)

# base
# de la especie versicolor, cuántos registros del largo_de_sépalo son mayores que 6.5 cm
iris[iris$Species == 'versicolor' & iris$Sepal.Length > 6.5, ]

# Selección por filas: dplyr::filter (tidyverse)
iris %>% 
  filter(Species == 'versicolor' & Sepal.Length > 6.5)


# Transformar los datos: agregar una nueva columna con dplyr::mutate
iris %>% 
  mutate(newCol = Sepal.Length * 2.15, newCol2 = 1:nrow(iris)) %>% 
  head()

# Seleccionar por columnas: dplyr::select()
iris %>% 
  select(Sepal.Length, Sepal.Width)

iris %>% 
  dplyr::select(1,3)

iris %>% 
  dplyr::select(starts_with('S')) %>% head()

# Agregación de valores: resumen de datos con group_by, summarise y mean
iris %>% 
  group_by(Species) %>% 
  summarise(media_SL = mean(Sepal.Length),
            media_SW = mean(Sepal.Width)) 

# resumen para todas las columnas
iris %>% 
  group_by(Species) %>% 
  summarise_all(.funs = ~mean(.))


# Tabla pivote: Transformación de la tabla entre filas y columnas
iris %>% 
  group_by(Species) %>% 
  dplyr::summarise_all(list(mn = 'min', mx = 'max')) %>% 
  pivot_longer(cols = -Species, names_to = 'minMax', values_to = 'dimensiones') %>% 
  pivot_wider(names_from = minMax, values_from = dimensiones)


# Ahora leeremos nuestros datos -------------------------------------------

# crear un lista de los archivos 
lf <- list.files('datos/tabular/meteo/', pattern = '.csv', full.names = T)

# leer los archivos con map valores faltantes (-1, -99)
data <- map(lf, ~read_csv(., col_names = F, na = c('-1', '-99'))) 

prc.dia <- data %>% 
  # une los archivos en un data frame (tibble)
  bind_rows() %>% 
  # seleccionamos las columnas que nos interesan
  dplyr::select(-c(X1, X7, X8)) %>% 
  # renombramos las variables
  dplyr::rename(nombre = X2, dia = X3, mes = X4, anio = X5, obs = X6) %>% 
  # crear un vector de fechas
  mutate(fecha = lubridate::make_date(year = anio, month = mes, day = dia)) 

# Ahora los tres pasos en una sola cadena de pasos, evitando pasos extra

prc.dia2 <- 'datos/tabular/meteo/' %>%
  list.files(pattern = '.csv', full.names = T) %>%
  map_df(read_csv, col_names = F, na = c('-1', '-99')) %>%
  dplyr::select(nombre = X2, dia = X3, mes = X4, anio = X5, obs = X6) %>% 
  mutate(fecha = lubridate::make_date(year = anio, month = mes, day = dia))
  
  
# datos mensuales ---------------------------------------------------------

# primero verificar datos faltantes 
dia.Na <- prc.dia %>%
  mutate(na = ifelse(is.na(obs), 1, 0)) %>%
  dplyr::group_by(nombre, anio, mes) %>%
  dplyr::summarise(na = sum(na))


# funcion para sumar datos restringiendo el núemro de NA's
sumNA <- function(x){
  ifelse(sum(is.na(x)) > 2,
         return(NA),
         return(sum(x, na.rm = T)))
}

# probar la función
sumNA(c(2, 4, NA, 6, 9))

# obtener la precipitación mensual por estación 
(prc.mes <- prc.dia %>%  
    dplyr::group_by(nombre, anio, mes) %>% 
    dplyr::summarise(prcMes = sumNA(obs))) 

# otra forma más compacta es:
prc.dia %>% 
  dplyr::count(nombre, anio, mes, es_NA = is.na(obs))

# guardar los datos mensuales 
save(prc.mes, file = 'resultados/tablas/prc.mes.rds')

# datos anuales ---------------------------------------------------

(prc.anio <- prc.dia %>%   
   dplyr::group_by(nombre, anio, mes) %>% 
   dplyr::summarise(prcMes = sumNA(obs)) %>% 
   group_by(nombre, anio) %>% 
   dplyr::summarise(prcAnio = sum(prcMes, na.rm = T)))


# obtenga la prc media anual de cada estación 

(prc.medAnual <- prc.anio %>%
    dplyr::group_by(nombre) %>% 
    dplyr::summarise(prcMedAnual = mean(prcAnio)))



# retomamos la lectura y arreglo de datos  ------------------------------------

# datos texto 
dakar <- read.fwf(file = 'datos/tabular/Dakar_PCP.ts3', 
                  skip = 28, 
                  widths = c(10, 6, 2)
)

# areglo de fechas
dakar %>% 
  transmute(fecha = V1, tiempo = V2, prc = V3) %>% 
  dplyr::select(-tiempo) %>% 
  mutate(fecha = ymd(as.character(fecha))) %>% tibble()


# leer datos sikasso csv
sikasso <- read_csv('datos/tabular/Sikasso.csv', na = '-999.9')

# selección de columnas
sikasso <- sikasso %>% 
  dplyr::select(!starts_with('F')) %>% 
  pivot_longer(cols = -c(STATION, YEAR, MONTH), values_to = 'PRC') %>% 
  separate(name, into = c('x', 'DAY'), sep = 'V') %>% dplyr::select(-x) %>% 
  mutate(DATE = make_date(YEAR, MONTH, DAY))



# vector de fechas 
date <- tibble(DATE = seq(make_date(min(sikasso$YEAR), 1, 1),
                            make_date(max(sikasso$YEAR), 12, 31),
                            by = 'day')
                )

# unir con la bd con date
data.sikasso <- left_join(date, sikasso, "DATE")





# consultar right_join, inner_join, full_join, etc
# https://dplyr.tidyverse.org/reference/join.html
  






