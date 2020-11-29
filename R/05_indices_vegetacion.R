
# indice de vegetación (NDVI) ---------------------------------------------

library(raster)
library(ggplot2)
library(RStoolbox)
library(cowplot)
library(landsat8)

lf <- list.files(path = 'datos/raster/Sentinel-2_Mex/', pattern = "jp2",
                  full.names = T)
sentinel2 <- stack(lf)
names(sentinel2)<- c("Blue", "Green", "Red", "NIR")


nir <- sentinel2$NIR # Infrarojo cercano
red <- sentinel2$Red # Rojo

ndvi <- (nir-red)/(nir+red) # NDVI

ndvi[ndvi>1] <- 1; ndvi[ndvi< (-1)] <- -1 #Reescalado para evitar outliers


# Visualización del NDVI e imagen falso color -----------------------------

# Visualización NDVI guardada en el objeto ndvi_plot

ndvi_plot <- ggR(ndvi, geom_raster = TRUE,alpha = 1) +
  scale_fill_gradientn(colours = rev(terrain.colors(100)), 
                       name = "NDVI") + 
  theme(legend.position = "bottom")

plot(ndvi_plot)


# Visualización falso color guardada en el objecto falso_color

falso_color <- ggRGB(sentinel2, r= "NIR" , g="Green" , b="Blue",
                     stretch = "lin")

# Representación finaltiff

cowplot::plot_grid(ndvi_plot, falso_color)




# cre una lista con las imágenes raster
lf <- list.files('datos/raster/L8_NDVI/Nueva carpeta/', pattern = 'TIF$', full.names = T) 

# apilar las imágenes en el objeto rst 
rst <- raster::stack(lf)

# se crea una mascar
msk <- raster::raster(xmn = 412000, xmx = 460000, ymn = 2090000, ymx = 2140000, 
               res = c(30, 30), 
               crs = '+proj=utm +zone=14 +datum=WGS84 +units=m +no_defs')
values(msk) <- rep(1, times = ncell(msk))

rstCrop <- crop(rst, msk)

ban <- paste0('B', 1:10)
for (i in 1:nlayers(rstCrop)){
writeRaster(rstCrop[[i]], 
            filename = paste('datos/raster/L8_NDVI/', paste0('B',i), '.tif'), 
            format = 'GTiff')
  } 

# renombrar las bandas con RGB 
blue <- rstCrop$LC08_L1TP_026047_20200217_20200225_01_T1_B2 
green <- rstCrop$LC08_L1TP_026047_20200217_20200225_01_T1_B3 
red <- rstCrop$LC08_L1TP_026047_20200217_20200225_01_T1_B4 
nir <- rstCrop$LC08_L1TP_026047_20200217_20200225_01_T1_B5  

# indice de vegetación de diferencia normalizadoa NDVI 
ndvi <- (nir - red)/(nir + red) 
plot(ndvi)

# falso color (RGB 4,3,2)
names(rstCrop) <- c('b2', 'b3', 'b4', 'b5')
plotRGB(rstCrop, 'b4', 'b3', 'b2', stretch = "hist", scale = 2000)




blue <- as(blue, 'SpatialGridDataFrame')
green <- as(green, 'SpatialGridDataFrame')
red <- as(red, 'SpatialGridDataFrame')
nir <- as(nir, 'SpatialGridDataFrame')

# conversoión a reflectancia TOA (parte superiro de la atmósfera)
blue.ref <- reflconvS(blue, Mp = 2.0000E-05, Ap = -0.100000, sunelev = 48.91468164)  # Mp = Reflectance_multiband_x
green.ref <- reflconvS(green, Mp = 2.0000E-05, Ap = -0.100000, sunelev = 48.91468164)  # Ap = Reflectance_additive
red.ref <- reflconvS(red, Mp = 2.0000E-05, Ap = -0.100000, sunelev = 48.91468164)  # sunelev 
nir.ref <- reflconvS(nir, Mp = 2.0000E-05, Ap = -0.100000, sunelev = 48.91468164)

blue.ref <- as(blue.ref, 'RasterLayer')
green.ref <- as(green.ref, 'RasterLayer')
red.ref <- as(red.ref, 'RasterLayer')
nir.ref <- as(nir.ref, 'RasterLayer')

band <- raster::brick(blue.ref, green.ref, red.ref, nir.ref)

plotRGB(band, r = 3, g = 2, b = 1, stretch = 'hist', scale = 2000)
ggRGB(band, r= 4 , g=2 , b=1,
                     stretch = "hist", scale = 2000)


# agrupación por k-means
band_df <- values(band)

idx <- complete.cases(band_df)

bandasKM <- raster(band[[1]])

values(tmpbandasKM) <- kmClust

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
    
  
  
  
  
  
  
  
  
  
