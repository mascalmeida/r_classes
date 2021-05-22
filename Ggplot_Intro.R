############################################################################################################################

########################################## ENGD02 ##########################################################################

############################################################################################################################

# Apontando para a pasta de trabalho

setwd("C:/Users/lukas/codes_old/R - Codes/Aulas - ENGD02/Compilado")

########################################## Library #########################################################################

# Chamando biblioteca, se ainda nao estiver instalada use, ex: install.packages("ggplot2")

if(!require("ggplot2")) install.packages("ggplot2") ; library(ggplot2)  
if(!require("ggrepel")) install.packages("ggrepel") ; library(ggrepel)
if(!require("ggExtra")) install.packages("ggExtra") ; library(ggExtra)
if(!require("gridExtra")) install.packages("gridExtra") ; library(gridExtra)
if(!require("plotly")) install.packages("plotly") ; library(plotly)

########################################### Data ###########################################################################

# Importando dados do tipo .csv

EconomistData <- read.csv("C:/Users/lukas/codes_old/R - Codes/Aulas - ENGD02/Compilado/data/EconomistData.csv")

########################################## Pacote Básico ###################################################################

# Grafico de dispersao usando a funcao residente 'plot()'

plot(x = EconomistData$CPI, y = EconomistData$HDI, 
     xlab = "CPI", ylab = "HDI")

########################################## Usando ggplot ###################################################################

# Gráfico de Dispersão

gdisp1 <- ggplot(EconomistData, mapping = aes(x = CPI, y = HDI)) +                        # Mapeando as variaveis
  geom_point(aes(color = Region, size = HDI.Rank),alpha = 0.8) +                          # Graficos de dispersao
  scale_color_manual(values = c("peru","gold","green","darkblue","hotpink3","red4")) +    # Definindo as cores de color
  xlab("Índice de Percepção da Corrupção") +                                              # Nomeando a Ox
  ylab("Índice de Desenvolvimento Humano") +                                              # Nomeando Oy
  geom_text_repel(aes(label = Country))                                                   # Adicionando os nomes

gdisp2 <- ggplot(EconomistData, mapping = aes(x = CPI, y = HDI)) +
  geom_point(aes(color = HDI.Rank, shape = Region), size = 3) +                           # Adicionando simbolos
  geom_text_repel(aes(label = Country)) +
  xlab("Índice de Percepção da Corrupção") + 
  ylab("Índice de Desenvolvimento Humano")

gdisp3 <- ggplot(EconomistData, mapping = aes(x = CPI, y = HDI)) +
  geom_point(aes(color = HDI.Rank), size = 3) +
  geom_text_repel(aes(label = Country)) +
  facet_wrap(~Region, ncol = 3) +                                                         # Dividindo por região
  xlab("Índice de Percepção da Corrupção") + 
  ylab("Índice de Desenvolvimento Humano")

gdisp <- grid.arrange(gdisp1, gdisp2, gdisp3, nrow = 3)                                   # Colocando todos juntos

ggsave(filename = "gdisp.jpeg", gdisp,                                                    # Salvando grafico
       width = 13, height = 21, dpi = 300)

# Graficos combinados

gcurve <- ggplot(EconomistData, mapping = aes(x = CPI, y = HDI)) +
  geom_point(aes(color = HDI.Rank), size = 1) +
  geom_rug(col="steelblue",alpha=0.5, size=1.5) +                                         # Adicionando rug
  xlab("Índice de Percepção da Corrupção") + 
  ylab("Índice de Desenvolvimento Humano") +
  facet_wrap(~Region, ncol = 3) +
  geom_smooth(method = "lm", se = TRUE)                                                   # Adicionando curva de ajuste

gcurve2 <- ggplot(EconomistData, mapping = aes(x = CPI, y = HDI)) +
  geom_point(aes(color = Region, size = HDI.Rank),alpha = 0.8) +
  xlab("Índice de Percepção da Corrupção") + 
  ylab("Índice de Desenvolvimento Humano") +
  geom_smooth(method = "lm", se = TRUE) +
  geom_rug(col="steelblue",alpha=0.1, size=1.5) +
  theme(legend.position="none") +                                                         # Tirando as legendas
  coord_flip()                                                                            # Trocando eixos

gcmb <- ggMarginal(gcurve2, type="boxplot", color="black", size=4)                        # Adicionando boxplot

gHDI <- ggplot(EconomistData, mapping = aes(x = HDI)) +
  geom_histogram(color = "black", fill = "paleturquoise", bins = 30) +                    # Criando histograma
  geom_density(kernel = "gaussian", size = 1)  +                                          # Adicionando grafico de densidade
  xlab("Índice de Desenvolvimento Humano") + 
  ylab("Frequência")

gCPI <- ggplot(EconomistData, mapping = aes(x = CPI)) +
  geom_histogram(color = "black", fill = "palegreen", bins = 30) +
  geom_density(kernel = "gaussian", size = 1) +
  xlab("Índice de Percepção da Corrupção") + 
  ylab("Frequência")

graph <- grid.arrange(gcmb, arrangeGrob(gCPI, gHDI, ncol=2), nrow = 2)                             # Colocando todos juntos

ggsave(filename = "graph.jpeg", graph,                                                    # Salvando grafico
       width = 13, height = 14, dpi = 300)

########################################## Extra - leaflet ################################################################

if(!require("readxl")) install.packages("readxl") ; library(readxl)
if(!require("tidyr")) install.packages("tidyr") ; library(tidyr)
if(!require("dplyr")) install.packages("dplyr") ; library(dplyr)
if(!require("leaflet")) install.packages("leaflet") ; library(leaflet)

## Importando dados
dados_et <- read_excel("C:/Users/lukas/codes_old/R - Codes/Aulas - ENGD02/Compilado/data/ovni.xlsx", 
                       col_types = c("date", "text", "text", 
                                     "text", "text", "numeric", "text", 
                                     "text", "date", "numeric", "numeric"))

## manipulando
d_ovni <- dados_et %>% 
  select(datetime, city, state, country, shape, latitude, longitude) %>%
  separate(col = datetime, into = c("Data", "Hora"), sep = "\\ ") %>% 
  filter(shape == "disk" & state == "tx") %>% 
  na.omit() %>% 
  mutate(lat = latitude/10000000, lon = longitude/10000000)

## leaflet
leaflet(data = d_ovni) %>% 
  addTiles() %>%              # Add default OpenStreetMap map tiles
  addMarkers(~lon, ~lat, popup = ~shape, clusterOptions = markerClusterOptions())
