
# Introducción a R: -------------------------------------------------------
# básico: vectores, matrices, data frame y listas
#

# vectores ----------------------------------------------------------------

v.numeros <- c(5, 8, 2, 4, -9, 8, 10, 0, -5, 6)
v.nombres <- c('María', 'Pedro', 'Juan', 'Julia', 'Carmita', 'Carlos', 
               'Liliana', 'Silvia', 'Flor', 'Ana')
v.logico <- c(TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE)

# construir otros vectores:
rnorm(10)
letters[1:10]


# secuencia de enteros 
seq(from = 1, to = 20, by = 0.5)

# con :
8:17
10:1

# repetir un secuencia de números
rep(x = 1:3, times = 5)
rep(x = 1:3, each = 5)

# secuencia con decimales
seq(3, 18, 0.6)

# datos aleatorios 
rnorm(15)
rnorm(n = 10, mean = 5, sd = 2)
rweibull(10, shape = 1, scale = 1)

# muestra aleatoria
sample(-100:100, 10, replace = T)

# secuencia de reales
seq(from = 0, to = 2, by = 0.5)
(0:4)*0.5

# Enteros aleatorios del rango de -100 a 100
sample(x = -100:100, size = 10, replace = TRUE)

# letras
letters[10]
LETTERS[1:3]

# operaciones algebraicas (suma, resta, multiplicación, división)
c(2,5,2) + c(6,5,7)

# recursividad
(x <- c(2,5))
(y <- c(3,2,6, 8))
x * y

# indexación o subconjuntos
vec <- c(4,9,6,3)
vec[3:4]
vec[c(4,1)]

# datos faltantes 
vec <- c(4, NA, NA, 9,6, NA, 3)
sum(vec[!is.na(vec)]) # devuelve la suma de los datos que no son NA
sum(vec, na.rm = TRUE)
sum(is.na(vec)) #devuelve el total de valores NA

# estructura y tipo de dato
str(v.logico)
typeof(v.nombres)

# dimensión del vector
length(vec) #incluye los valores identificados como NA
length(vec[!is.na(vec)]) #devuelve el total de valores sin contar los NA

# conteo
table(v.numeros)
sum(v.logico)
table(v.logico)

# data frame --------------------------------------------------------------

(df.from.v <- data.frame(v.numeros, v.nombres, v.logico))

(df.from.bind <- dplyr::bind_cols(v.numeros = v.numeros, 
                                  v.nombres = v.nombres, 
                                  v.logico = v.logico))  # esto es tidyverse

(df2 <- tibble::tibble(v.numeros, v.nombres, v.logico))  # esto es tidyverse

colnames(df.from.bind)


# data frame indexación [filas, columnas] ------------------------------------

df.from.bind[5:6, 'v.nombres']


# conteo
colSums(df.from.bind[, c("v.numeros", "v.logico")])
colSums(df.from.bind[, -2])

# matrices ----------------------------------------------------------------

matrix(1:12, nrow = 4, ncol = 3, byrow = F)

(m1 <- matrix(data = 1:9, nrow = 3))


# crear otra matrix n x n 
set.seed(123456)
(m2 <- matrix(rnorm(9),3))

# determinante de la matriz
det(m1)

# inversa de la matriz
(m2.inv <- solve(m2))

# matriz identidad 
diag(m2)

# indexación de matrices
# matrix[filas, columas]
m1[2:3,2:3]
m1[2:3, c(1,3)]

# Suma por columnas o filas
colSums(m1)
rowSums(m1)








