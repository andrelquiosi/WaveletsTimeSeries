# Intalação de Pacotes
if (!require("rgdal")) install.packages("rgdal", repos = "http://cran.us.r-project.org")
if (!require("raster")) install.packages("raster", repos = "http://cran.us.r-project.org")
if (!require("sp")) install.packages("sp", repos = "http://cran.us.r-project.org")
if (!require("maptools")) install.packages("maptools", repos = "http://cran.us.r-project.org")
if (!require("rworldmap")) install.packages("rworldmap", repos = "http://cran.us.r-project.org")
if (!require("rgeos")) install.packages("rgeos", repos = "http://cran.us.r-project.org")
if (!require("WaveletComp")) install.packages("WaveletComp", repos = "http://cran.us.r-project.org")

# Carregar Pacotes
packs <- c(
    "rgdal", "raster", "sp",
    "maptools", "rworldmap", "rgeos", "WaveletComp"
)
lapply(packs, require, character.only = TRUE)

# Carregar Funções
source("funcoes.R")


anos <- c("2018", "2019", "2020", "2021", "2022")
meses <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
ano <- anos[5]

# selecionar o pixel de interesse
pixel <- 95
# carrega os dados (GRIB) de um ano em decendios
# (parametro ano corresponde a pasta com os arquivo)
raster_ano_selecionado <- ler_arquivos_grib(ano)


lista_dados_decendios_ano <- c()
for (mes in meses) {
    # selecionar o mês de interesse
    grib_mes <- raster_ano_selecionado[[mes]]
    # empilhar (list) os dados de precipitação 3 decêndios
    grib_list_mes_d1_d11_d20 <- list_d1_d11_d20(grib_mes)
    # selecionar o pixel de interesse em 3 decêndios
    valores_pixel <- seleciona_pixel(pixel, grib_list_mes_d1_d11_d20)
    # adicionar os valores de precipitação do pixel selecionado
    # em 3 decêndios em uma lista
    lista_dados_decendios_ano <- c(lista_dados_decendios_ano, valores_pixel)
}


# obter os valores mínimos e máximos de precipitação arredondados
min_precipitacao <- floor(min(lista_dados_decendios_ano))
max_precipitacao <- ceiling(max(lista_dados_decendios_ano))

# plotar os dados de precipitação 3 decêndios
# para o pixel selecionado em um ano específico em um gráfico de linha
legenda <- paste(
    "Serie Temporal de Precipitação decendial para o ano ", ano, " pixel ", pixel
)
nome_arquivo <- paste0(
    "Graficos/serie_temporal_", ano, "_pixel_", pixel, ".png"
)
png(nome_arquivo, width = 10, height = 10, units = "in", res = 300)
plot(
    lista_dados_decendios_ano,
    type = "l",
    xlab = "Decendios Mês a Mês (t)",
    ylab = "Precipitação (mm)",
    xaxt = "n",
    yaxt = "n",
    main = legenda
)
legend("topleft", legend = c(c("Máximo"), "Mínimo"), col = c("red", "blue"), pch = 20, cex = 2)
axis(1, at = 1:36, labels = datas_decendios, las = 2, cex.axis = 0.7)
axis(2, at = min_precipitacao:max_precipitacao, las = 3, cex.axis = 1)
points(which(lista_dados_decendios_ano == max(lista_dados_decendios_ano)), max(lista_dados_decendios_ano), col = "red", pch = 20, cex = 5)
points(which(lista_dados_decendios_ano == min(lista_dados_decendios_ano)), min(lista_dados_decendios_ano), col = "blue", pch = 20, cex = 5)
dev.off()
