# Intalação de Pacotes
if (!require("raster")) install.packages("raster", repos = "http://cran.us.r-project.org")
if (!require("maptools")) install.packages("maptools", repos = "http://cran.us.r-project.org")
# Carregar Pacotes
packs <- c(
    "raster", "maptools"
)
lapply(packs, require, character.only = TRUE)

# Carregar Funções
source("funcoes.R")


anos <- c("2018", "2019", "2020", "2021", "2022")
meses <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)


# selecionar o pixel de interesse
pixel <- 95

#parametro ano corresponde a pasta com os arquivo
#laço para plotar as series temporais: ano, meses e pixel
for (ano in anos) {
    plot_temporal_series(ano, meses, pixel)
}
