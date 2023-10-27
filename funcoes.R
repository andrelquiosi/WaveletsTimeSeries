# Função para empilhar (stack) os dados de precipitação 3 decêndios
stack_precipitacao_d1_d11_d20 <- function(dados_precipitacao) {
  precipitacao_d1_d11_d20_empilhada <- stack(
    dados_precipitacao[[1]],
    dados_precipitacao[[11]],
    dados_precipitacao[[20]]
  )
  return(precipitacao_d1_d11_d20_empilhada)
}

# Função para empilhar (list) os dados de precipitação 3 decêndios
list_precipitacao_d1_d11_d20 <- function(dados_precipitacao_mes) {
  precipitacao_d1_d11_d20_listada <- list(
    values(dados_precipitacao_mes[[1]]),
    values(dados_precipitacao_mes[[11]]),
    values(dados_precipitacao_mes[[20]])
  )
  return(precipitacao_d1_d11_d20_listada)
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
processa_dados_precipitacao <- function(dados_precipitacao, poligonos_parana) {
  dados_precipitacao_empilhados <-
    stack_precipitacao_d1_d11_d20(dados_precipitacao)
  dados_precipitacao_somados <-
    stackApply(dados_precipitacao_empilhados, c(1, 1, 1), fun = sum)
  dados_precipitacao_rasterizados <-
    rasterize(poligonos_parana, dados_precipitacao_somados)
  dados_precipitacao_recortados <-
    mask(dados_precipitacao_somados, dados_precipitacao_rasterizados)
  return(dados_precipitacao_recortados)
}

criar_recorte_regiao_especifica <- function(coordenadas) {
  # Criar objeto SpatialPolygons
  sp_poligono <- SpatialPolygons(
    list(Polygons(list(Polygon(coordenadas)), "recorte_regiao_especifica")),
    proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs")
  )

  # Criar objeto SpatialPolygonsDataFrame
  spdf_poligono <- SpatialPolygonsDataFrame(
    sp_poligono, data.frame(z = 1:1, row.names = c("recorte_regiao_especifica"))
  )

  # Retornar uma lista com os objetos criados
  return(list(sp_poligono, spdf_poligono))
}


criar_poligono_circular <- function(centroide, raio_poligono) {
  # Calcular as coordenadas dos pontos que formam o polígono circular
  angulos <- seq(0, 2 * pi, length.out = 360)
  x <- centroide[1] + raio_poligono * cos(angulos)
  y <- centroide[2] + raio_poligono * sin(angulos)
  coords_poligono <- cbind(x, y)

  # Criar o objeto Polygon
  poligono <- Polygon(coords_poligono)

  # Criar o objeto SpatialPolygons
  sp_poligono <- SpatialPolygons(
    list(Polygons(list(poligono), ID = "poligono_circular")),
    proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs")
  )

  # Criar o objeto SpatialPolygonsDataFrame
  spdf_poligono <- SpatialPolygonsDataFrame(
    sp_poligono, data.frame(z = 1:1, row.names = c("poligono_circular"))
  )
  return(spdf_poligono)
}

ler_arquivos_grib <- function(dir) {
  grib_dir <- paste0(dir)

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

rasterizar_e_recortar <- function(lista_arquivos_grib, poligono_recorte) {
  # Criar uma lista vazia para armazenar as pilhas de raster de cada arquivo GRIB
  lista_rasters <- list()

  # Loop sobre os arquivos GRIB
  for (arquivo_grib in lista_arquivos_grib) {
    # Empilhar as camadas do arquivo GRIB em uma pilha de raster
    pilha_raster_grib <- stack_precipitacao_d1_d11_d20(arquivo_grib)

    # Adicionar a pilha de raster à lista de pilhas de raster
    lista_rasters <- c(lista_rasters, list(pilha_raster_grib))
  }

  # Empilhar todas as pilhas de raster em uma única pilha de raster
  pilha_rasters <- do.call(stack, lista_rasters)

  # Rasterizar o polígono de recorte
  raster_recorte <- rasterize(poligono_recorte, pilha_rasters)

  # Recortar o raster para o polígono de recorte
  raster_recortado <- mask(pilha_rasters, raster_recorte)

  # Retornar o raster recortado
  return(raster_recortado)
}

recortar_rasters <- function(pilha_rasters, poligono_recorte) {
  # Rasterizar o polígono de recorte
  raster_recorte <- rasterize(poligono_recorte, pilha_rasters)

  # Recortar o raster para o polígono de recorte
  raster_recortado <- mask(pilha_rasters, raster_recorte)

  # Retornar o raster recortado
  return(raster_recortado)
}

# Função para gerar as datas (ano, meses e dias)
gerar_datas <- function(ano, meses, dias) {
  datas <- c()
  for (mes in meses) {
    for (dia in dias) {
      data_completa <- paste(ano, mes, dia, sep = "-")
      datas <- c(datas, data_completa)
    }
  }
  return(as.Date(datas, format = "%Y-%m-%d"))
}
