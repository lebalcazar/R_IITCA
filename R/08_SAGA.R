# Cargar librerias
library(tidyverse) # pkg para ciencia de datos 
library(RSAGA)     # pkg para integrar SAGA con R
library(raster)    # pkg para manejar datos raster
library(sf)        # pkg para manejar datos vectoriales
library(tmap)      # pkg para desplegar objetos (raster, poligonos, etc)


# Conectar el ambiente de SAGA en Windows
env <- rsaga.env(path = 'C:/Program Files (x86)/SAGA-GIS')
env

# Consultar los nombres de las librerias de SAGA
rsaga.get.libraries()

# Consultar los módulos de la librería preprocessor 
rsaga.get.modules("ta_preprocessor")

# Consultar como se usa un módulo: Se puede usar el nombre o el número de módulo
rsaga.get.usage("ta_preprocessor", module = "Fill Sinks (Wang & Liu)")

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

#···································
# acumulación de flujo
rsaga.topdown.processing(in.dem = "resultados/raster/escondido/alt_fill.sgrd", 
                         out.carea = "resultados/raster/escondido/flujo",  
                         method = "mfd",
                         env = env)
flujo <- raster("resultados/raster/escondido/flujo.sdat")
spplot(flujo)

#···································
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

#···································
# delimitación de cuencas
rsaga.get.usage("ta_channels","Watershed Basins",env = env)


rsaga.geoprocessor("ta_channels",1,
                   list(ELEVATION = "resultados/raster/escondido/alt_fill.sgrd", 
                        CHANNELS = "resultados/raster/escondido/channel_net", 
                        BASINS = "resultados/raster/escondido/basins",
                        MINSIZE = 500), 
                   env = env)

cuencaEscondido <- raster("resultados/raster/escondido/basins.sdat")

spplot(cuencaEscondido)


#···································
# Cuenca aportante a un punto de salida.
rsaga.get.modules("ta_hydrology", env = env)
rsaga.get.usage(lib = "ta_hydrology", module = 4, env = env)

# Coordenada del punto de salida en el mismo SRC del DEM
pxy <-  c(x = 347724.5180, y = 3172076,5631)

# Calculemos la cuenca aportante a ese punto
rsaga.geoprocessor(
  lib = "ta_hydrology", 
  module = 4,
  param = list(TARGET_PT_X = pxy[1], 
               TARGET_PT_Y = pxy[2], 
               ELEVATION = "resultados/raster/escondido/alt_fill.sgrd",
               METHOD = 2, #Método MFD de acuerdo a #[1]
               AREA = "resultados/raster/escondido/cuenca_aporte.sgrd"),
  env = env
)

cuencaAportante <- raster("resultados/raster/escondido/cuenca_aporte.sdat")

# afinar los valores mediante reclasificación
cuencaAportante[cuencaAportante <= 0] <- NA
cuencaAportante[cuencaAportante > 0] <- 1

# Plot del DEM
raster("resultados/raster/escondido/alt_fill.sdat") %>% 
  plot()

# Agregar cuenca aportante
plot(cuencaAportante, add = TRUE, legend = FALSE)

# agregar el punto de salida
points(pxy[1], pxy[2], cex = 1, pch = 16)

# Referencias ----
#[1] https://www.sciencedirect.com/science/article/pii/009830049190048I
