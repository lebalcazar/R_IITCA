# Lectura de datos geo-espaciales
# cargar librerias
library(lubridate)
library(raster)
library(sp)
# datos raster  -------------------------------------------------------------

# datos PERSIANN-CDR  https://chrsdata.eng.uci.edu/ 
lf <- list.files(path = 'datos/raster/CDR_Month_WestAfr_tif', 
                 pattern = '.tif$', full.names = T)

cdrStk <- stack(lf)

# extraer las fechas 
lf_years <- paste0(str_extract(lf, '[1-9]\\d{5}'), '01')
indices <- as.Date(lf_years, format = '%Y%m%d') %>% 
  format('%Y') %>% 
  as.numeric()

# precipitación por año
cdrSum <- raster::stackApply(x = cdrStk, indices = indices, fun = sum)
plot(cdrSum[[2]])

# precipitación media anual del área
cdrMean <- stackApply(cdrSum, indices = nlayers(cdrSum), fun = mean)
plot(cdrMean)
writeRaster(cdrMean, 'resultados/raster/cdrMean.tif')

# visualizar
tmap_mode(mode = 'view')
tm_shape(cdrMean) +
  tm_raster(style = 'cont', 
            palette = RColorBrewer::brewer.pal(16,'Blues'),
            alpha = 0.80)









ggplot()



# datos tabulares ---------------------------------------------------------
# extraer datos PERSIANN-CDR de estaciones meteorológicas
# ubicación de 4 estaciones
est <- read.csv('datos/tabular/est.csv', header = T)

# extraer datos de 4 pixeles 
cdrTab <- raster::extract(cdrStk, est[,c('x', 'y')]) 

# unir los datos con estaciones 
cdr <- cdrTab %>% 
bind_cols(est = est,.) %>% 
  pivot_longer(cols = -c('name', 'x', 'y'), 
               names_to = 'date', values_to = 'cdr') %>% 
  mutate(date = paste0(date,01) %>% 
           as.Date('AfrWstCDR_%Y%m%d'))

# crear una lista con los archivos de texto 
lf.csv <- list.files(path = 'datos/tabular/meteo', 
                     pattern = 'csv$', full.names = T)

# leer los datos de estaciones
read <- lapply(lf.csv, function(x){
  read.csv(x, header = F)}) 
met <- read %>% 
  bind_rows() %>% 
  dplyr::transmute(name = V2, date = as.Date(ISOdate(V5, V4, V3)),  prc = V6) %>% 
  pivot_wider(names_from = name, values_from = prc) %>%                 #  truco para fechas
  pivot_longer(cols = -date, names_to = 'name', values_to = 'prc') %>%  #  truco para fechas
  arrange(name, date) %>% 
  dplyr::group_by(name, 
                  year = lubridate::year(date),
                  month = lubridate::month(date)) %>% 
  dplyr::summarise(prc = sum(prc, na.rm = T)) %>% 
  # recortar entre 1990 y 1999
  filter(year >= 1990 & year <= 1999)

# cargar los datos de precipitación mensual 
load('resultados/tablas/prc.mes.rds')

# vector de fechas
date <- tibble(date = seq(make_date(min(year(met$date)), 1, 1),
                          make_date(max(year(met$date)), 12, 31),
                          by = 'day'))
date

rm(list = setdiff(ls(), c('cdr', 'met', 'date')))

obs <- left_join()



               
