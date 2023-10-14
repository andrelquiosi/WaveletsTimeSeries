# Intalação de Pacotes
# install.packages(c(
#   "rgdal", "raster", "sp",
#   "maptools", "rworldmap", "rgeos", "WaveletComp"
# ))

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
{
  # ano para rodar os scrypts
  ano <- "2018"

  # carrega os dados (GRIB) de um ano em decendios
  # (parametro ano corresponde a pasta com os arquivo)
  raster_ano_selecionado <- ler_arquivos_grib(ano)

  # Empilhar os dados de precipitação do grib escolhodo
  ecmwf_step_240_t00_d1_d11_d20 <-
    prepara_plot_decendios(raster_ano_selecionado[[1]])

  # Plotar os dados do grib escolhido
  spplot(ecmwf_step_240_t00_d1_d11_d20, scales = list(draw = TRUE))

  #
  clipe_ecmwf_d1_d11_d20_soma_raster <-
    processa_dados_precipitacao(raster_ano_selecionado[[1]], mapa_parana[[1]])

  # Plotar os dados no mapa do Paraná com a Mesorregião do Oeste do Paraná
  # com o círculo em Toledo e Cascavel
  # cria a legenda para o mapa
  legenda1 <- paste(
    "Dados de Previsão de Precipitação do ECMWF, para o ano de ",
    ano,
    ", com previsão para 240h\nInseridos na Mesorregião do Oeste do Paraná"
  )
  spplot(
    clipe_ecmwf_d1_d11_d20_soma_raster,
    scales = list(draw = TRUE),
    sp.layout = list(
      list(mapa_parana[[2]], oestepr_sp, first = FALSE),
      list(oestepr_sp, lwd = 2, first = FALSE),
      list(circulo_toledo_cascavel, lwd = 2, first = FALSE)
    ), main = legenda1
  )

  # Plotar os dados no mapa do Paraná com a Mesorregião do Oeste do Paraná
  # e os números do grid na mesorregião
  spplot(
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

anos <- c("2018", "2019", "2020", "2021", "2022")
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
  "Dados de Previsão de Precipitação do ECMWF, para o ano de ",
  ano,
  ", com previsão para 240h\nInseridos na Mesorregião do Oeste do Paraná"
)

# carrega as legendas dos decendios para plotar
legenda_decendios <- datas_para_plotar()

# Criar o arquivo PNG
nome_arquivo <- paste0("Graficos/parana_oeste_toledo_cascavel_", ano, ".png")
png(nome_arquivo, width = 1000, height = 1000, units = "px", pointsize = 12)

spplot(
  raster_com_decendios,
  scales = list(
    draw = TRUE,
    alternating = 1,
    x = list(labels = x_labels),
    y = list(labels = y_labels)
  ),
  sp.layout = list(
    list(mapa_parana[[2]], oestepr_sp, lwd = 0.5, col = "#3d3d3d", first = FALSE),
    list(oestepr_sp, lwd = 0.5, col = "#3d3d3d", first = FALSE),
    list(circulo_toledo_cascavel, lwd = 0.5, col = "#3d3d3d", first = FALSE)
  ),
  main = legenda,
  names.attr = legenda_decendios
)
# Finalizar o arquivo SVG
dev.off()
