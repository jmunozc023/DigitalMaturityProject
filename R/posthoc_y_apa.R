###############################################################################
# Post hoc y resumen APA 7
# Este archivo se ejecuta desde analisis_cuantitativo.R cuando ya existen los
# datos, puntajes y funciones de exportación del análisis principal.
###############################################################################

posthoc_one <- function(data, outcome, group, dataset) {
  keep <- complete.cases(data[[outcome]], data[[group]])
  y <- suppressWarnings(as.numeric(data[[outcome]][keep]))
  g <- droplevels(factor(data[[group]][keep]))
  counts <- table(g)
  if (length(counts) < 3 || any(counts < 2)) return(NULL)

  lev <- car::leveneTest(y ~ g)[1, "Pr(>F)"]
  if (!is.na(lev) && lev >= .05) {
    tukey <- stats::TukeyHSD(stats::aov(y ~ g))$g
    result <- as.data.frame(tukey)
    result$contraste <- rownames(result)
    rownames(result) <- NULL
    names(result)[names(result) == "diff"] <- "diferencia_media"
    names(result)[names(result) == "lwr"] <- "ic95_inferior"
    names(result)[names(result) == "upr"] <- "ic95_superior"
    names(result)[names(result) == "p adj"] <- "p_ajustado"
    result$dataset <- dataset
    result$dependiente <- outcome
    result$agrupacion <- group
    result$metodo <- "Tukey"
    result$nota <- NA_character_
    return(result[, c("dataset", "dependiente", "agrupacion", "metodo",
                      "contraste", "diferencia_media", "ic95_inferior",
                      "ic95_superior", "p_ajustado", "nota")])
  }

  if (!requireNamespace("rstatix", quietly = TRUE)) {
    return(data.frame(dataset = dataset, dependiente = outcome, agrupacion = group,
                      metodo = "Games-Howell pendiente",
                      contraste = NA, diferencia_media = NA,
                      ic95_inferior = NA, ic95_superior = NA, p_ajustado = NA,
                      nota = "Instale rstatix para ejecutar Games-Howell"))
  }
  gh <- rstatix::games_howell_test(data.frame(value = y, group = g), value ~ group)
  data.frame(dataset = dataset, dependiente = outcome, agrupacion = group,
             metodo = "Games-Howell", contraste = paste(gh$group1, gh$group2, sep = " - "),
             diferencia_media = gh$estimate, ic95_inferior = gh$conf.low,
             ic95_superior = gh$conf.high, p_ajustado = gh$p.adj, nota = NA_character_)
}

posthoc_results <- list()
for (g in group_vars_func) {
  posthoc_results[[length(posthoc_results) + 1]] <- posthoc_one(
    data.frame(V1_global = func_scores$V1_global, group = funcionarios[[g]]),
    "V1_global", "group", "funcionarios"
  )
}
for (g in group_vars_cit) {
  for (y in c("V2_eficiencia", "V3_digitalizacion", "V4_satisfaccion")) {
    posthoc_results[[length(posthoc_results) + 1]] <- posthoc_one(
      data.frame(outcome = cit_scores[[y]], group = ciudadanos[[g]]),
      "outcome", "group", "ciudadanos"
    )
  }
}
posthoc_results <- posthoc_results[!vapply(posthoc_results, is.null, logical(1))]
if (length(posthoc_results)) {
  posthoc <- do.call(rbind, posthoc_results)
} else {
  posthoc <- data.frame(nota = "No hubo ANOVA estimables con tres o más grupos")
}
write_table(posthoc, "posthoc_Tukey_o_GamesHowell")

format_p_apa <- function(p) {
  if (is.na(p)) return("p no estimable")
  if (p < .001) return("p < .001")
  paste0("p = ", formatC(p, format = "f", digits = 3))
}

apa_lines <- c(
  "RESUMEN DE RESULTADOS EN FORMATO APA 7",
  "",
  "Hipótesis principal: relación entre V3 (digitalización percibida) y V2 (eficiencia administrativa percibida)."
)
if (nrow(hypothesis) > 0 && !is.na(hypothesis$p_value[1])) {
  apa_lines <- c(apa_lines,
    paste0("Se realizó una correlación ", hypothesis$metodo[1],
           ", r = ", formatC(hypothesis$estimador[1], format = "f", digits = 2),
           ", ", format_p_apa(hypothesis$p_value[1]), ", n = ", hypothesis$n[1], ". ",
           hypothesis$decision[1], ". El tamaño del efecto fue ",
           hypothesis$interpretacion[1], "."))
} else {
  apa_lines <- c(apa_lines, "La hipótesis principal no fue estimable con las respuestas disponibles.")
}
apa_lines <- c(apa_lines, "",
               "Las comparaciones por grupos son exploratorias; solo se ejecutan cuando existen al menos dos observaciones por grupo.",
               "Las tablas incluyen estadístico, grados de libertad, valor p y tamaño del efecto.",
               "Con la muestra parcial actual, los resultados de confiabilidad e inferencia deben interpretarse como preliminares.")
writeLines(apa_lines, file.path(ANALYSIS_DIR, "resumen_APA7.txt"), useBytes = TRUE)
