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

# Criar os recortes do Paraná e da Mesorregião do Oeste do Paraná
mapa_parana <- criar_recortes_pr()
oestepr_sp <- criar_recortes_oeste_pr()

# Criar o círculo em Toledo e Cascavel
centroide <- c(-53.5, -25)
circulo_toledo_cascavel <- criar_circulo_toledo_cascavel(centroide)

anos <- c("2018", "2019", "2020", "2021", "2022")
{
  ano <- anos[5]
  # carrega os dados (GRIB) de um ano em decendios
  # (parametro ano corresponde a pasta com os arquivo)
  raster_ano_selecionado <- ler_arquivos_grib(ano)
  raster_com_decendios <- raster_arquivos(raster_ano_selecionado, mapa_parana[[1]])

  # cria os labels para o eixo x e y
  x_labels <- c("", "54°W", "", "50°W", "", "")
  y_labels <- c("26°S", "", "25°S", "", "24°S", "", "23°S")

  # cria a legenda para o mapa
  legenda <- paste(
    "Dados de previsão de precipitação do ECMWF, para o ano de ",
    ano,
    ", com previsão para 240h\nInseridos na mesorregião do Oeste do Paraná"
  )

  # carrega as legendas dos decendios para plotar
  legenda_decendios <- datas_para_plotar()

  # Criar o arquivo PNG
  nome_arquivo <- paste0("Graficos/parana_oeste_toledo_cascavel_", ano, ".png")
  png(nome_arquivo, width = 10, height = 10, units = "in", res = 300)
}
spplot(
  raster_com_decendios,
  scales = list(
    draw = TRUE,
    alternating = 1,
    x = list(labels = x_labels),
    y = list(labels = y_labels)
  ),
  sp.layout = list(
    list(mapa_parana[[2]], oestepr_sp, lwd = 1, col = "#3d3d3d", first = FALSE),
    list(oestepr_sp, lwd = 1, col = "#ffffff", first = FALSE),
    list(circulo_toledo_cascavel, lwd = 1, col = "#ffffff", first = FALSE)
  ),
  main = legenda,
  names.attr = legenda_decendios
)
# Finalizar o arquivo SVG
dev.off()