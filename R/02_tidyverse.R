# Tidyverse -------------------------------------------------------
# es una familia de paquetes diseñado para manipulación de datos

library(tidyverse)
library(magrittr)


# pipe %>% ----------------------------------------------------------------
# obtener la raís cuadrada de la suma de un vector 
(vx <- c(45, 46.8, -67, 34.6, 12, 34, 98))

(suma.vx <- sum(vx))
(raiz.vx <- sqrt(suma.vx))
(redn.vx <- round(raiz.vx, 2))

# con paréntesis 
round(sqrt(sum(vx)),2)

# con pipe
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










