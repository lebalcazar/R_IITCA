
# Introducción a R: -------------------------------------------------------
# básico: vectores, matrices, data frame y listas


# vectores ----------------------------------------------------------------

(v.numeros <- c(5, 18, -2, 10, -5))
(v.nombres <- c('María', 'Pedro', 'Juan', 'Julia', 'Ana'))
(v.logico <- c(TRUE, FALSE, TRUE, TRUE, FALSE))

# construir otros vectores ":"
8:17  # from:to, by = 1
10:1

# secuencia de enteros 
seq(from = 1, to = 20)
seq(1, 20, by = 2)  # incremento de la secuencia

# repetir un secuencia de números
rep(x = 1:3, times = 5)
rep(x = 1:3, each = 5)

# secuencia de reales
seq(from = 0, to = 2, by = 0.5)
(0:4)*0.5

# datos aleatorios 
rnorm(n = 15, mean = 0, sd = 1)
rnorm(15)
rnorm(10, 5, 2)
rweibull(10, shape = 1, scale = 1)


# muestra aleatoria
sample(x = -100:100, size = 8, replace = TRUE)
sample(-100:100, 8,  T)
sample(x = letters[], 5, replace = F)

# operaciones algebraicas (suma, resta, multiplicación, división)
c(2, 5, 2) + c(6, 5, 7)

# recursividad
(x <- c(2, 5))
(y <- c(3, 2, 6, 8))
x * y

# indexación o subconjuntos
(vec <- c(4, 9, 6, 3, 0, 2))
vec[3:4]
vec[c(6,1)]

# datos faltantes 
vec <- c(4, NA, NA, 9, 6, NA, 3)
sum(vec)
sum(vec[!is.na(vec)]) # devuelve la suma de los datos que no son NA
sum(is.na(vec))       # devuelve el total de valores NA

# dimensión del vector
length(vec)  # incluye los valores identificados como NA

# obtener el total sin NA
length(vec[!is.na(vec)]) 

# vector de fechas
(fecha <- seq(as.Date(ISOdate(2003,1,1)),
             as.Date(ISOdate(2003,5,31)),
             by = 'month'))


# data frame --------------------------------------------------------------

(df.from.v <- data.frame(fecha, v.numeros, v.nombres, v.logico))

colnames(df.from.v)
dim(df.from.v)


# data frame indexación [filas, columnas] 
# [filas, columnas]
df.from.v[1, ]              # selecciona fila 1
df.from.v[ ,1]              # selecciona columna 1
df.from.v[3:5, 'v.nombres'] # selecciona los nombres de las filas 3:5
df.from.v$v.numeros         # selecciona con el operador $

# seleccion por indexación y suma de columnas 
colSums(df.from.v[ ,c("v.numeros", "v.logico")])
colSums(df.from.v[ ,-c(1,3)])


# agregar una columna al data frame
df.from.v$nueva_variable01 <- 1:nrow(df.from.v)
df.from.v[ ,'nueva_variable2'] <- 1:nrow(df.from.v)

df.from.v <- data.frame(df.from.v, 
                        nueva_variable3 = round(rnorm(nrow(df.from.v)),2)
)

# quitar columnas del data frame
(df.from.v[ ,-c(1, 4)])     # con la ubicación de las variables
df.from.v$v.logico <- NULL   # con $ y NULL
df.from.v 


# matrices ----------------------------------------------------------------

matrix(data = 1:12, nrow = 4, ncol = 3)

# matriz desde vectores
(matriz <- cbind(c(1:3), rnorm(3), c(10, 20, 30)))

# matriz con función matrix()
(m1 <- matrix(data = 1:9, nrow = 3))
(m2 <- matrix(rnorm(9), 3))

# operaciones 
m1 * m2

# indexación de matrices
# matriz[filas, columas]
m1[c(1,3),2:3]


# Suma por columnas o filas
colSums(m1)
rowSums(m1)


# revisar por su cuenta la ayuda para:  
# obtener el determinante det(matriz)
# la inversa de la matriz solve(matriz)
# la diagonal de la matriz diag(matriz)
# valores propios eigen(matriz)




# arrays ------------------------------------------------------------------
# generalizacion de una matriz con n dimensiones (del mismo tipo de dato)

(ar <- array(data = c(m1, m2), dim = c(3,3,2)))

# seleccionar [fila, columna, (layer, page)]

ar[3,1,2]
ar[ , ,1][ ,c(1,3)]


# listas ------------------------------------------------------------------
# las listas son un conjunto de datos que pueden tener vectores, data frames, etc

lista <- list(v.logico, df.from.v, ar)
lista

# seleccionar con el operador [[]]
lista[[2]][ ,1]
lista[[3]][ , ,1][2, ]
lista[[2]]$nueva_variable01

