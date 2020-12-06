# gplot2 
# gramática de gráficos
# gráficos de alta calidad 

library(ggplot2)
library(magrittr)
library(lubridate)
library(gridExtra)
library(datos)
library(rworldxtra)


# plots base --------------------------------------------------------------
# R tiene los siguientes motores de graficación: base (plot, hist, boxplot, 
# barplot),y lattice y/o ggplot


# graficos base 
plot <- plot(Sepal.Length ~ Petal.Length, data = iris,
             main = 'Pétalo vs Sépalo', 
             xlab = 'Longitud del Sépalo', ylab = 'Longitud del Pétalo', 
             col = 'blue', 
             type = 'p', pch = 16)

# ggplot2 -----------------------------------------------------------------
# gramática de gráficos
# revisar https://exts.ggplot2.tidyverse.org/gallery/
# https://ggplot2.tidyverse.org/ 


iris %>% 
  ggplot(aes(x = Sepal.Length, y = Petal.Length)) +
  geom_point(colour = 'blue')

iris %>% 
  ggplot(aes(x = Sepal.Length, y = Petal.Length, colour = Species)) +
  geom_point() +
  theme_bw() +
  labs(x = 'Longitud del Sépalo', y = 'Longitud del Pétalo', colour = 'Especies')

iris %>% 
  ggplot(aes(x = Sepal.Length, y = Petal.Length, color = Species)) +
  geom_point() +
  stat_smooth(method = 'lm', se = F) +
 

  #scale_color_ordinal(guide = guide_legend()) 
  guides(color = guide_legend(
    title = 'Especies',
    title.theme = element_text(vjust = 0.5,
                               size = 10,
                               face = "bold",
                               colour = "black"))) +
 
  theme_bw() +
  theme(legend.position = c(0.85, 0.2),
        panel.grid.minor = element_blank()) +
 
  labs(x = 'Longitud del Sépalo', y = 'Longitud del Pétalo')



# histograma con la lluvia media mensual

# cargamos la precipitación mensual obtenida en el programa anterior
load('resultados/tablas/prc.mes.rds')

    # aquí empieza ggplot2. Toma los datos de prc.mes como entrada
ggplot(data = prc.mes) +
  # para que no se apilen las columnas utilizamos posición 'dodge'
  geom_col(mapping = aes(x = mes, 
                         y = prcMes, 
                         fill = nombre),
           position = 'dodge') +  
  # se modifican las escalas "x", "y", y "fill", relleno de las columnas  
  scale_x_continuous(name = '',
                     breaks = 1:12,
                     labels = month(1:12, label = T)) +
  scale_y_continuous(name = expression(paste('Preciptación (mm',' ', mes^-1, ')'))
  ) +
  scale_fill_manual(name = 'Estaciones', 
                    values = c('black', 'grey20', 'grey40', 'grey60')) +
  # modica la ubicación de la leyenda y elimina el las lineas del plot
  theme_bw() +
  theme(legend.position = c(0.20, 0.70),
        panel.grid = element_blank()
  )
  
# guardar 
ggsave('resultados/plots/prc.mes.png')  
 
# guardar con especificaiones 
  ggsave(filename = 'prc.mes2.png', plot = last_plot(), 
         path = 'resultados/plots/', device = 'png',
         dpi = 600, width = 4, height = 3)


# trabajaremos con los datos millas
millas <- millas
millas %>% 
  # cilindrada = tamaño del motor (litros)
  # autopista = eficiencia del vehículo (millas por galón en autopista)
  ggplot(aes(x = cilindrada, y = autopista)
  ) +
  geom_point()


millas %>% 
# agregamos uan tercera vsariable
  ggplot(aes(x = cilindrada, y = autopista, colour = clase)
  ) +
  geom_point()
  
  
  
df2 <- data.frame(sex = rep(c("Female", "Male"), each=3),
                  time=c("breakfeast", "Lunch", "Dinner"),
                  bill=c(10, 30, 15, 13, 40, 17) )

ggplot(df2, aes(x=time, y=bill, group=sex)) +
  geom_line(aes(linetype=sex))+
  geom_point()+
  scale_linetype_manual(values=c("twodash", "dotted"))+
  theme(legend.position="top")  

# Line plot with multiple groups
ggplot(data=df2, aes(x=time, y=bill, group=sex)) +
  geom_line()+
  geom_point()
# Change line types
ggplot(data=df2, aes(x=time, y=bill, group=sex)) +
  geom_line(linetype="dashed")+
  geom_point()

# Change line colors and sizes
ggplot(data=df2, aes(x=time, y=bill, group=sex)) +
  geom_line(linetype="dotted", color="red", size=2)+
  geom_point(color="blue", size=3)

ggplot(df2, aes(x=time, y=bill, group=sex)) +
  geom_line(aes(linetype=sex))+
  geom_point()+
  theme(legend.position="top")
# Change line types + colors
ggplot(df2, aes(x=time, y=bill, group=sex)) +
  geom_line(aes(linetype=sex, color=sex))+
  geom_point(aes(color=sex))+
  theme(legend.position="top")

# Set line types manually
ggplot(df2, aes(x=time, y=bill, group=sex)) +
  geom_line(aes(linetype=sex))+
  geom_point()+
  scale_linetype_manual(values=c("twodash", "dotted"))+
  theme(legend.position="top")
# Change line colors and sizes
ggplot(df2, aes(x=time, y=bill, group=sex)) +
  geom_line(aes(linetype=sex, color=sex, size=sex))+
  geom_point()+
  scale_linetype_manual(values=c("twodash", "dotted"))+
  scale_color_manual(values=c('#999999','#E69F00'))+
  scale_size_manual(values=c(1, 1.5))+
  theme(legend.position="top")




# mapas con ggplot --------------------------------------------------------

# cargar un raster de altitud (MNA) África occidental
alt <- raster('datos/raster/DEM/alt100m.tif')
plot(alt)


# leer coordenadas de estaciones meteo
estMet <- read.csv('datos/tabular/est.csv') %>% 
  st_as_sf(coords = c('x','y'), 
           crs = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0')

# adjuntar los puntos al DEM
plot(estMet, add = T, 
     type = 'p', pch = 16, col = 'blue')



# cargar poligino de datos globales 
data("countriesHigh")
names(countriesHigh)

# convertir a simple feature
mundo <- sf::st_as_sf(countriesHigh)

# seleccionar la región de Africa Occidental 
westAfr <- mundo %>% 
  filter(GEO3 == 'Western Africa') 

# plotear la región
plot(westAfr$geometry)

# vector de la cuenca 
cncBafing <- st_read('datos/vector/cncBafing.shp')
plot(cncBafing, add = T, col = 'red')

# vector de rio
rioSenegal <- st_read('datos/vector/rioSenegal.shp')
plot(rioSenegal, add = T, col = 'blue')

# convertir a puntos 
alt_points <- rasterToPoints(alt) %>% data.frame()


mapaWestAfr <-  ggplot() + 
  # polígono de Africa occidental
  geom_sf(data = westAfr) +
  # raster del DEM agregado ~1km
  geom_tile(data = alt_points, aes(x, y, fill = alt100m)) +
  # polígono de la cuenca Bafing Makana
  geom_sf(data = cncBafing, aes(colour = 'Cuenca'), fill = 'red', #alpha = 0,
          show.legend = 'polygon') +
  
  geom_sf(data = rioSenegal, aes(colour = 'Río'), 
          show.legend = 'line') +
  geom_sf(data = estMet, aes(colour = 'Estaciones'), 
          show.legend = 'point') +
  
  scale_colour_manual(values = c('Cuenca' = 'red', 'Río' = 'blue', 
                                 'Estaciones' = 'green'), 
                      guide = guide_legend(override.aes = 
                                             list(linetype = c(1, 0, 1),
                                                  shape = c(NA, 16, NA),
                                                  fill = c('red', NA, NA)))) +
  
  # cambio de color en el raster (color de terreno)
  scale_fill_gradientn(colours = grDevices::terrain.colors(10),
                       breaks = round(seq(min(alt_points$alt100m),
                                          max(alt_points$alt100m),
                                          by = 400),
                                      0)) +
  # guides( fill = guide_legend()) +
  labs(x = '', y = '', 
       fill = 'msnm',
       title = 'Africa Occidental',
       colour = '') +
  ggsn::north(data = westAfr, symbol = 16) +
  ggsn::scalebar(data = westAfr, dist = 250, dist_unit = 'km', st.size = 2, 
                 transform = T, model = 'WGS84',location = 'bottomright') +
  theme_bw() +
  theme(panel.grid = element_line(colour = 'grey75'),
        panel.ontop = T, panel.background = element_rect(color = NA, fill = NA)) + 
  theme(legend.position = 'bottom',
        legend.background = element_blank(),
        legend.direction = 'horizontal') 

mapaWestAfr

# guardar el mapa
ggsave(filename = 'mapaWestAfr.png', 
       plot = mapaWestAfr, 
       device = 'png',
       path = 'resultados/mapas/',
       width = 18, height = 16, units = 'cm', dpi = 900)


# tribble -----------------------------------------------------------------

people <- tribble(
  ~Name,
  'Mark Gindas',
  'Dave Smith',
  'Jackie Doe'
)
people
str(people)

people2 <- people %>% 
  separate(Name, into = c('FIRST', 'LAST'), sep = ' ')

people3 <- people2 %>% 
  unite(col = 'Nombre completo', FIRST, LAST, sep = ' ', remove = FALSE)












# expresiones regulares ---------------------------------------------------
library(stringr)

correo <- c('Luis Bal le.bal@gmail.com', 'Pablito P pal_@hotmail.com', 'Juan A jp-radio@yahoo.com')
str_extract(string = correo, pattern = "[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\\.[a-zA-Z]+")

texto <- sprintf('las camisas blanc@s pueden ser muy ensuciables el son mal0s resultad@s. 
                 Miestras que las otras camisas son de buena calidad')

str_extract(texto, pattern = '[a-zA-Z]+@[a-zA-Z]')

str_extract_all(texto, pattern = '[^a-z]+')

