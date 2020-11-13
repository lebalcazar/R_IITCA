
# Introducción a R: -------------------------------------------------------
# básico: vectores, matrices, data frame y listas

rm(list = ls())

# vectores ----------------------------------------------------------------

v.numeros <- c(5,8,2,4,-9,8,10,0,-5,6)
v.nombres <- c('María', 'Pedro', 'Juan', 'Julia', 'Carmita', 'Carlos', 'Liliana', 'Silvia', 'Flor', 'Ana')
v.logico <- c(TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE)

v.aleatorio <- rnorm(10, 0, 1)
v.secuencia <- seq(1, 20, 2)
v.secuencia <- 1:10
v.letras <- letters[1:10]
v.faltantes <- c(3, NA, 8.3, 2.7, NA, 2.5, NA, 3, NA, 6.1)

# operaciones algebraicas (suma, resta, multiplicación, división)
v.numeros + v.aleatorio
sum(v.faltantes, na.rm = T)
sum(v.faltantes[!is.na(v.faltantes)])
sum(na.omit(v.faltantes))

# recursividad
x <- c(2,5)
y <- c(3,2,6,8)
x * y

# indexación o subconjuntos
v.logico[5]
v.letras[c(5,2,8)]
v.faltantes[!is.na(v.faltantes)]

# estructura y tipo de dato
str(v.logico)
typeof(v.nombres)

# dimensión del vector
length(v.letras)

# conteo
table(v.numeros)
sum(v.logico)
table(v.logico)

# data frame --------------------------------------------------------------

df.from.v <- data.frame(v.numeros, v.secuencia, v.logico)
df.from.bind <- dplyr::bind_cols(v.numeros = v.numeros, b = v.nombres, c = v.logico)  # esto es tidyverse
df2 <- tibble(v.numeros, v.secuencia, v.logico)  # esto es tidyverse

colnames(df.from.v)

# conteo
colSums(df.from.v)

# matrices ----------------------------------------------------------------

m1 <- matrix(data = 1:9, nrow = 3, ncol = 3, byrow = F)
m1.1 <- matrix(1:12, ncol = 3)

# crear otra matrix n x n 
set.seed(123456)
(m2 <- matrix(rnorm(9),3))

# determinante de la matriz
det(m1)

# inversa de la matriz
m2.inv <- solve(m2)

# matriz identidad 
diag(m2)

# indexación de matrices
# matrix[filas, columas]
m1[2:3,2:3]
m1[2:3, c(1,3)]

# conteo
colSums(m1)
rowSums(m1)


# pipe %>% ----------------------------------------------------------------

vx <- c(45,46.8,-67,34.6,12,34,98)
vx
round(sqrt(sum(vx)),2)

# listas ------------------------------------------------------------------

l1 <- list(df.from.v, v.letras, f = factor(c(3,8,9)), v.new = 1:5)

#subset
l1[[1]][2:6, ] %>% colSums()
l1[[4]] %>% mean()

# funciones ---------------------------------------------------------------

# generar datos aleatorios para un data frame
GenDF <- function(n.row, n.col){
  vec.datos <- sample(x = c(NA, 0:400), 
                      size = n.row * n.col, 
                      replace = T)
  df <- as_tibble(matrix(data = vec.datos,
                         nrow = n.row,
                         ncol = n.col)
  ) %>% rename_with(., ~gsub('V', 'col', .))
}

datosG <- GenDF(4,6)
datosG




# estructuras de control --------------------------------------------------

# if/else
x <- sample(c(NA, 1:20), size = 1, replace = T)
if (is.na(x)) {
  stop(paste0('Favor ingrese un número'))
} else if (x > 10){
  y <- TRUE
} else {
  y <- FALSE
}
y

# for

for(i in 1:10){
  print(i + i^2)
}

# valor máximo de un df
colMax <- data.frame()
for(i in 1:ncol(datosG)){
  columna <- dplyr::select(datosG, i)
  max <- max(columna)
  colMax <- bind_rows(colMax, 
                      c(col = i, 
                        max = max))
}
colMax 

# en una función
colMaxx <- function(x){
  colMax = data.frame()
  for(i in 1:ncol(x)){
    columna = dplyr::select(x, i)
    max = max(columna)
    colMax = bind_rows(colMax, 
                        c(col = i, 
                          max = max))
  }
  print(colMax)
}
colMaxx(datosG)


# familia Tidyverse -------------------------------------------------------

# manipulación de datos
iris <- as.tibble(iris)

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

iris %>% 
  group_by(Species) %>% 
  summarise_all(list(mn = min, mx = max)) 

# arreglo de datos
iris %>% 
  group_by(Species) %>% 
  summarise_all(list(mn = min, mx = max)) %>% 
  pivot_longer(cols = -Species) %>% 
  pivot_wider()



# filtrar
iris %>% 
  filter(Species == 'versicolor') %>% 
  filter(Sepal.Length >= mean(Sepal.Length))
  
iris %>% 
  filter(Species == 'versicolor') %>% 
  filter(Sepal.Length > mean(Sepal.Length) & Petal.Width <= mean(Petal.Width))


# plots -------------------------------------------------------------------

# graficos base 
plot <- plot(Sepal.Length ~ Petal.Length, data = iris,
             main = 'Pétalo vs Sépalo', 
             xlab = 'Longitud del Sépalo', ylab = 'Longitud del Pétalo', 
             col = 'blue', 
             type = 'p', pch = 16)


# gplot2 ------------------------------------------------------------------
# gramática de gráficos
# gráficos de alta calidad 
iris %>% 
  ggplot(aes(x = Sepal.Length, y = Petal.Length)) +
  geom_point(colour = 'blue')

iris %>% 
  ggplot(aes(x = Sepal.Length, y = Petal.Length, colour = Species)) +
  geom_point() +
  theme_bw() +
  labs(x = 'Longitud del Sépalo', y = 'Longitud del Pétalo', colour = 'Especies')
  
  iris %>% 
  ggplot(aes(x = Sepal.Length, y = Petal.Length, color = Species)) +
  geom_point() +
  stat_smooth(method = 'lm') +
  theme_bw() +
  #scale_color_ordinal(guide = guide_legend()) 
  guides(color =
           guide_legend(title = 'Especies',
                        title.theme = element_text(vjust = 0.5,
                                                   size = 10,
                                                   face = "bold",
                                                   colour = "black"))) +
  theme(legend.position = c(0.85, 0.2)) +
  labs(x = 'Longitud del Sépalo', y = 'Longitud del Pétalo')

  lm <- lm(Sepal.Length ~ Petal.Length, data = iris)

  residual <- summary(lm)$residual
  plot(residuals(lm))
  r.cuadrado <- summary(lm)$adj.r.squared
  
  # resumen del modelo
  tidy(lm)
  
  glance(lm)
  


  df <- expand.grid(X1 = 1:10, X2 = 1:10)
  df$value <- df$X1 * df$X2
  
  p1 <- ggplot(df, aes(X1, X2)) + 
    geom_tile(aes(fill = value))
  
  p2 <- p1 + geom_point(aes(size = value))
  p2
  # Basic form
  p1 + scale_fill_continuous(guide = guide_legend())  

  p1 + guides(fill = guide_legend(title = 'XX'))  
  
  

  

# tribble -----------------------------------------------------------------

people <- tribble(
  ~Name,
  'Mark Gindas',
  'Dave Smith',
  'Jackie Doe'
  )
people
str(people)

people2 <- people %>% 
  separate(Name, into = c('FIRST', 'LAST'), sep = ' ')

people3 <- people2 %>% 
  unite(col = 'Nombre completo', FIRST, LAST, sep = ' ', remove = FALSE)












# expresiones regulares ---------------------------------------------------
library(stringr)

correo <- c('Luis Bal le.bal@gmail.com', 'Pablito P pal_@hotmail.com', 'Juan A jp-radio@yahoo.com')
str_extract(string = correo, pattern = "[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\\.[a-zA-Z]+")

texto <- sprintf('las camisas blanc@s pueden ser muy ensuciables el son mal0s resultad@s. 
                 Miestras que las otras camisas son de buena calidad')

str_extract(texto, pattern = '[a-zA-Z]+@[a-zA-Z]')

str_extract_all(texto, pattern = '[^a-z]+')



