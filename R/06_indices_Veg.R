# Se utilizan datos Landsat 8
# escenas de 2020-02-17
# resolución de 30m

library(raster)
library(ggplot2)
library(RStoolbox)
library(cowplot)
library(landsat8)

# crear una lista con las imágenes raster
lf <- list.files('datos/raster/Landsat8/', pattern = 'tif$', full.names = T) 

# apilar las imágenes en el objeto rst 
rst <- raster::stack(lf)

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

# conveir a spatial point
blue <- as(blue, 'SpatialGridDataFrame')
green <- as(green, 'SpatialGridDataFrame')
red <- as(red, 'SpatialGridDataFrame')
nir <- as(nir, 'SpatialGridDataFrame')

# conversoión a reflectancia TOA (parte superior de la atmósfera)
blue.ref <- reflconvS(blue, Mp = 2.0000E-05, Ap = -0.100000, sunelev = 48.91468164)  # Mp = Reflectance_multiband_x
green.ref <- reflconvS(green, Mp = 2.0000E-05, Ap = -0.100000, sunelev = 48.91468164)  # Ap = Reflectance_additive
red.ref <- reflconvS(red, Mp = 2.0000E-05, Ap = -0.100000, sunelev = 48.91468164)  # sunelev 
nir.ref <- reflconvS(nir, Mp = 2.0000E-05, Ap = -0.100000, sunelev = 48.91468164)

blue.ref <- as(blue.ref, 'RasterLayer')
green.ref <- as(green.ref, 'RasterLayer')
red.ref <- as(red.ref, 'RasterLayer')
nir.ref <- as(nir.ref, 'RasterLayer')

band <- raster::brick(blue.ref, green.ref, red.ref, nir.ref)

plotRGB(band, r = 4, g = 2, b = 1, stretch = 'hist', scale = 2000)
ggRGB(band, r= 4 , g=2 , b=1,
      stretch = "hist", scale = 2000)


# agrupación por k-means
band_df <- values(band)

idx <- complete.cases(band_df)

bandasKM <- raster(band[[1]])

values(bandasKM) <- kmClust

for(nClust in 1:4){
  
  cat("-> Clustering data for nClust =",nClust,"......")
  
  # Realizar clustering K-means
  km <- kmeans(band_df[idx,], centers = nClust, iter.max = 50)
  
  # Crear un vector entero temporal para mantener los números del clúster
  kmClust <- vector(mode = "integer", length = ncell(band))
  
  # Generar un vector de agrupamiento temporal para K-means
  kmClust[!idx] <- NA
  kmClust[idx] <- km$cluster
  
  # Crear un ráster temporal para mantener la nueva solución de clúster
  # K-means
  tmpbandasKM <- raster(band[[1]])
  
  # Establecer valores ráster con el vector deL clúster
  # K-means
  values(tmpbandasKM) <- kmClust
  
  # Unir los rásteres temporales en los finales
  if(nClust==2){
    bandasKM    <- tmpbandasKM
  }else{
    bandasKM    <- stack(bandasKM, tmpbandasKM)
  }
  
  cat(" hecho =)\n\n")
}

plot(bandasKM)

writeRaster(bandasKM, "kmeans.tif", overwrite=TRUE)    


