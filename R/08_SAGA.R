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
                 out.dem = "resultados/raster/escondido/alt_fill",
                 method = "xxl.wang.liu.2006",
                 minslope = 0.0001)

# plot
raster("resultados/raster/escondido/alt_fill.sdat") %>% plot()


# hillshade
rsaga.hillshade(in.dem = 'resultados/raster/escondido/alt_fill.sdat',
                out.grid = 'resultados/raster/hillshade', 
                exaggeration = 4, env = env
)
raster('resultados/raster/hillshade.sdat') %>% plot()




# hidrología --------------------------------------------------------------
# algunos módulos para hidrología
rsaga.get.modules("ta_hydrology")
rsaga.get.modules("ta_channels")


# acumulación de flujo
rsaga.topdown.processing(in.dem = "resultados/raster/escondido/alt_fill.sgrd", 
                         out.carea = "resultados/raster/escondido/flujo",  
                         method = "mfd",
                         env = env)
flujo <- raster("resultados/raster/escondido/flujo.sdat")
spplot(flujo)


# redes de cauces 
rsaga.get.modules("ta_channels", env = env)
rsaga.get.usage("ta_channels", "Channel Network",env = env)
rsaga.geoprocessor("ta_channels",0,list(ELEVATION="resultados/raster/escondido/alt_fill.sgrd",
                                        CHNLNTWRK="resultados/raster/escondido/channel_net.sgrd",
                                        CHNLROUTE="resultados/raster/escondido/route.sdat",
                                        SHAPES='datos/raster/puntoEscondido/channel_net_shp.shp',
                                        INIT_GRID="resultados/raster/escondido/flujo.sgrd",
                                        INIT_METHOD= 2, 
                                        INIT_VALUE = 5000000), 
                   env = env)

cauces <- st_read("datos/raster/puntoEscondido/channel_net_shp.shp")

spplot(as(cauces, "Spatial"), "Order")


# delimitación de cuencas
rsaga.get.usage("ta_channels","Watershed Basins",env = env)


rsaga.geoprocessor("ta_channels",1,
                   list(ELEVATION = "resultados/raster/escondido/alt_fill.sgrd", 
                        CHANNELS = "resultados/raster/escondido/channel_net.sgrd", 
                        BASINS = "resultados/raster/escondido/basins.sgrd",
                        MINSIZE = 500), 
                   env = env)

cuencaEscondido <- raster("resultados/raster/escondido/basins.sdat")

spplot(cuencaEscondido)








