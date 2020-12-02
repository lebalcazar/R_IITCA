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
