
# funciones ---------------------------------------------------------------
library(tidyverse)

# Función para generar un data frame con datos aleatorios
# Necesita ingresar el número de filas y columnas 
GenDF <- function(n.row, n.col){
  vec.datos <- sample(x = 0:100,              # valores modificables
                      size = n.row * n.col,  
                      replace = T)
  df <- as_tibble(matrix(data = vec.datos,    # 
                         nrow = n.row,
                         ncol = n.col)
  ) %>% rename_with(., ~gsub('V', 'col', .))
  return(df)
}

datosG <- GenDF(12, 8)
datosG


# moda --------------------------------------------------------------------

moda <- function(v){
  v.unique <- unique(v)  # valores únicos del vector
  v.unique[match(v, v.unique) %>%   # repetición de los índices o posiciones del vector
             tabulate() %>%  # enumera las repeticiones de cada índice
             which.max()]  # seleciona el máximo valor del índice (posición) 

}

datosG %>% 
  pivot_longer(cols = 1:ncol(.), names_to = 'columnas', values_to = 'num') %>% 
  dplyr::group_by(columnas) %>% 
    dplyr::summarise(moda = moda(num))




# estructuras de control --------------------------------------------------

# if/else
x <- sample(c(NA, -10:10, NA), size = 1) # selecciona un número aleatorio 

if (is.na(x) | is.character(x)) {
  stop(paste0('Favor ingrese un número'))
} else if (x >= 0){
  y <- 'número positivo'
} else {
  y <- 'número negativo'
}
print(y)


# for

for(i in 1:10){
  print(i + i^2)
}


# valor máximo de un df
colMax <- tibble()
for(i in 1:ncol(datosG)){
  columna <- dplyr::select(datosG, all_of(i))
  max <- max(columna)
  colMax <- bind_rows(colMax, 
                      c(col =  i, 
                        Max = max))
}
colMax 



# for en una función
colMaxx <- function(x){
  colMax = tibble()
  for(i in 1:ncol(datosG)){
    columna <- dplyr::select(datosG, all_of(i))
    max <- max(columna)
    colMax <- bind_rows(colMax, 
                        c(Col =  i, 
                          Max = max))
  }
  return(colMax)
}

colMaxx(datosG)
