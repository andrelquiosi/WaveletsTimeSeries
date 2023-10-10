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

# Carregar dados do arquico grib#
ecmwf_step_240_201801 <- stack("2018/ecmwf_sfc_Step240_date2018-01-01to2018-01-31_Time00.grib")
ecmwf_step_240_201802 <- stack("2018/ecmwf_sfc_Step240_date2018-02-01to2018-02-28_Time00.grib")
ecmwf_step_240_201803 <- stack("2018/ecmwf_sfc_Step240_date2018-03-01to2018-03-31_Time00.grib")
ecmwf_step_240_201804 <- stack("2018/ecmwf_sfc_Step240_date2018-04-01to2018-04-30_Time00.grib")
ecmwf_step_240_201805 <- stack("2018/ecmwf_sfc_Step240_date2018-05-01to2018-05-31_Time00.grib")
ecmwf_step_240_201806 <- stack("2018/ecmwf_sfc_Step240_date2018-06-01to2018-06-30_Time00.grib")
ecmwf_step_240_201807 <- stack("2018/ecmwf_sfc_Step240_date2018-07-01to2018-07-31_Time00.grib")
ecmwf_step_240_201808 <- stack("2018/ecmwf_sfc_Step240_date2018-08-01to2018-08-31_Time00.grib")
ecmwf_step_240_201809 <- stack("2018/ecmwf_sfc_Step240_date2018-09-01to2018-09-30_Time00.grib")
ecmwf_step_240_201810 <- stack("2018/ecmwf_sfc_Step240_date2018-10-01to2018-10-31_Time00.grib")
ecmwf_step_240_201811 <- stack("2018/ecmwf_sfc_Step240_date2018-11-01to2018-11-30_Time00.grib")
ecmwf_step_240_201812 <- stack("2018/ecmwf_sfc_Step240_date2018-12-01to2018-12-31_Time00.grib")
ecmwf_step_240_201901 <- stack("2019/ecmwf_sfc_Step240_date2019-01-01to2019-01-31_Time00.grib")
ecmwf_step_240_201902 <- stack("2019/ecmwf_sfc_Step240_date2019-02-01to2019-02-28_Time00.grib")
ecmwf_step_240_201903 <- stack("2019/ecmwf_sfc_Step240_date2019-03-01to2019-03-31_Time00.grib")
ecmwf_step_240_201904 <- stack("2019/ecmwf_sfc_Step240_date2019-04-01to2019-04-30_Time00.grib")
ecmwf_step_240_201905 <- stack("2019/ecmwf_sfc_Step240_date2019-05-01to2019-05-31_Time00.grib")
ecmwf_step_240_201906 <- stack("2019/ecmwf_sfc_Step240_date2019-06-01to2019-06-30_Time00.grib")
ecmwf_step_240_201907 <- stack("2019/ecmwf_sfc_Step240_date2019-07-01to2019-07-31_Time00.grib")
ecmwf_step_240_201908 <- stack("2019/ecmwf_sfc_Step240_date2019-08-01to2019-08-31_Time00.grib")
ecmwf_step_240_201909 <- stack("2019/ecmwf_sfc_Step240_date2019-09-01to2019-09-30_Time00.grib")
ecmwf_step_240_201910 <- stack("2019/ecmwf_sfc_Step240_date2019-10-01to2019-10-31_Time00.grib")
ecmwf_step_240_201911 <- stack("2019/ecmwf_sfc_Step240_date2019-11-01to2019-11-30_Time00.grib")
ecmwf_step_240_201912 <- stack("2019/ecmwf_sfc_Step240_date2019-12-01to2019-12-31_Time00.grib")
ecmwf_step_240_202001 <- stack("2020/ecmwf_sfc_Step240_date2020-01-01to2020-01-31_Time00.grib")
ecmwf_step_240_202002 <- stack("2020/ecmwf_sfc_Step240_date2020-02-01to2020-02-29_Time00.grib")
ecmwf_step_240_202003 <- stack("2020/ecmwf_sfc_Step240_date2020-03-01to2020-03-31_Time00.grib")
ecmwf_step_240_202004 <- stack("2020/ecmwf_sfc_Step240_date2020-04-01to2020-04-30_Time00.grib")
ecmwf_step_240_202005 <- stack("2020/ecmwf_sfc_Step240_date2020-05-01to2020-05-31_Time00.grib")
ecmwf_step_240_202006 <- stack("2020/ecmwf_sfc_Step240_date2020-06-01to2020-06-30_Time00.grib")
ecmwf_step_240_202007 <- stack("2020/ecmwf_sfc_Step240_date2020-07-01to2020-07-31_Time00.grib")
ecmwf_step_240_202008 <- stack("2020/ecmwf_sfc_Step240_date2020-08-01to2020-08-31_Time00.grib")
ecmwf_step_240_202009 <- stack("2020/ecmwf_sfc_Step240_date2020-09-01to2020-09-30_Time00.grib")
ecmwf_step_240_202010 <- stack("2020/ecmwf_sfc_Step240_date2020-10-01to2020-10-31_Time00.grib")
ecmwf_step_240_202011 <- stack("2020/ecmwf_sfc_Step240_date2020-11-01to2020-11-30_Time00.grib")
ecmwf_step_240_202012 <- stack("2020/ecmwf_sfc_Step240_date2020-12-01to2020-12-31_Time00.grib")
ecmwf_step_240_202101 <- stack("2021/ecmwf_sfc_Step240_date2021-01-01to2021-01-31_Time00.grib")
ecmwf_step_240_202102 <- stack("2021/ecmwf_sfc_Step240_date2021-02-01to2021-02-28_Time00.grib")
ecmwf_step_240_202103 <- stack("2021/ecmwf_sfc_Step240_date2021-03-01to2021-03-31_Time00.grib")
ecmwf_step_240_202104 <- stack("2021/ecmwf_sfc_Step240_date2021-04-01to2021-04-30_Time00.grib")
ecmwf_step_240_202105 <- stack("2021/ecmwf_sfc_Step240_date2021-05-01to2021-05-31_Time00.grib")
ecmwf_step_240_202106 <- stack("2021/ecmwf_sfc_Step240_date2021-06-01to2021-06-30_Time00.grib")
ecmwf_step_240_202107 <- stack("2021/ecmwf_sfc_Step240_date2021-07-01to2021-07-31_Time00.grib")
ecmwf_step_240_202108 <- stack("2021/ecmwf_sfc_Step240_date2021-08-01to2021-08-31_Time00.grib")
ecmwf_step_240_202109 <- stack("2021/ecmwf_sfc_Step240_date2021-09-01to2021-09-30_Time00.grib")
ecmwf_step_240_202110 <- stack("2021/ecmwf_sfc_Step240_date2021-10-01to2021-10-31_Time00.grib")
ecmwf_step_240_202111 <- stack("2021/ecmwf_sfc_Step240_date2021-11-01to2021-11-30_Time00.grib")
ecmwf_step_240_202112 <- stack("2021/ecmwf_sfc_Step240_date2021-12-01to2021-12-31_Time00.grib")
ecmwf_step_240_202201 <- stack("2022/ecmwf_sfc_Step240_date2022-01-01to2022-01-31_Time00.grib")
ecmwf_step_240_202202 <- stack("2022/ecmwf_sfc_Step240_date2022-02-01to2022-02-28_Time00.grib")
ecmwf_step_240_202203 <- stack("2022/ecmwf_sfc_Step240_date2022-03-01to2022-03-31_Time00.grib")
ecmwf_step_240_202204 <- stack("2022/ecmwf_sfc_Step240_date2022-04-01to2022-04-30_Time00.grib")
ecmwf_step_240_202205 <- stack("2022/ecmwf_sfc_Step240_date2022-05-01to2022-05-31_Time00.grib")
ecmwf_step_240_202206 <- stack("2022/ecmwf_sfc_Step240_date2022-06-01to2022-06-30_Time00.grib")
ecmwf_step_240_202207 <- stack("2022/ecmwf_sfc_Step240_date2022-07-01to2022-07-31_Time00.grib")
ecmwf_step_240_202208 <- stack("2022/ecmwf_sfc_Step240_date2022-08-01to2022-08-31_Time00.grib")
ecmwf_step_240_202209 <- stack("2022/ecmwf_sfc_Step240_date2022-09-01to2022-09-30_Time00.grib")
ecmwf_step_240_202210 <- stack("2022/ecmwf_sfc_Step240_date2022-10-01to2022-10-31_Time00.grib")
ecmwf_step_240_202211 <- stack("2022/ecmwf_sfc_Step240_date2022-11-01to2022-11-30_Time00.grib")
ecmwf_step_240_202212 <- stack("2022/ecmwf_sfc_Step240_date2022-12-01to2022-12-31_Time00.grib")
#####################

# Empilhar os dados de precipitação
ecmwf_step_240_201801_t00_d1_d11_d20 <-
  prepara_plot_decendios(ecmwf_step_240_201801)
# Plotar os dados
spplot(ecmwf_step_240_201801_t00_d1_d11_d20, scales = list(draw = TRUE))

# Criar os recortes do Paraná e da Mesorregião do Oeste do Paraná
mapa_parana <- criar_recortes_pr()
oestepr_sp <- criar_recortes_oeste_pr()
circulo_toledo_cascavel <- criar_circulo_toledo_cascavel()

clipe_ecmwf_step_240_201801T00_d1_d11_d20_soma_raster <-
  processa_dados_precipitacao(ecmwf_step_240_201801, mapa_parana[[1]])

# Plotar os dados no mapa do Paraná com a Mesorregião do Oeste do Paraná
spplot(
  clipe_ecmwf_step_240_201801T00_d1_d11_d20_soma_raster,
  scales = list(draw = TRUE),
  sp.layout = list(list(mapa_parana[[2]], oestepr_sp, first = FALSE))
)

# Plotar o círculo
spplot(
  clipe_ecmwf_step_240_201801T00_d1_d11_d20_soma_raster,
  scales = list(draw = TRUE),
  sp.layout = list(
    list(mapa_parana[[2]], oestepr_sp, first = FALSE),
    list(oestepr_sp, lwd = 2, first = FALSE),
    list(circulo_toledo_cascavel, lwd = 2, first = FALSE)
  )
)

spplot(
  clipe_ecmwf_step_240_201801T00_d1_d11_d20_soma_raster,
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
