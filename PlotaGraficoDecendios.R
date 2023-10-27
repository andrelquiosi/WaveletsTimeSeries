# Intalação de Pacotes
if (!require("rgdal")) install.packages("rgdal", repos = "http://cran.us.r-project.org")
if (!require("raster")) install.packages("raster", repos = "http://cran.us.r-project.org")
if (!require("sp")) install.packages("sp", repos = "http://cran.us.r-project.org")
if (!require("maptools")) install.packages("maptools", repos = "http://cran.us.r-project.org")
if (!require("rworldmap")) install.packages("rworldmap", repos = "http://cran.us.r-project.org")
if (!require("rgeos")) install.packages("rgeos", repos = "http://cran.us.r-project.org")
# Carregar Pacotes
packs <- c(
  "rgdal", "raster", "sp",
  "maptools", "rworldmap", "rgeos"
)
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
centroide <- c(-53.5, -25)
# Definir o raio do polígono circular
raio_poligono <- 0.36
circulo_toledo_cascavel <- criar_poligono_circular(centroide, raio_poligono)

# ano para rodar os scrypts
anos <- c("2018", "2019", "2020", "2021", "2022")
meses <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
dias <- c("01", "11", "20")
plots <- list()

for (ano in anos) {
  # carrega os dados (GRIB) de um ano em decendios
  # (parametro ano corresponde a pasta com os arquivo)
  raster_ano_selecionado <- ler_arquivos_grib(ano)
  raster_com_decendios <- rasterizar_e_recortar(raster_ano_selecionado, mapa_parana[[1]])

  # cria os labels para o eixo x e y
  x_labels <- c("", "54°W", "", "50°W", "", "")
  y_labels <- c("26°S", "", "25°S", "", "24°S", "", "23°S")

  # cria a legenda para o mapa
  legenda <- paste(
    "Dados de previsão de precipitação do ECMWF, para o ano de ",
    ano,
    ", com previsão para 240h\nInseridos na mesorregião do Oeste do Paraná",
    sep = ""
  )

  # carrega as legendas dos decendios para plotar
  legenda_decendios <- format.Date(gerar_datas(ano,meses,dias), "%d %b")

  # cria o mapa com os decendios e o recorte do oeste do Paraná e Toledo e Cascavel
  s <- spplot(
    raster_com_decendios,
    scales = list(
      draw = TRUE,
      alternating = 1,
      x = list(labels = x_labels),
      y = list(labels = y_labels)
    ),
    sp.layout = list(
      list(mapa_parana[[2]], lwd = 2, col = "#3d3d3d", first = FALSE),
      list(recorte_oeste_parana[[1]], lwd = 1, col = "#ffffff", first = FALSE),
      list(circulo_toledo_cascavel, lwd = 1, col = "#ffffff", first = FALSE)
    ),
    main = legenda,
    names.attr = legenda_decendios
  )
  plots[[ano]] <- s
}
# Salvar os mapas em arquivos PNG
for (ano in anos) {
  # Criar o arquivo PNG
  nome_arquivo <- paste0("Graficos/parana_oeste_toledo_cascavel_", ano, ".png")
  png(nome_arquivo, width = 900, height = 400, units = "px")

  # Plotar o mapa
  print(plots[[ano]])

  # Finalizar o arquivo SVG
  dev.off()
}
