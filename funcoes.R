# Função para empilhar os dados de precipitação 3 decêndios
stack_d1_d11_d20 <- function(grib_stack) {
  grib_stack_t00_d1_d11_d20 <- stack(
    grib_stack[[1]],
    grib_stack[[11]],
    grib_stack[[20]]
  )
  return(grib_stack_t00_d1_d11_d20)
}

# Função para preparar os dados de precipitação para plotagem 3 decêndios
prepara_plot_decendios <- function(ecmwf_step_240) {
  # Empilhar os dados de precipitação
  ecmwf_step_240_d1_d11_d20 <- stack_d1_d11_d20(ecmwf_step_240)
  return(ecmwf_step_240_d1_d11_d20)
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
    "Decêndio: 01 Jan",
    "Decêndio: 11 Jan",
    "Decêndio: 20 Jan",
    "Decêndio: 01 Fev",
    "Decêndio: 11 Fev",
    "Decêndio: 20 Fev",
    "Decêndio: 01 Mar",
    "Decêndio: 11 Mar",
    "Decêndio: 20 Mar",
    "Decêndio: 01 Abr",
    "Decêndio: 11 Abr",
    "Decêndio: 20 Abr",
    "Decêndio: 01 Mai",
    "Decêndio: 11 Mai",
    "Decêndio: 20 Mai",
    "Decêndio: 01 Jun",
    "Decêndio: 11 Jun",
    "Decêndio: 20 Jun",
    "Decêndio: 01 Jul",
    "Decêndio: 11 Jul",
    "Decêndio: 20 Jul",
    "Decêndio: 01 Ago",
    "Decêndio: 11 Ago",
    "Decêndio: 20 Ago",
    "Decêndio: 01 Set",
    "Decêndio: 11 Set",
    "Decêndio: 20 Set",
    "Decêndio: 01 Out",
    "Decêndio: 11 Out",
    "Decêndio: 20 Out",
    "Decêndio: 01 Nov",
    "Decêndio: 11 Nov",
    "Decêndio: 20 Nov",
    "Decêndio: 01 Dez",
    "Decêndio: 11 Dez",
    "Decêndio: 20 Dez"
  )
  return(datas)
}
