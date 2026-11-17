###############################################################################
# ANALISIS COMPLEMENTARIOS RECOMENDADOS EN LA GUIA
# Chi-cuadrado y regresión se reportan como exploratorios: no reemplazan la
# hipótesis formal V3-V2 ni implican causalidad.
###############################################################################

safe_file_name <- function(x) {
  x <- iconv(x, to = "ASCII//TRANSLIT")
  gsub("[^A-Za-z0-9]+", "_", x)
}

chi_square_one <- function(data, x, y, dataset) {
  keep <- complete.cases(data[[x]], data[[y]])
  tab <- table(data[[x]][keep], data[[y]][keep])
  if (nrow(tab) < 2 || ncol(tab) < 2) {
    return(data.frame(dataset = dataset, variable_1 = x, variable_2 = y,
                      n = sum(tab), chi2 = NA, gl = NA, p_value = NA,
                      min_expected = NA, decision = "No estimable",
                      nota = "Se requieren al menos dos categorías por variable"))
  }
  test <- suppressWarnings(stats::chisq.test(tab, correct = FALSE))
  expected <- unname(test$expected)
  p <- test$p.value
  observed <- as.data.frame.matrix(tab)
  observed$variable_1 <- rownames(observed)
  rownames(observed) <- NULL
  write_table(observed, paste0("contingencia_", safe_file_name(dataset), "_",
                               safe_file_name(x), "_", safe_file_name(y)))
  data.frame(dataset = dataset, variable_1 = x, variable_2 = y,
             n = sum(tab), chi2 = unname(test$statistic), gl = unname(test$parameter),
             p_value = p, min_expected = min(expected),
             decision = ifelse(p < .05, "Se rechaza H0", "No se rechaza H0"),
             nota = ifelse(min(expected) < 5,
                           "Exploratorio: hay frecuencias esperadas menores que 5",
                           "Exploratorio; interpretar como asociación, no causalidad"),
             stringsAsFactors = FALSE)
}

chi_square <- rbind(
  chi_square_one(ciudadanos, "canal", "frecuencia_uso", "ciudadanos"),
  chi_square_one(ciudadanos, "rango_edad", "canal", "ciudadanos"),
  chi_square_one(ciudadanos, "tipo_tramite", "canal", "ciudadanos")
)
write_table(chi_square, "chi_cuadrado_exploratorio")

###############################################################################
# Regresión lineal simple exploratoria: V2 como resultado y V3 como predictor
###############################################################################

complete <- complete.cases(cit_scores$V2_eficiencia, cit_scores$V3_digitalizacion)
if (sum(complete) >= 3) {
  regression_model <- stats::lm(V2_eficiencia ~ V3_digitalizacion,
                                data = data.frame(V2_eficiencia = cit_scores$V2_eficiencia[complete],
                                                  V3_digitalizacion = cit_scores$V3_digitalizacion[complete]))
  model_summary <- summary(regression_model)
  coefficient <- model_summary$coefficients
  regression <- data.frame(
    modelo = "V2_eficiencia ~ V3_digitalizacion",
    n = sum(complete),
    intercepto = coefficient[1, "Estimate"],
    pendiente_V3 = coefficient[2, "Estimate"],
    p_pendiente = coefficient[2, "Pr(>|t|)"],
    R2 = model_summary$r.squared,
    R2_ajustado = model_summary$adj.r.squared,
    F = unname(model_summary$fstatistic[1]),
    gl_modelo = unname(model_summary$fstatistic[2]),
    gl_error = unname(model_summary$fstatistic[3]),
    interpretacion = "Exploratoria; no implica que V3 cause V2",
    stringsAsFactors = FALSE
  )
} else {
  regression <- data.frame(modelo = "V2_eficiencia ~ V3_digitalizacion",
                           n = sum(complete), intercepto = NA, pendiente_V3 = NA,
                           p_pendiente = NA, R2 = NA, R2_ajustado = NA, F = NA,
                           gl_modelo = NA, gl_error = NA,
                           interpretacion = "No estimable con los casos completos disponibles")
}
write_table(regression, "regresion_exploratoria_V2_V3")
