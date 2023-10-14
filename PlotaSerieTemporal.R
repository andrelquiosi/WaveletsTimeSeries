# obter os valores mínimos e máximos de precipitação arredondados
min_precipitacao <- floor(min(lista_dados_decendios_ano))
max_precipitacao <- ceiling(max(lista_dados_decendios_ano))

# plotar os dados de precipitação 3 decêndios
# para o pixel selecionado em um ano específico em um gráfico de linha
legenda <- paste(
    "Serie Temporal de Precipitação decendial para o ano ", ano, " pixel ", pixel
)
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
    main = legenda

)
legend("topleft", legend = c("Máximo", "Mínimo"), col = c("red", "blue"), pch = 20, cex = 2)
axis(1, at = 1:36, labels = datas_decendios, las = 2, cex.axis = 0.7)
axis(2, at = min_precipitacao:max_precipitacao, las = 3, cex.axis = 1)
points(which(lista_dados_decendios_ano == max(lista_dados_decendios_ano)), max(lista_dados_decendios_ano), col = "red", pch = 20, cex = 5)
points(which(lista_dados_decendios_ano == min(lista_dados_decendios_ano)), min(lista_dados_decendios_ano), col = "blue", pch = 20, cex = 5)
dev.off()
