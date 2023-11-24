# Intalação de Pacotes
if (!require("raster")) install.packages("raster", repos = "http://cran.us.r-project.org")
if (!require("maptools")) install.packages("maptools", repos = "http://cran.us.r-project.org")
# Carregar Pacotes
packs <- c(
    "raster", "maptools"
)
lapply(packs, require, character.only = TRUE)

# Carregar Funções
source("funcoes.R")


anos <- c("2018", "2019", "2020", "2021", "2022")
meses <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
dias <- c("01", "11", "20")

# selecionar o pixel de interesse
pixel <- 94

# parametro ano corresponde a pasta com os arquivo
# laço para plotar as series temporais: ano, meses e pixel
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
    legenda_decendios <- format.Date(gerar_datas(ano, meses, dias), "%d %b")

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
    # legenda <- paste(
    #     "Serie Temporal de precipitação decendial para o ano ", ano, ".",
    #     "\nCorrespondente a Toledo e Cascavel - PR(pixel ", pixel, ").",
    #     sep = ""
    # )
    legenda <- paste(
        "Serie Temporal para o ano ", ano,
        sep = ""
    )

    # salvar o gráfico em um arquivo png
    nome_arquivo <- paste0(
        "Graficos/serie_temporal_", ano, "_pixel_", pixel, ".png"
    )
    png(nome_arquivo, width = 1000, height = 500, units = "px")
    plot(
        lista_dados_decendios_ano,
        type = "l",
        xlab = "Decendios Mês a Mês (t)",
        ylab = "Precipitação (mm)",
        xaxt = "n",
        yaxt = "n",
        main = NULL,
        cex = 1.5,
        cex.lab = 1.5
    )

    # adicionar os labels para o eixo x e y
    axis(1, at = 1:36, labels = FALSE)
    text(1:36, par("usr")[3] - 1.5,
        srt = 45, adj = 1.1,
        xpd = TRUE, labels = legenda_decendios
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
        col = "blue", adj = c(0, -0.25)
    )

    abline(h = min(lista_dados_decendios_ano), col = "red", lty = 2)
    text(0, min(lista_dados_decendios_ano),
        paste("Mínimo: ", round_min_precipitacao, "mm"),
        col = "red", adj = c(0, +1.1)
    )

    abline(h = mediana_precipitacao, col = "#006100", lty = 2)
    text(0, mediana_precipitacao, paste("Mediana: ", round_mediana_precipitacao, "mm"), col = "#006100", adj = c(0, -0.25))


    dev.off()
}
