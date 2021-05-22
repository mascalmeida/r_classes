# Apontando para a pasta de trabalho

setwd("C:/Users/lukas/codes_old/R - Codes/Aulas - ENGD02/Compilado")

# Chamando biblioteca, se ainda nao estiver instalada use, ex: install.packages("ggplot2")

if(!require("readxl")) install.packages("readxl") ; library(readxl)
if(!require("dplyr")) install.packages("dplyr") ; library(dplyr)
if(!require("ggplot2")) install.packages("ggplot2") ; library(ggplot2)

# Conceitos basicos----

# Criando um vetor

vetor = c(8, 10, 15, 35, 40, 3, 19, 10, 34, 7)

## Medidas de localizacao

media <- mean(vetor)
mediana <- median(vetor)
quartil <- quantile(vetor)
resumo <- summary(vetor)

## Medidas de variabilidade

desvio <- sd(vetor)
variancia <- var(vetor)
CV <- (desvio/media)*100

# Importando banco de dados----

dados <- read_excel("C:/Users/lukas/codes_old/R - Codes/Aulas - ENGD02/Compilado/data/EconomistData.xlsx",col_types = c("text", "numeric", "numeric", "numeric", "text"))

# representacao grafica----

## Histograma

par(mfrow = c(2,1))

hist(dados$HDI, main = "IDH", xlab = "Concentração", ylab = "Frequência")
hist(dados$CPI, main = "CPI", xlab = "Concentração", ylab = "Frequência")

## Box-plot

par(mfrow = c(1,2))

boxplot(dados$HDI, main = "IDH")
boxplot(dados$CPI, main = "CPI")

## Dispersao

par(mfrow = c(1,1))

plot(dados$CPI, dados$HDI, main = "IDH vs. IPC", xlab = "IPC", ylab = "IDH", type = "p")

# Manipulando e Exportando dados----

## Usando dplyr

dados_exp <- dados %>% 
  group_by(Region) %>% 
  mutate(M.CPI = mean(CPI), M.HDI = mean(HDI), Var.CPI = var(CPI)) %>% 
  select(Region, M.CPI, M.HDI, Var.CPI, Country) %>% 
  filter(M.CPI < 4.5)

## Exportando dados

write.csv2(x = dados_exp, file = "dados_paises.csv")

# Representacao grafica (ggplot2)----

gg.1 <- ggplot(data = dados, mapping = aes(x = CPI, y = HDI)) +
  geom_point(mapping = aes(color = Region, size = HDI.Rank))

gg.1

gg.2 <- ggplot(data = dados, mapping = aes(x = CPI, y = HDI)) +
  geom_point(mapping = aes(color = HDI.Rank)) +
  facet_wrap(facets = ~Region, nrow = 2) +
  geom_smooth(method = "lm") +
  theme_light()

gg.2

# Salvando os graficos

ggsave(filename = "grafico1.png", plot = gg.1, width = 13, height = 7, dpi = 500)