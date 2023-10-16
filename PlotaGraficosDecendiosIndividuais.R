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
mapa_parana <- criar_recortes_pr()
oestepr_sp <- criar_recortes_oeste_pr()

# Criar o círculo em Toledo e Cascavel
centroide <- c(-53.5, -25)
circulo_toledo_cascavel <- criar_circulo_toledo_cascavel(centroide)
# ano para rodar os scrypts
anos <- c("2018", "2019", "2020", "2021", "2022")
mes <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
{
  ano <- anos[1]
  mes <- mes[1]
  # carrega os dados (GRIB) de um ano em decendios
  # (parametro ano corresponde a pasta com os arquivo)
  raster_ano_selecionado <- ler_arquivos_grib(ano)
  # Empilhar os dados de precipitação do grib escolhodo
  ecmwf_step_240_t00_d1_d11_d20 <-
    stack_d1_d11_d20(raster_ano_selecionado[[mes]])

  # Plotar os dados do grib escolhido
  legend <- paste(
    "Dados de Previsão de Precipitação para 240h do ECMWF.",
    "\nPrimeiro decêndio de Janeiro de ", ano,
    ", para o estado do Paraná",sep = ""
  )
  exemplo <- spplot(ecmwf_step_240_t00_d1_d11_d20[[1]], scales = list(draw = TRUE), main = legend)
 exemplo2 <- spplot(raster_ano_selecionado[[1]], scales = list(draw = TRUE))
  #
  clipe_ecmwf_d1_d11_d20_soma_raster <-
    processa_dados_precipitacao(raster_ano_selecionado[[mes]], mapa_parana[[1]])

  # Plotar os dados no mapa do Paraná com a Mesorregião do Oeste do Paraná
  # com o círculo em Toledo e Cascavel
  # cria a legenda para o mapa
  legenda <- paste(
    "Dados de Previsão de Precipitação do ECMWF, para o ano de ",
    ano,
    ", com previsão para 240h\nInseridos na Mesorregião do Oeste do Paraná"
  )
  exemplo3 <- spplot(
    clipe_ecmwf_d1_d11_d20_soma_raster,
    scales = list(draw = TRUE),
    sp.layout = list(
      list(mapa_parana[[2]], oestepr_sp, first = FALSE),
      list(oestepr_sp, lwd = 2, first = FALSE),
      list(circulo_toledo_cascavel, lwd = 2, first = FALSE)
    ), main = legenda
  )

  # Plotar os dados no mapa do Paraná com a Mesorregião do Oeste do Paraná
  # e os números do grid na mesorregião
  exemplo4 <- spplot(
    clipe_ecmwf_d1_d11_d20_soma_raster,
    scales = list(draw = TRUE),
    sp.layout = list(
      list(mapa_parana[[2]], oestepr_sp, first = FALSE),
      list(oestepr_sp, lwd = 2, first = FALSE),
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
png(nome_arquivo, width = 10, height = 10, units = "in", res = 300)
print(exemplo)
# Finalizar o arquivo SVG
dev.off()
