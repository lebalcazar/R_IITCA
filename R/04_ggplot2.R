# gplot2 
# gramática de gráficos
# gráficos de alta calidad 

library(ggplot2)
library(magrittr)
library(lubridate)

# plots base --------------------------------------------------------------

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
prc.mes %>% 
  group_by(nombre, mes) %>% 
  summarise(prc_mes_Med = mean(prcSum, na.rm = T)) %>% 
  ggplot(aes(x = mes, y = prc_mes_Med, fill = nombre)) +
  geom_col(position = 'dodge') +  
  scale_x_continuous(breaks = 1:12,
                     labels = month(1:12, label = T))






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

