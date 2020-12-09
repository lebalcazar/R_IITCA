# Tidyverse -------------------------------------------------------
# es una familia de paquetes diseñado para manipulación de datos

library(tidyverse)
library(magrittr)


# pipe %>% ----------------------------------------------------------------
# obtener la raís cuadrada de la suma de un vector 
(vx <- c(45, 46.8, -67, 34.6, 12, 34, 98))

# forma tradicional
(suma.vx <- sum(vx))
(raiz.vx <- sqrt(suma.vx))
(redn.vx <- round(raiz.vx, 2))

# con paréntesis 
round(sqrt(sum(vx)),2)

# con pipe line
vx %>% sum() %>% sqrt() %>% round(2)

# filtrar 
# retomar el ejercicio anterior
# de la especie versicolor filtrar los valores de sépalo mayor a 6.5
iris[iris$Species == 'versicolor' & iris$Sepal.Length > 6.5, ]


# filtrar con dplyr (tidyverse)
iris <- tibble(iris)

iris %>% 
  filter(Species == 'versicolor' & Sepal.Length > 6.5)

iris %>% 
  # cuantos registros están por encima de la media
  filter(Species == 'setosa') %>% 
  filter(Sepal.Length <= mean(Sepal.Length))  

iris %>% 
  filter(Species == 'versicolor') %>% 
  filter(Sepal.Length > mean(Sepal.Length) | Petal.Width <= mean(Petal.Width))

  
# agrgar una nueva columna con mutate
iris %>% 
  mutate(newCol = Sepal.Length * 2.15, newCol2 = 1:nrow(iris)) %>% 
  head()

# seleccionar
iris %>% 
  select(Sepal.Length, Sepal.Width)

iris %>% 
  select(1,2)

iris %>% 
  select(starts_with('S')) %>% head()

# resumen de datos con group_by y summarise
iris %>% 
  group_by(Species) %>% 
  summarise(media_SL = mean(Sepal.Length),
            media_SW = mean(Sepal.Width)) 

iris %>% 
  group_by(Species) %>% 
  summarise_all(.funs = ~mean(.))


# arreglo de datos
iris %>% 
  group_by(Species) %>% 
  summarise_all(list(mn = min, mx = max)) %>% 
  pivot_longer(cols = -Species, names_to = 'minMax', values_to = 'dimensiones') %>% 
  pivot_wider(names_from = minMax, values_from = dimensiones)


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








