# lectura de datos geo-espaciales
library(lubridate)

# datos raster  -------------------------------------------------------------

# datos PERSIANN-CDR
lf <- list.files(path = 'datos/raster/CDR_Month_WestAfr_tif', 
                 pattern = '.tif$', full.names = T)

cdrStk <- stack(lf)

# precipitación para cada año
lf_years <- paste0(str_extract(lf, '[1-9]\\d{5}'), '01')
indices <- as.Date(lf_cd, format = '%Y%m%d') %>% 
  format('%Y') %>% 
  as.numeric()
cdrSum <- raster::stackApply(x = cdrStk, indices = indices, fun = sum)

# precipitación media anual
cdrMean <- stackApply(cdrSum, indices = indices, fun = mean)
writeRaster(cdrMean, 'resultados/raster/cdrMean.tif')

# visualizar
tmap_mode(mode = 'view')
tm_shape(cdrMean) +
  tm_raster(style = 'cont', 
            palette = RColorBrewer::brewer.pal(16,'Blues'),
            alpha = 0.80)

# graficar un mapa por mes
lf_month <- paste0(str_extract(lf, '[1-9]\\d{5}'), '01')
indices <- as.Date(lf_month, format = '%Y%m%d') %>% 
  format('%Y') %>% 
  as.numeric()
cdrMeanMonth <- raster::stackApply(x = cdrStk, indices = indices, fun = mean)

# precipitación (mes)
cdrMeanM <- stackApply(cdrMonth, indices = indices, fun = mean)


CDRsum.df <-  as.data.frame(cdrStk, xy = TRUE) %>% 
  pivot_longer(cols = 3:ncol(.), values_to = 'Prc') %>% 
  mutate(name = gsub(name, pattern = 'index_', replacement = '') %>%  as.numeric()) %>% 
  pivot_wider(names_from = name, values_from = Prc)
names(CDRsum.df) <- mes
CDRsum.df <- CDRsum.df %>% 
  pivot_longer(cols = 3:ncol(.), values_to = 'Prc') %>% 
  mutate(name = factor(name, levels = mes.f,
                       labels = mes.f)) %>% 
  ggplot() +
  geom_raster(aes(x, y, fill = Prc)) +
  theme_bw()+
  theme(legend.position = 'bottom',
        legend.box.spacing = unit(0.1, 'cm'),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  geom_polygon(africa, mapping = aes(x = long, y = lat, group = group),
               color = 'black', fill = NA) +
  scale_fill_gradient(low = '#FFFFFF', high = 'blue', 
                      breaks = c(50, 300, 600)) +
  labs(x = 'Longitud', y = 'Latitud', fill = 'Precipitación (mm)') +
  facet_wrap(~name) 



ggplot()



# datos tabulares ---------------------------------------------------------
# extraer datos de estaciones meteorológicas
# ubicación de 4 estaciones
est <- read.csv('datos/tabular/est.csv', header = T)

# extraer datos de 4 pixeles 
cdrTab <- extract(cdrStk, est[,c('x', 'y')]) 
cdr <- cdrTab %>% 
bind_cols(est = est,.) %>% 
  pivot_longer(cols = -c('name', 'x', 'y'), 
               names_to = 'date', values_to = 'cdr') %>% 
  mutate(date = as.Date(paste0(date,01), 'AfrWstCDR_%Y%m%d'))

# leer los datos de estaciones 
lf.csv <- list.files(path = 'datos/tabular/meteo', 
                     pattern = 'csv$', full.names = T)
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



# vector de fechas
date <- tibble(date = seq(make_date(min(year(met$date)), 1, 1),
                          make_date(max(year(met$date)), 12, 31),
                          by = 'day'))
date

rm(list = setdiff(ls(), c('cdr', 'met', 'date')))

obs <- left_join()



               
