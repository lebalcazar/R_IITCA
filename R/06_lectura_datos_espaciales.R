# Lectura de datos geo-espaciales

# cargar librerias
library(lubridate)
library(raster)
library(sp)
library(tidyverse)

# datos raster  -------------------------------------------------------------

# datos PERSIANN-CDR  https://chrsdata.eng.uci.edu/ 
lf <- list.files(path = 'datos/raster/CDR_Month_WestAfr_tif', 
                 pattern = '.tif$', full.names = T)

cdrStk <- stack(lf)


# extraer los años que se utilizan como índices 
indices <- str_extract(lf, pattern = '[1-9]\\d{3}') %>% as.numeric()


# precipitación por año
cdrSum <- raster::stackApply(x = cdrStk, indices = indices, fun = sum)
plot(cdrSum[[2]])

# precipitación media anual del área
cdrMean <- stackApply(cdrSum, indices = nlayers(cdrSum), fun = mean)
plot(cdrMean)
writeRaster(cdrMean, 'resultados/raster/cdrMean.tif', overwrite = T)



# datos tabulares ---------------------------------------------------------
# extraer datos PERSIANN-CDR de estaciones meteorológicas
# ubicación de 4 estaciones
est <- read.csv('datos/tabular/est.csv', header = T)

# extraer datos de 4 pixeles 
cdrTab <- raster::extract(cdrStk, est[ ,c('x', 'y')]) 

# unir los datos con estaciones 
cdr <- cdrTab %>% 
  bind_cols(est = est,.) %>% 
  pivot_longer(cols = -c('name', 'x', 'y'), 
               names_to = 'fecha', values_to = 'cdr') %>% 
  mutate(fecha = paste0(fecha,01) %>% 
           as.Date('AfrWstCDR_%Y%m%d')) %>% rename(nombre = name)


# cargar los datos de precipitación mensual 
load('resultados/tablas/prc.mes.rds')
prc.mes <- prc.mes %>% 
  mutate(fecha = make_date(anio, mes, 1)) %>% ungroup() %>% 
  select(-c(anio, mes))

rm(list = setdiff(ls(), c('cdr', 'prc.mes')))

datosAfr <- left_join(cdr, prc.mes, by = c('nombre', 'fecha'))

# guardar
save(datosAfr, 
     file = 'resultados/tablas/datosAfr.Rdata')

# obtener el R2 
datosAfr %>% 
  split(.$nombre) %>% 
  map(~lm(cdr ~ prcMes, data = .)) %>% 
  map(summary) %>% 
  map_dbl('r.squared') %>% round(3)

# revisar artículo 
# https://www.mdpi.com/2072-4292/10/12/1884
               
