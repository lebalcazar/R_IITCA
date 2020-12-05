

# cre una lista con las imágenes raster
lf <- list.files('datos/raster/', pattern = 'tif$', full.names = T) 

# apilar las imágenes en el objeto rst 
rst <- raster::stack(lf)

# indice de vegetación de diferencia normalizadoa NDVI 
# en ladsa8 RGB es red = banda 4, green = banda 3, blue = 2, y NIR = banda 5

red = rst$B4; green = rst$B3; blue = rst$B2; NIR = rst$B5

# NDVI
NDVI <- (NIR - red)/(NIR + red) 
plot(NDVI)


ggR(NDVI, geom_raster = TRUE) +
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


# coon esto se cortó las imagenes
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

writeRaster(rstCrop,
            bylayer = T, 
            filename = paste0('datos/raster/L8_NDVI/', names(rstCrop), '.tif'), 
            format = 'GTiff')

