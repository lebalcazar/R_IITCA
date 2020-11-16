# Sistemas de Información Geográfica con R
# 
# SIG --------------------------------------------

librerias <- (c("RgoogleMaps", "ggmap", "mapproj", "sf", "osmar", "tidyverse","RColorBrewer",
                 "dplyr", "OpenStreetMap", "devtools", "DT", "raster", "rgdal", "rworldxtra",
                'grDevices', 'ggsn', 'tmap', 'utils', 'viridis', 'RColorBrewer', 'RSAGA', 'cptcity'))
lapply(librerias, function(x) require(x, character.only = T))
 

# cargar un raster de altitud (MNA)
# alt <- raster('D:/tesisT/datos/Alt.rst')
# plot(alt)

# descargar datos
alt2 <- getData(name = 'SRTM', lon = -11, lat = 11, download = T, 
                path = 'resultados')

alt10 <- raster::aggregate(alt, fact = 10, fun = mean)


# # area de estudio (AE)
r <- raster(ext = extent(-13, -9,  10, 13), 
            res = c(0.25, 0.25)
)
values(r) <- 1:ncell(r)
r <- projectRaster(r, crs= "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# cortar DEM para AE
altCnc <- crop(alt10, r)
paleta <- grDevices::colorRampPalette(c('black', 'white'),7)
plot(altCnc, col = paleta(7))
plot(altCnc, col = brewer.pal(7, 'Greys'))

# guaradar DEM alt cuenca 
# writeRaster(x = altCnc, 
#             filename = 'D://r-curso-IITCA/datos/altCnc.tif')

alt_points <- rasterToPoints(altCnc) %>% data.frame()
# alt_points <- altCnc %>% as('SpatialPixelsDataFrame') %>% as.data.frame()

#altCnc.df <- data.frame(alt_points)


# poligono <- rasterToPolygons(r) %>% st_as_sf
# plot(poligono, add = T, crs= "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

#  leer coordenadas de estaciones meteo
estMet <- read.csv('D:/tesisT/datos/base_datos_africa/sinopticas.csv') %>% 
  dplyr::select('x', 'y', 'name') %>% 
  st_as_sf(coords = c('x','y'), 
           crs = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0')
# plot(estMet, add = T)
# plot(p, add = T)


# cargar poligino de datos globales 
data("countriesHigh")

# convertir a simple feature
mundo <- sf::st_as_sf(countriesHigh)

westAfr <- mundo %>% 
  filter(GEO3 == 'Western Africa') 

# vector de la cuenca 
cncBafing <- st_read('D:/r-curso-IITCA/datos/cncBafing.shp')

# vector de rio
rioSenegal <- st_read('datos/rioSenegal.shp')

mapaWestAfr <- ggplot() + 
  geom_sf(data = westAfr) +
  geom_tile(data = alt_points, aes(x, y, fill = Alt)) +
  geom_sf(data = cncBafing, colour = 'red', alpha = 0) +
  scale_fill_gradientn(colours = grDevices::terrain.colors(10),
                       breaks = round(seq(min(alt_points$Alt),
                                          max(alt_points$Alt),
                                          by = 400),0)) +
  guides(fill = guide_legend()) +
    # geom_sf(data = poligono, colour = 'red', alpha = 0) +
  geom_sf(data = rioSenegal, colour = 'blue') +
  geom_sf(data = estMet, colour = 'blue') +
  labs(x = '', y = '', 
       fill = 'msnm',
       title = 'Africa Occidental') +
  north(data = westAfr, symbol = 16) +
  scalebar(westAfr, dist = 250, dist_unit = 'km', st.size = 4,
           transform = T, model = 'WGS84',location = 'bottomright',) +
  # theme_bw() +
  dark_theme_bw() +
  theme(panel.grid = element_line(colour = 'grey75'),
        panel.ontop = T, panel.background = element_rect(color = NA, fill = NA)) +
  theme(legend.position = c(0.08, 0.16),
        legend.background = element_blank(),
        legend.direction = 'vertical') 
  

ggsave(filename = 'mapaWestAfr_dark.png', 
       plot = mapaWestAfr, 
       device = 'png',
       path = '../resultados',
       width = 18, height = 16, units = 'cm', dpi = 300)




# hidrología --------------------------------------------------------------

install.packages('nhdplusTools')
library(nhdplusTools) 
library(sf)

start_point <- st_sfc(st_point(c(-10.27886, 12.49721)), 
                      crs = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0')

start_comid <- discover_nhdplus_id(start_point)


flowline <- navigate_nldi(list(featureSource = "comid",
                               featureID = start_comid),
                          mode = "upstreamTributaries",
                          distance_km = 1000)



options(download.file.method = 'libcurl')
install.packages('topmodel', depedences = T)
install.packages("Hmisc")
library(topmodel)
library(Hmisc)

data('huagrahuma', package = 'topmodel')


# conectado RSAGA a R -----------------------------------------------------

# dem <- raster('../datos/altCnc.tif')
# writeRaster(dem,'../datos/demGrid.sgrd', overwrite=TRUE)

# nuevo srtm
prj_iqualArea <- '+proj=laea +lon_0=-8.0859375 +lat_0=0 +datum=WGS84 +units=m +no_defs'

dem <- getData(name = 'SRTM', lon = -11, lat = 11)
dem.iqualArea <- projectRaster(dem, crs = prj_iqualArea)

# # area de estudio (AE)
r <- raster(ext = extent(-13, -9,  10, 13), 
            res = c(0.25, 0.25)
)

values(r) <- 1:ncell(r)
r <- projectRaster(r, crs= prj_iqualArea)

# cortar DEM para AE
dem.crop <- crop(dem.iqualArea, r)

# proyeccion utm EPSG:32629
utm29n <- '+proj=utm +zone=29 +ellps=WGS84 +datum=WGS84 +units=m +no_defs' 
demUtm <- projectRaster(dem.crop, crs = utm29n) 
demUtm <- demUtm2
demUtm
#
raster::res(demUtm) <- c(100,100)
extent(demUtm) <- c(xmin = 33440, xmax = 394340, ymin = 1104700, ymax = 1469100)
ncol(demUtm) <- 3609
nrow(demUtm) <- 3644
ncell(demUtm) <- 13151196

demUtm

#







writeRaster(demUtm, filename = '../resultados/demUtm.crop.tif', overwrite = T)

# rellenar huecos 
rsaga.fill.sinks(in.dem = '../resultados/demUtm.crop.tif',
                 out.dem = '../resultados/DEM_fill')

# visualizacion del dem corregido
tmap_mode('view')
raster('../resultados/') %>% 
  tm_shape() + 
  tm_basemap('Esri.WorldTopoMap') +
  tm_raster(style = 'cont',alpha = 0.75,
            palette = cpt(pal = 'ncl_topo_15lev'))




# cclAfr <- '+proj=lcc +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs'
# demCcl <- projectRaster(dem_proj, crs = cclAfr) 
# plot(demCcl, col = rainbow(16))




# localizar el saga-cmd
env <- rsaga.env()

# librerias de saga
rsaga.get.libraries()

# todas las funciones 
fun.saga <- rsaga.get.modules(lib = lib.saga, env = env) %>% 
  bind_rows(.id = 'libreria') %>% as.tibble()

# funciones de rsaga
modulos.saga <- rsaga.get.lib.modules('ta_preprocessor', env = env)

rsaga.get.usage(lib = 'ta_preprocessor', module = 4)
rsaga.get.usage('ta_preprocessor', module = 4)


rsaga.fill.sinks(in.dem = '../datos/demGrid.sgrd', 
                 minslope = 0.1,
                 out.dem = "../resultados/dem_new", 
                 method = 'planchon.darboux.2001')

raster('../resultados/dem_new.sdat') %>% qtm()


# hillshade
rsaga.hillshade(in.dem = 'D://r-curso-IITCA/resultados/demWestAfrUtm.grd', 
                out.grid = "../resultados/hillshade_2x",
                exaggeration = 4)

# hillshade
rsaga.hillshade(in.dem = '../datos/demGrid.sgrd', 
                out.grid = "../resultados/hillshade",
                exaggeration = 4)

raster('../resultados/hillshade.sdat') %>% qtm()
plot('../resultados/hillshade.sdat')


rsaga.geoprocessor(lib = "ta_morphometry", module = "Slope, Aspect, Curvature",
                   param = list(ELEVATION = paste(getwd(),"../resultados/dem_new.sgrd", sep = ""), 
                                SLOPE = paste(getwd(),"/slope.sgrd", sep = "")),
                   env = env)

rsaga.slope(in.dem = "dem", out.slope = "slope", env = env)
