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

  ggplot(iris, mapping = aes(x = Sepal.Length, y = Petal.Length)) + 
  geom_point(colour = 'blue') +
  theme_bw()

# color por especie
iris %>% 
  ggplot(aes(x = Sepal.Length, y = Petal.Length, colour = Species)) +
  geom_point() +
  theme_bw() +
  labs(x = 'Longitud del Sépalo', 
       y = 'Longitud del Pétalo', colour = 'Especies')


# curva regresión lineal
iris %>% 
  ggplot(aes(x = Petal.Length, y = Petal.Width, color = Species)) +
  geom_point() +
  stat_smooth(method = 'lm') +
  labs(x = 'Longitud del Sépalo', y = 'Longitud del Pétalo') +
  theme_bw() +
  theme(legend.position = c(0.85, 0.2),
        panel.grid.minor = element_blank()) 

# boxplot  y facet
iris %>% 
  pivot_longer(cols = -Species) %>% 
  ggplot(aes(x = Species, y = value)) + 
  geom_boxplot() + facet_wrap(~name)


# graficar la lluvia media mensual ----------------------------------

# cargamos la precipitación mensual obtenida en el programa anterior
load('resultados/tablas/prc.mes.rds')


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
  # modificar el nombre del eje y
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



  # utilizando facets  
  ggplot(data = prc.mes) +
        geom_col(mapping = aes(x = mes, 
                           y = prcMes, 
                           fill = nombre),
             position = 'dodge') +  
   
    scale_x_continuous(name = '',
                       breaks = 1:12,
                       labels = month(1:12, label = T)) +
  
    scale_y_continuous(name = expression(paste('Preciptación (mm',' ', mes^-1, ')'))
    ) +
    scale_fill_manual(name = 'Estaciones', 
                      values = c('black', 'grey20', 'grey40', 'grey60')) +
    facet_wrap(~nombre) +
    
  theme_bw() +
    theme(legend.position = c(0.10, 0.80),
          panel.grid = element_blank()
    )
  
  ggsave(filename = 'prc.mes_facets.png', plot = last_plot(), 
         path = 'resultados/plots/', device = 'png',
         dpi = 600, width = 7, height = 5)
  

# datos millas
millas <- tibble(millas)

millas %>% 
  # cilindrada = tamaño del motor (litros)
  # autopista = eficiencia del vehículo (millas por galón en autopista)
  ggplot(aes(x = cilindrada, y = autopista)) +
  geom_point()


millas %>% 
# agregamos uan tercera variable
  ggplot(aes(x = cilindrada, y = autopista, colour = clase)) +
  geom_point()
  
# revisar https://exts.ggplot2.tidyverse.org/gallery/
# https://ggplot2.tidyverse.org/ 

