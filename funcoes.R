# Função para empilhar (stack) os dados de precipitação 3 decêndios
stack_d1_d11_d20 <- function(grib_stack) {
  grib_stack_t00_d1_d11_d20 <- stack(
    grib_stack[[1]],
    grib_stack[[11]],
    grib_stack[[20]]
  )
  return(grib_stack_t00_d1_d11_d20)
}

# Função para empilhar (list) os dados de precipitação 3 decêndios
list_d1_d11_d20 <- function(grib_mes) {
  grib_list_mes_d1_d11_d20 <- list(
    values(grib_mes[[1]]),
    values(grib_mes[[11]]),
    values(grib_mes[[20]])
  )
  return(grib_list_mes_d1_d11_d20)
}

# Função para selecionar o pixel de interesse em 3 decêndios
seleciona_pixel <- function(pixel, decendios) {
  valores_pixel <- c()
  for (i in seq_along(decendios)) {
    valores_pixel <- c(valores_pixel, decendios[[i]][[pixel]])
  }
  return(valores_pixel)
}

# Função para preparar os dados de precipitação para plotagem 3 decêndios
processa_dados_precipitacao <- function(ecmwf_step_240, parana_sp) {
  ecmwf_step_240_d1_d11_d20 <- stack_d1_d11_d20(ecmwf_step_240)
  ecmwf_step_240_d1_d11_d20_soma <- stackApply(ecmwf_step_240_d1_d11_d20, c(1, 1, 1), fun = sum)
  ecmwf_step_240_d1_d11_d20_soma_raster <- rasterize(parana_sp, ecmwf_step_240_d1_d11_d20_soma)
  clipe_ecmwf_step_240_d1_d11_d20_soma_raster <- mask(ecmwf_step_240_d1_d11_d20_soma, ecmwf_step_240_d1_d11_d20_soma_raster)
  return(clipe_ecmwf_step_240_d1_d11_d20_soma_raster)
}

# Função para criar os recortes do Paraná
criar_recortes_pr <- function() {
  # Carregar shapefiles e metadados
  brasil <- readOGR("./Centroides", "brasil")
  # Extrair coordenadas do contorno do Paraná
  parana_contorno <- brasil@polygons[[221]]@Polygons[[1]]@coords

  # Criar objeto SpatialPolygons para a área de recorte de interesse
  parana_polygon <- Polygon(parana_contorno)
  parana_polygons <- Polygons(list(parana_polygon), "s1")
  parana_sp <- SpatialPolygons(
    list(parana_polygons), 1:1,
    proj4string = CRS(
      "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    )
  )
  parana_spdf <- SpatialPolygonsDataFrame(
    parana_sp, data.frame(z = 1:1, row.names = c("s1"))
  )

  # Retornar uma lista com os objetos criados
  return(list(parana_sp, parana_spdf))
}

# Função para criar os recortes da Mesorregião do Oeste do Paraná
criar_recortes_oeste_pr <- function() {
  # Carregar coordenadas da Mesorregião do Oeste do Paraná
  oestepr_contorno <- read.table("Centroides/oestepr_contorno.txt")

  # Criar objeto SpatialPolygons para a Mesorregião do Oeste do Paraná
  oestepr_polygon <- Polygon(oestepr_contorno)
  oestepr_polygons <- Polygons(list(oestepr_polygon), "s1")
  oestepr_sp <- SpatialPolygons(
    list(oestepr_polygons), 1:1,
    proj4string = CRS(
      "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    )
  )
  return(oestepr_sp)
}

criar_circulo_toledo_cascavel <- function(centroide) {
  # Definir o raio do círculo
  raio <- 0.36
  # Calcular as coordenadas dos pontos que formam o círculo
  angulos <- seq(0, 2 * pi, length.out = 360)
  x <- centroide[1] + raio * cos(angulos)
  y <- centroide[2] + raio * sin(angulos)
  coords_circulo <- cbind(x, y)

  # Criar o objeto Polygon
  poligono <- Polygon(coords_circulo)

  # Criar o objeto SpatialPolygons
  sp_poligono <- SpatialPolygons(list(Polygons(list(poligono), ID = "s1")),
    proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs")
  )

  # Criar o objeto SpatialPolygonsDataFrame
  spdf_circulo <- SpatialPolygonsDataFrame(
    sp_poligono, data.frame(z = 1:1, row.names = c("s1"))
  )
  return(spdf_circulo)
}

ler_arquivos_grib <- function(ano) {
  grib_dir <- paste0(ano)

  # Get a list of all the GRIB files in the directory
  grib_files <- list.files(grib_dir, pattern = "*.grib", full.names = TRUE)

  # Create an empty list to store the raster stacks
  grib_stacks <- list()

  # Loop through each GRIB file and read it into a raster stack
  for (i in seq_along(grib_files)) {
    grib_stacks[[i]] <- stack(grib_files[i])
  }
  return(grib_stacks)
}

raster_arquivos <- function(gribs_list, parana_spdf) {
  # Criar uma lista vazia para armazenar as pilhas de raster de cada arquivo GRIB
  raster_list <- list()
  # Loop sobre os arquivos GRIB
  for (grib in gribs_list) {
    # Empilhar as camadas do arquivo GRIB em uma pilha de raster
    raster_grib <- stack_d1_d11_d20(grib)

    # Adicionar a pilha de raster à lista de pilhas de raster
    raster_list <- append(raster_list, list(raster_grib))
  }

  # Empilhar todas as pilhas de raster em uma única pilha de raster
  pilha_raster <- do.call(stack, raster_list)

  # Rasterizar o polígono de recorte
  raster_parana <- rasterize(parana_spdf, pilha_raster)

  # Recortar o raster para o polígono de recorte
  clipe_raster <- mask(pilha_raster, raster_parana)

  # Retornar o raster recortado
  return(clipe_raster)
}

datas_para_plotar <- function() {
  datas <- c(
    "01 Jan",
    "11 Jan",
    "20 Jan",
    "01 Fev",
    "11 Fev",
    "20 Fev",
    "01 Mar",
    "11 Mar",
    "20 Mar",
    "01 Abr",
    "11 Abr",
    "20 Abr",
    "01 Mai",
    "11 Mai",
    "20 Mai",
    "01 Jun",
    "11 Jun",
    "20 Jun",
    "01 Jul",
    "11 Jul",
    "20 Jul",
    "01 Ago",
    "11 Ago",
    "20 Ago",
    "01 Set",
    "11 Set",
    "20 Set",
    "01 Out",
    "11 Out",
    "20 Out",
    "01 Nov",
    "11 Nov",
    "20 Nov",
    "01 Dez",
    "11 Dez",
    "20 Dez"
  )
  return(datas)
}


plot_temporal_series <- function(ano, meses, pixel) {
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

  # criar os labels para o eixo x
  datas_decendios <- datas_para_plotar()

  # obter os valores mínimos, máximos e mediana de precipitação
  min_precipitacao <- floor(min(lista_dados_decendios_ano))
  max_precipitacao <- ceiling(max(lista_dados_decendios_ano))
  mediana_precipitacao <- median(lista_dados_decendios_ano)

  # obter os valores mínimos, máximos e mediana de precipitação arredondados com 2 casas decimais
  round_min_precipitacao <- round(min(lista_dados_decendios_ano), 2)
  round_max_precipitacao <- round(max(lista_dados_decendios_ano), 2)
  round_mediana_precipitacao <- round(mediana_precipitacao, 2)


  # plotar os dados de precipitação 3 decêndios
  # para o pixel selecionado em um ano específico em um gráfico de linha
  legenda <- paste(
    "Serie Temporal de precipitação decendial para o ano ", ano, ".",
    "\nCorrespondente a Toledo e Cascavel - PR(pixel ", pixel, ").",
    sep = ""
  )

  # salvar o gráfico em um arquivo png
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
    main = legenda,
    cex = 1.5,
    cex.lab = 1.5
  )

  # adicionar os labels para o eixo x e y
  axis(1, at = 1:36, labels = FALSE)
  text(1:36, par("usr")[3] - 1.5,
    srt = 45, adj = 1,
    xpd = TRUE, labels = datas_decendios
  )
  axis(2, at = min_precipitacao:max_precipitacao, las = 3, cex.axis = 1)

  # adicionar pontos para os valores máximos e mínimos
  points(which(lista_dados_decendios_ano == max(lista_dados_decendios_ano)),
    max(lista_dados_decendios_ano),
    col = "blue", pch = 4, cex = 3
  )

  # adicionar linhas horizontais para os valores máximos e mínimos
  abline(h = max(lista_dados_decendios_ano), col = "blue", lty = 2)
  text(0, max(lista_dados_decendios_ano),
    paste("Máximo: ", round_max_precipitacao, "mm"),
    col = "blue", adj = c(0, -.1)
  )

  abline(h = min(lista_dados_decendios_ano), col = "red", lty = 2)
  text(0, min(lista_dados_decendios_ano),
    paste("Mínimo: ", round_min_precipitacao, "mm"),
    col = "red", adj = c(0, +1)
  )

  abline(h = mediana_precipitacao, col = "green", lty = 2)
  text(0, mediana_precipitacao, paste("Mediana: ", round_mediana_precipitacao, "mm"), col = "green", adj = c(0, -1))


  dev.off()
}
