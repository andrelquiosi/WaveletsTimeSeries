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
  # Renomear as bandas
  names(ecmwf_step_240_d1_d11_d20) <- c(
    "Precipitação 1 ao 10",
    "Precipitação 11 ao 20",
    "Precipitação 21 ao 30"
  )
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
  ogrInfo(".", "brasil")
  brasil <- readOGR(".", "brasil")

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
  return(parana_sp, parana_spdf)
}

# Função para criar os recortes da Mesorregião do Oeste do Paraná
criar_recortes_oeste_pr <- function() {
  # Carregar coordenadas da Mesorregião do Oeste do Paraná
  oestepr_contorno <- read.table("oestepr_contorno.txt")

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
