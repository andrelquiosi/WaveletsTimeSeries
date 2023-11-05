# Intalação de Pacotes
if (!require("rgdal")) install.packages("rgdal", repos = "http://cran.us.r-project.org")
if (!require("raster")) install.packages("raster", repos = "http://cran.us.r-project.org")
if (!require("sp")) install.packages("sp", repos = "http://cran.us.r-project.org")
if (!require("maptools")) install.packages("maptools", repos = "http://cran.us.r-project.org")
if (!require("rworldmap")) install.packages("rworldmap", repos = "http://cran.us.r-project.org")
if (!require("rgeos")) install.packages("rgeos", repos = "http://cran.us.r-project.org")

# Carregar Pacotes para avariavel
packs <- c(
  "rgdal", "raster", "sp",
  "maptools", "rworldmap", "rgeos"
)

# carrega os pacotes
lapply(packs, require, character.only = TRUE)

# Carregar Funções
source("funcoes.R")

# Criar os recortes do Paraná e da Mesorregião do Oeste do Paraná
# Carregar shapefiles e metadados
brasil_shapefile <- readOGR("./Centroides", "brasil")
# Extrair coordenadas do contorno do Paraná
parana_contorno <- brasil_shapefile@polygons[[221]]@Polygons[[1]]@coords
mapa_parana <- criar_recorte_regiao_especifica(parana_contorno)

# Carregar coordenadas da Mesorregião do Oeste do Paraná
coordenadas <- read.table("Centroides/oestepr_contorno.txt")
recorte_oeste_parana <- criar_recorte_regiao_especifica(coordenadas)

# Criar o círculo em Toledo e Cascavel
centroide <- c(-53.5, -25) # coordenadas do centroide do circulo
# Definir o raio do polígono circular
raio_poligono <- 0.36
circulo_toledo_cascavel <- criar_poligono_circular(centroide, raio_poligono)

# ano para rodar os scrypts
anos <- c("2018", "2019", "2020", "2021", "2022")
meses <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
dias <- c("01", "11", "20")


{
  ano <- anos[1]
  mes <- meses[1]

  datas <- gerar_datas(ano, meses, dias)
  # carrega os dados (GRIB) de um ano em decendios
  # (parametro ano corresponde a pasta com os arquivo)
  raster_ano_selecionado <- ler_arquivos_grib(ano)
  # Empilhar os dados de precipitação do grib escolhodo
  ecmwf_step_240_t00_d1_d11_d20 <-
    stack_precipitacao_d1_d11_d20(raster_ano_selecionado[[mes]])

  raster_com_decendios <- recortar_rasters(ecmwf_step_240_t00_d1_d11_d20[[1]], recorte_oeste_parana[[1]])

  # Plotar os dados do grib escolhido
  legend <- paste(
    "Dados de Previsão de Precipitação para 240h do ECMWF.",
    "\nPrimeiro decêndio de Janeiro de ", ano,
    ", para o estado do Paraná",
    sep = ""
  )
  exemplo <- spplot(ecmwf_step_240_t00_d1_d11_d20[[1]], scales = list(draw = TRUE), main = legend)

  # Plotar os dados no mapa do Paraná com todos os dias
  exemplo2 <- spplot(raster_ano_selecionado[[1]], scales = list(draw = TRUE))

  # Plotar os dados no mapa do Paraná com a Mesorregião do Oeste do Paraná
  # com o círculo em Toledo e Cascavel
  # cria a legenda para o mapa
  legenda <- paste(
    "Dados de Previsão de Precipitação \nPrimeiro decêndio de Janeiro de ",
    ano
  )
  exemplo3 <- spplot(
    raster_com_decendios,
    scales = list(draw = TRUE),
    sp.layout = list(
      list(mapa_parana[[2]], first = FALSE),
      list(recorte_oeste_parana[[1]], lwd = 1, first = FALSE),
      list(circulo_toledo_cascavel, lwd = 2, first = FALSE)
    ), main = legenda
  )

  # Plotar os dados no mapa do Paraná com a Mesorregião do Oeste do Paraná
  # e os números do grid na mesorregião
  exemplo4 <- spplot(
    raster_com_decendios[[1]],
    scales = list(draw = TRUE),
    sp.layout = list(
      list(mapa_parana[[2]], first = FALSE),
      list(recorte_oeste_parana[[1]], lwd = 2, first = FALSE),
      list("sp.text", c(-54, -24.5), "1"),
      list("sp.text", c(-53.5, -24.5), "2"),
      list("sp.text", c(-54, -25), "3"),
      list("sp.text", c(-53.5, -25), "4"),
      list("sp.text", c(-53, -25), "5"),
      list("sp.text", c(-54.45, -25.4), "6"),
      list("sp.text", c(-54, -25.4), "7"),
      list("sp.text", c(-53.5, -25.4), "8")
    )
  )
}

# Criar o arquivo PNG
nome_arquivo <- paste0("Graficos/exemploPixelsCoordenadasPrecipitacao", ".png")
png(nome_arquivo, width = 10, height = 8, units = "in", res = 300)
print(exemplo3)
# Finalizar o arquivo SVG
dev.off()



pixels <- rasterToPoints(ecmwf_step_240_t00_d1_d11_d20[[1]])
# Adicionar rótulos aos pixels, se houver pixels
pixels[94, 1:2]
