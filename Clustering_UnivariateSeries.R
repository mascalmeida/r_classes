# Estudo de caso - Series Univariadas

# Bibliotecas----
if(!require("readxl")) install.packages("readxl") ; library(readxl)
if(!require("caret")) install.packages("caret") ; library(caret)
if(!require("e1071")) install.packages("e1071") ; library(e1071)
if(!require("factoextra")) install.packages("factoextra") ; library(factoextra)
if(!require("cluster")) install.packages("cluster") ; library(cluster)
if(!require("dtwclust")) install.packages("dtwclust") ; library(dtwclust)
if(!require("reshape2")) install.packages("reshape2") ; library(reshape2)
if(!require("dplyr")) install.packages("dplyr") ; library(dplyr)
if(!require("ggpmisc")) install.packages("ggpmisc") ; library(ggpmisc)

# Importando dados ----

# Apontando para a pasta de trabalho
setwd("C:/Users/lukas/codes_old/R - Codes/Aulas - ENGD02/Compilado")

# Importando dados de falha
falhas <- read_excel("C:/Users/lukas/codes_old/R - Codes/Aulas - ENGD02/Compilado/data/dados_falha.xlsx", 
                     col_names = T)

# Importando dados de partida normal
normal <- read_excel("C:/Users/lukas/codes_old/R - Codes/Aulas - ENGD02/Compilado/data/dados_normal.xlsx", 
                     col_names = T)

# Juntando os dados
total <- cbind(falhas[2:length(falhas)], normal[2:length(normal)])

# Normalizando os dados ----

# Funcao que normaliza os dados Max = 1 e Min = 0
normalizando <- function(x)
{
  return((x- min(x)) /(max(x)-min(x)))
}

# Dados totais
dados_t <- normalizando(total)
T_dados_t <- as.data.frame(t(dados_t))

# Comportamento geral das turbinas----

g.total <- dados_t %>% 
  cbind(falhas$Instantes) %>% 
  melt(id.vars = "falhas$Instantes") %>% 
  mutate(tempo = `falhas$Instantes`) %>% 
  select(-`falhas$Instantes`) %>% 
  ggplot(mapping = aes(x = tempo, y = value)) +
  geom_line(mapping = aes(color = variable), size = 0.75) +
  theme_light() +
  labs(title = "Comportamento da temperatura da turbina de todas as partidas",
       x = "Tempo (minutos)", y = "Temperatura",
       subtitle = "Obs: Dados normalizados") +
  theme(legend.position="none") +
  geom_smooth(method = "loess", se = TRUE, color = "black", size = 1.5, linetype = 5)
g.total

g.div <- dados_t %>% 
  cbind(falhas$Instantes) %>% 
  melt(id.vars = "falhas$Instantes") %>% 
  mutate(tempo = `falhas$Instantes`, 
         operacao = ifelse(grepl("Falha", variable) == T, "Falha", "Normal")) %>% 
  mutate(operacao = factor(operacao, levels = c("Normal", "Falha"))) %>% 
  select(-`falhas$Instantes`) %>% 
  ggplot(mapping = aes(x = tempo, y = value)) +
  geom_line(mapping = aes(color = variable), size = 0.75) +
  theme_light() +
  labs(title = "Comportamento da temperatura da turbina de todas as partidas",
       x = "Tempo (minutos)", y = "Temperatura",
       subtitle = "Obs: Dados normalizados") +
  theme(legend.position="none") +
  facet_wrap(facets = ~operacao, nrow = 1) +
  geom_smooth(method = "loess", se = TRUE, color = "black", size = 1.5, linetype = 5)
g.div

# Letra (a)----

# Aplicando FCM - 2 grupos (Distancia Euclidiana)
d_a_2 <- fanny(T_dados_t, k = 2, metric = "euclidean", stand = FALSE)

fviz_cluster(list(data = T_dados_t, cluster=d_a_2$cluster), 
             ellipse.type = "norm",
             #ellipse.level = 0.68,
             palette = "jco",
             ggtheme = theme_light())

fviz_silhouette(d_a_2, palette = "jco",
                ggtheme = theme_light())

d1 <- dados_t %>% 
  cbind(falhas$Instantes) %>% 
  melt(id.vars = "falhas$Instantes") %>% 
  mutate(tempo = `falhas$Instantes`, 
         operacao = ifelse(grepl("Falha", variable) == T, "Falha", "Normal")) %>% 
  select(-`falhas$Instantes`) %>% 
  mutate(operacao = factor(operacao, levels = c("Normal", "Falha")))

d2 <- as.data.frame(t(d_a_2$clustering)) %>% 
  melt() %>% 
  mutate(op = ifelse(grepl("Normal", variable) == T, 1, 2))

dt.1 <- left_join(d1, d2, by = c("variable")) %>% 
  mutate(temperatura = value.x, grupo = value.y) %>% 
  select(-value.x, -value.y) %>% 
  mutate(grupo = ifelse(grupo == 1, 3, grupo), 
         grupo = ifelse(grupo == 2, 1, 2))

g.a.1 <- dt.1 %>% 
  ggplot(mapping = aes(x = tempo, y = temperatura)) +
  geom_line(mapping = aes(color = variable), size = 0.75) +
  theme_light() +
  labs(title = "Comportamento da turbina agrupado por FCM",
       x = "Tempo (minutos)", y = "Temperatura",
       subtitle = "Distâncias euclidianas e 2 grupos") +
  theme(legend.position="none") +
  geom_smooth(method = "loess", se = TRUE, color = "black", size = 1.5, linetype = 5) +
  facet_wrap(facets = ~grupo, nrow = 1)
g.a.1

# Aplicando FCM - 3 grupos (Distancia Euclidiana)
d_a_3 <- fanny(T_dados_t, k = 3, metric = "euclidean", stand = FALSE)

fviz_cluster(list(data = T_dados_t, cluster=d_a_3$cluster), 
             ellipse.type = "norm",
             #ellipse.level = 0.68,
             palette = "jco",
             ggtheme = theme_light())

fviz_silhouette(d_a_3, palette = "jco",
                ggtheme = theme_light())

d3 <- as.data.frame(t(d_a_3$clustering)) %>% 
  melt()

dt.2 <- left_join(d1, d3, by = c("variable")) %>% 
  mutate(temperatura = value.x, grupo = value.y) %>% 
  select(-value.x, -value.y) %>% 
  mutate(grupo = ifelse(grupo == 3, 4, grupo),
         grupo = ifelse(grupo == 1, 3, grupo),
         grupo = ifelse(grupo == 4, 1, grupo))

g.a.2 <- dt.2 %>% 
  ggplot(mapping = aes(x = tempo, y = temperatura)) +
  geom_line(mapping = aes(color = variable), size = 0.75) +
  theme_light() +
  labs(title = "Comportamento da turbina agrupado por FCM",
       x = "Tempo (minutos)", y = "Temperatura",
       subtitle = "Distâncias euclidianas e 3 grupos") +
  theme(legend.position="none") +
  geom_smooth(method = "loess", se = TRUE, color = "black", size = 1.5, linetype = 5) +
  facet_wrap(facets = ~grupo, nrow = 1)
g.a.2

# Letra (b)----

# Aplicando FCM usando dtw para 2 grupos
d_dtw.1 <- tsclust(series = T_dados_t, type = "fuzzy", k = 2L, distance = "dtw", centroid = "fcm")
pb.1 <- plot(d_dtw.1)

d2.b <- as.data.frame(t(d_a_2$clustering)) %>% 
  rbind(d_dtw.1@cluster) %>% 
  slice(-1) %>% 
  melt() %>% 
  mutate(op = ifelse(grepl("Normal", variable) == T, 1, 2))

dt.1.b <- left_join(d1, d2.b, by = c("variable")) %>% 
  mutate(temperatura = value.x, grupo = value.y) %>% 
  select(-value.x, -value.y)

g.b.1 <- dt.1.b %>% 
  ggplot(mapping = aes(x = tempo, y = temperatura)) +
  geom_line(mapping = aes(color = variable), size = 0.75) +
  theme_light() +
  labs(title = "Comportamento da turbina agrupado por FCM",
       x = "Tempo (minutos)", y = "Temperatura",
       subtitle = "DTW e 2 grupos") +
  theme(legend.position="none") +
  geom_smooth(method = "loess", se = TRUE, color = "black", size = 1.5, linetype = 5) +
  facet_wrap(facets = ~grupo, nrow = 1)
g.b.1

# Aplicando FCM usando dtw para 3 grupos
d_dtw.2 <- tsclust(series = T_dados_t, type = "fuzzy", k = 3L, distance = "dtw", centroid = "fcm")
pb.2 <- plot(d_dtw.2)

d3.b <- as.data.frame(t(d_a_2$clustering)) %>% 
  rbind(d_dtw.2@cluster) %>% 
  slice(-1) %>% 
  melt()

dt.2.b <- left_join(d1, d3.b, by = c("variable")) %>% 
  mutate(temperatura = value.x, grupo = value.y) %>% 
  select(-value.x, -value.y) %>% 
  mutate(grupo = ifelse(grupo == 3, 4, grupo),
         grupo = ifelse(grupo == 1, 3, grupo),
         grupo = ifelse(grupo == 4, 1, grupo))

g.b.2 <- dt.2.b %>% 
  ggplot(mapping = aes(x = tempo, y = temperatura)) +
  geom_line(mapping = aes(color = variable), size = 0.75) +
  theme_light() +
  labs(title = "Comportamento da turbina agrupado por FCM",
       x = "Tempo (minutos)", y = "Temperatura",
       subtitle = "DTW e 3 grupos") +
  theme(legend.position="none") +
  geom_smooth(method = "loess", se = TRUE, color = "black", size = 1.5, linetype = 5) +
  facet_wrap(facets = ~grupo, nrow = 1)
g.b.2

# Comparando----

dx.a <- confusionMatrix(table(d2$value, d2$op))

dx.a <- as.data.frame(t(dx.a$byClass)) %>% 
  melt()

dx.b <- confusionMatrix(table(d2.b$value, d2.b$op))

dx.b <- as.data.frame(t(dx.b$byClass)) %>% 
  melt() %>% 
  left_join(dx.a, by = "variable") %>% 
  rename("index" = variable, "DTW" = value.x, "Euclidean" = value.y) %>% 
  melt() %>% 
  rename("Method" = variable)

g.compare.1 <- ggplot(dx.b) +
  geom_point(mapping = aes(x = index, y = value, color = Method), size = 5, alpha = 0.6) +
  theme_light() +
  labs(title = "Comparing: DTW vs Euclidean",
       x = "", y = "Value") +
  theme(legend.position="top")
g.compare.1

confusionMatrix(table(d2.b$value, d2.b$op))$overall



