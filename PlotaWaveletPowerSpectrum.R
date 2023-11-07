if (!require("WaveletComp")) install.packages("WaveletComp", repos = "http://cran.us.r-project.org")
if (!require("raster")) install.packages("raster", repos = "http://cran.us.r-project.org")

packs <- c(
  "WaveletComp", "raster"
)

lapply(packs, require, character.only = TRUE)

source("funcoes.R")

# selecionar o pixel de interesse
pixel <- 94

# parametro ano corresponde a pasta com os arquivo
anos <- c("2018", "2019", "2020", "2021", "2022")
meses <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
dias <- c("01", "11", "20")

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
  datas_decendios <- gerar_datas(ano, meses, dias)
  dados <- data.frame(date = datas_decendios, lista_dados_decendios_ano)

  names(dados) <- c("date", "Precipitacao")

  # criar imagem para salvar wavelet power spectrum
  nome_arquivo <- paste("Graficos/espectro_de_potencia_wavelet_pixel", pixel, "_ano_", ano, ".png", sep = "")
  png(nome_arquivo, width = 1000, height = 500, units = "px")

  # Cálculo do espectro de potência wavelet de uma única série temporal
  set.seed(1)
  wavelet <- analyze.wavelet(
    dados,
    "Precipitacao",
    loess.span = 0,
    dt = 1 / 12,
    dj = 1 / 250,
    lowerPeriod = 0.150,
    upperPeriod = 8,
    make.pval = TRUE,
    n.sim = 10
  )

  # Gráfico de imagem do espectro de potência wavelet de uma única série temporal
  main_legend <- paste("Ano", ano, sep = " ")
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
      at = seq(1, dim(dados)[1], by = 1),
      labels = format.Date(datas_decendios, "%d-%b"),
      las = 2,
      hadj = 1,
      padj = 0.5
    )
  )

  # Adicionar rótulo ao eixo x
  mtext("Decêndios", side = 1, line = 3.5)

  dev.off()
}
