

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
