# Cargar librerias
library(tidyverse) # pkg para ciencia de datos 
library(RSAGA)     # pkg para integrar SAGA con R
library(raster)    # pkg para manejar datos raster
library(sf)        # pkg para manejar datos vectoriales
library(tmap)      # pkg para desplegar objetos (raster, poligonos, etc)


# Conectar el ambiente de SAGA en Windows
env <- rsaga.env(path = 'C:/Program Files (x86)/SAGA-GIS')
env

# desplegar las librerias de SAGA
rsaga.get.libraries()

# modulos del la librería preprocessor 
rsaga.get.modules("ta_preprocessor")

# función para rellenar depresiones del terreno
rsaga.fill.sinks(in.dem = "datos/raster/demEscondido/s_b1w24290utm.rst",
                 out.dem = "resultados/raster/escondido/s_b1w24290utm_fill",
                 method = "xxl.wang.liu.2006",
                 minslope = 0.0001)


raster("datos/raster/demEscondido/s_b1w24290utm_fill.sdat") %>% plot()

path <- 'resultados/raster/escondido/s_b1w24290utm_fill.sdat'
dem <- raster(path)
plot(dem)

# ver el raster-DEM en modo vista
tmap_mode(mode = 'view')
tm_shape(dem) +
  tm_raster(style = 'cont')

# rellenar huecos, valores faltantes u otros
rsaga.fill.sinks(in.dem = 'datos/raster/demEscondido/s_b1w24290utm.rst', 
                 out.dem = 'resultados/raster/dem_fill', env = env)
raster('resultados/raster/dem_fill.sdat') %>% plot

# hacer un hillshade
rsaga.hillshade(in.dem = 'resultados/raster/dem_fill.sdat',
                out.grid = 'resultados/raster/hillshade', 
                exaggeration = 4, env = env
)
raster('resultados/raster/hillshade.sdat') %>% plot()



# 
print <- raster('D:/04SIG/01 Rawdata/Prc/PERSIANN-CDR_mensual_global_Tif/CDR_2020-08-26072833pm/CDR_201812.tif')
tm_shape(World) + 
  tm_polygons("HPI", border.col = 'black', alpha = 0.1, title = '', legend.show = F) + tm_shape(print)  + 
  tm_raster(style = 'cont', alpha = 0.75, palette = RColorBrewer::brewer.pal(16,name = 'GnBu'), title = 'mm') 
