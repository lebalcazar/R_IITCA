# familia Tidyverse -------------------------------------------------------
# manipulación de datos

library(tidyverse)
library(rlang)

# conjunto de datos del género de planta iris
iris

iris <- as_tibble(iris)


# mutate
iris %>% 
  mutate(newCol = Sepal.Length * 2.15, newCol2 = 1:nrow(iris))

# seleccionar
iris %>% 
  select(Sepal.Length, Sepal.Width)

iris %>% 
  select(1,2)

iris %>% 
  select(starts_with('S'))

# resumen de datos
iris %>% 
  group_by(Species) %>% 
  summarise(media.SL = mean(Sepal.Length),
            media.SW = mean(Sepal.Width)) 

iris %>% 
  group_by(Species) %>% 
  summarise_all(.funs = ~mean(.))


# arreglo de datos
iris %>% 
  group_by(Species) %>% 
  summarise_all(list(mn = min, mx = max)) %>% 
  pivot_longer(cols = -Species) %>% 
  pivot_wider(names_from = name, values_from = value)


  # filtrar
iris %>% 
  filter(Species == 'versicolor') %>% 
  filter(Sepal.Length >= mean(Sepal.Length))

iris %>% 
  filter(Species == 'versicolor') %>% 
  filter(Sepal.Length > mean(Sepal.Length) & Petal.Width <= mean(Petal.Width))



