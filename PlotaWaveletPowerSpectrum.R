if (!require("rgdal")) install.packages("WaveletComp", repos = "http://cran.us.r-project.org")
if (!require("raster")) install.packages("raster", repos = "http://cran.us.r-project.org")

packs <- c(
  "WaveletComp", "raster"
)

lapply(packs, require, character.only = TRUE)

source("funcoes.R")
# carregar os dados selecionado para o pixel 95, depois plotar esses dado em um gráfico carregar os dados selecionado para o pixel 95, depois plotar esses dado em um gráfico

# selecionar o pixel de interesse
pixel <- 95

# parametro ano corresponde a pasta com os arquivo
anos <- c("2018", "2019", "2020", "2021", "2022")
meses <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)

for (ano in anos) {
  raster_ano_selecionado <- ler_arquivos_grib(ano)

  lista_dados_decendios_ano <- c()
  for (mes in meses) {
    # selecionar o mês de interesse
    grib_mes <- raster_ano_selecionado[[mes]]
    # empilhar (list) os dados de precipitação 3 decêndios
    grib_list_mes_d1_d11_d20 <- list_precipitacao_d1_d11_d20(grib_mes)
    # selecionar o pixel de interesse em 3 decêndios
    valores_pixel <- seleciona_pixel(pixel, grib_list_mes_d1_d11_d20)
    # adicionar os valores de precipitação do pixel selecionado
    # em 3 decêndios em uma lista
    lista_dados_decendios_ano <- c(lista_dados_decendios_ano, valores_pixel)
  }

  # criar os labels para o eixo x
  datas_decendios <- datas_para_carregar(ano)
  dados <-
    data.frame(date = datas_decendios, lista_dados_decendios_ano)

  names(dados) <- c("date", "Precipitação")

  # salvar wavelet power spectrum
  filename <- paste("Graficos/espectro_de_potencia_wavelet_pixel", pixel, "_ano_", ano, ".png", sep = "")
  png(filename, width = 10, height = 10, units = "in", res = 300)

  set.seed(1)
  wavelet <- analyze.wavelet(
    dados,
    "Precipitação",
    loess.span = 0,
    dt = 1 / 12,
    dj = 1 / 250,
    lowerPeriod = 0.150,
    upperPeriod = 8,
    make.pval = T,
    n.sim = 10
  )

  index.ticks <- seq(1, dim(dados)[1], by = 1)
  index.labels <- format.Date(datas_decendios, "%d-%b")
  main_legend <- paste("Periodograma da série temporal do", "pixel", pixel, "(Toledo e Cascavel)", "\nAno:", ano, sep = " ")

  wt.image(
    wavelet,
    color.key = "quantile",
    main = main_legend,
    legend.params = list(
      lab = "Níveis de Potência da Wavelet",
      lab.line = 3.5,
      label.digits = 2,
      n.ticks = 10
    ),
    show.date = FALSE,
    periodlab = "Período",
    lwd.axis = 1,
    label.time.axis = TRUE,
    spec.time.axis = list(
      at = index.ticks,
      labels = index.labels,
      las = 2,
      hadj = 1,
      padj = 0.5
    )
  )
  dev.off()
}
