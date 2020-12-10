
# indice de vegetación (NDVI) ---------------------------------------------

library(raster)
library(ggplot2)
library(RStoolbox)
library(cowplot)
library(landsat8)


# crear una lista con las imágenes raster
lf <- list.files('datos/raster/Landsat8/', pattern = 'tif$', full.names = T) 

# apilar las imágenes en el objeto rst 
rst <- raster::stack(lf)

# ladsat8 https://gisgeography.com/landsat-8-bands-combinations/
# renombrar las bandas con RGB 
blue <- rst$B2 
green <- rst$B3 
red <- rst$B4 
nir <- rst$B5  

# indice de vegetación de diferencia normalizadoa NDVI (-1 NDVI 1)
ndvi <- (nir - red)/(nir + red) 

# graficar 
ggR(ndvi, geom_raster = TRUE) +
  theme_bw() + 
  scale_fill_gradientn(colours = rev(terrain.colors(100)), 
                       name = "NDVI") + 
  theme(legend.position = "right") +
  labs(x = '', y = '', 
       title = 'Valle de Toluca') 

#  falso color 
plotRGB(rst, 'B4', 'B3', 'B2', stretch = "hist", scale = 1000)


# falso color para áreas sin cobertura (urbanas)
plotRGB(rst, 'B7', 'B6', 'B4', stretch = "hist", scale = 1000)

# infrarrojo para vegetación 
plotRGB(rst, 'B5', 'B4', 'B3', stretch = "hist", scale = 1000)


# area más pequeña 
msk <- raster::raster(xmn = 440000, xmx = 448000, ymn = 2112000, ymx = 2120000, 
                      res = c(30, 30), 
                      crs = '+proj=utm +zone=14 +datum=WGS84 +units=m +no_defs')
values(msk) <- rep(1, times = ncell(msk))

rstCrop <- crop(rst, msk)

# cultivos
plotRGB(rstCrop, 'B6', 'B5', 'B2', stretch = "hist", scale = 1000)





# cálculo de reflectancia 
# clasificación no supervisada
# https://rpubs.com/marialorena/clasificacion_no_supervisada

