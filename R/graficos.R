###############################################################################
# GRAFICOS DEL ANALISIS CUANTITATIVO
# Se ejecuta desde analisis_cuantitativo.R después de construir los puntajes.
###############################################################################

FIGURE_DIR <- file.path(ANALYSIS_DIR, "figures")
dir.create(FIGURE_DIR, recursive = TRUE, showWarnings = FALSE)

save_png <- function(name, width = 1800, height = 1200) {
  png(file.path(FIGURE_DIR, paste0(name, ".png")),
      width = width, height = height, res = 160)
  par(mar = c(5, 12, 4, 2), las = 1, family = "sans")
}

translate_labels <- function(x, map = NULL) {
  x <- as.character(x)
  if (is.null(map)) return(x)
  idx <- match(x, names(map))
  out <- x
  out[!is.na(idx)] <- unname(map[idx[!is.na(idx)]])
  out
}

format_p3 <- function(p) {
  if (is.na(p)) return("NA")
  p <- max(p, 0.001)
  formatC(p, format = "f", digits = 3)
}

md_item_labels <- c(
  setNames(sprintf("MD%02d — Strategy item %d", 1:4, 1:4), sprintf("MD%02d", 1:4)),
  setNames(sprintf("MD%02d — Participation item %d", 5:8, 1:4), sprintf("MD%02d", 5:8)),
  setNames(sprintf("MD%02d — Design item %d", 9:12, 1:4), sprintf("MD%02d", 9:12)),
  setNames(sprintf("MD%02d — Transition item %d", 13:16, 1:4), sprintf("MD%02d", 13:16)),
  setNames(sprintf("MD%02d — Operation item %d", 17:20, 1:4), sprintf("MD%02d", 17:20)),
  setNames(sprintf("MD%02d — Continuous improvement item %d", 21:24, 1:4), sprintf("MD%02d", 21:24))
)

cit_item_labels <- c(
  setNames(sprintf("EA%02d — Efficiency item %d", 1:8, 1:8), sprintf("EA%02d", 1:8)),
  setNames(sprintf("DGP%02d — Digitalization item %d", 1:5, 1:5), sprintf("DGP%02d", 1:5)),
  setNames(sprintf("SAT%02d — Satisfaction item %d", 1:5, 1:5), sprintf("SAT%02d", 1:5))
)

plot_scale_means <- function(scores, variables, labels, title, name, colour) {
  means <- vapply(variables, function(v) mean(scores[[v]], na.rm = TRUE), numeric(1))
  means[!is.finite(means)] <- NA_real_
  keep <- !is.na(means)
  if (!any(keep)) return(invisible(NULL))
  values <- means[keep]
  labs <- labels[keep]
  order_idx <- order(values)
  values <- values[order_idx]
  labs <- labs[order_idx]
  y <- seq_along(values)
  save_png(name)
  left_margin <- min(26, max(12, max(nchar(labs)) + 2))
  par(mar = c(5, left_margin, 4, 2), las = 1, family = "sans")
  plot(NA, type = "n", xlim = c(0, 5), ylim = c(.5, length(values) + .5),
       axes = FALSE, xlab = "Mean score (1–5 scale)", ylab = "", main = title)
  axis(1, at = 0:5, labels = 0:5)
  axis(2, at = y, labels = labs, las = 1)
  abline(v = c(1, 2.5, 3.5, 4.5), lty = 3, col = "grey70")
  rect(0, y - .35, values, y + .35, col = colour, border = NA)
  label_x <- ifelse(values > 4.7, values - .08, values + .08)
  label_pos <- ifelse(values > 4.7, 2, 4)
  text(label_x, y, labels = sprintf("%.2f", values),
       pos = label_pos, cex = .9, xpd = NA)
  box()
  dev.off()
}

plot_scale_means(func_scores,
                 c("estrategia", "participacion", "diseno", "transicion",
                   "operacion", "mejora_continua"),
                 c("Strategy", "Participation", "Design", "Transition",
                   "Operation", "Continuous improvement"),
                 "Institutional digital maturity by KPA",
                 "01_medias_funcionarios_kpa", "#2E6F95")

plot_scale_means(cit_scores,
                 c("V2_eficiencia", "V3_digitalizacion", "V4_satisfaccion"),
                 c("V2 Efficiency", "V3 Digitalization", "V4 Satisfaction"),
                 "Main citizen experience indicators",
                 "02_medias_ciudadania", "#4C956C")

plot_scale_means(funcionarios, MD, md_item_labels[MD],
                 "Item-level means: institutional digital maturity",
                 "13_medias_items_MD", "#2E6F95")
plot_scale_means(ciudadanos, c(EA, DGP, SAT), cit_item_labels[c(EA, DGP, SAT)],
                 "Item-level means: citizen experience",
                 "14_medias_items_ciudadania", "#4C956C")

###############################################################################
# Distribución de los resultados principales
###############################################################################

box_data <- cit_scores[, c("V2_eficiencia", "V3_digitalizacion", "V4_satisfaccion")]
box_data <- lapply(box_data, function(x) x[is.finite(x)])
if (sum(vapply(box_data, length, integer(1))) > 0) {
  png(file.path(FIGURE_DIR, "03_distribucion_ciudadania.png"),
      width = 1800, height = 1200, res = 160)
  par(mar = c(5, 5, 4, 2), family = "sans")
  boxplot(box_data, names = c("V2\nEfficiency", "V3\nDigitalization", "V4\nSatisfaction"),
          ylim = c(1, 5), col = c("#2E6F95", "#4C956C", "#D9A441"),
          ylab = "Average score (1–5)",
          main = "Distribution of citizen scores")
  abline(h = c(2.5, 3.5, 4.5), lty = 3, col = "grey60")
  dev.off()
}

###############################################################################
# Hipótesis principal: V3 y V2
###############################################################################

xy <- complete.cases(cit_scores$V2_eficiencia, cit_scores$V3_digitalizacion)
if (sum(xy) >= 3) {
  x <- cit_scores$V2_eficiencia[xy]
  y <- cit_scores$V3_digitalizacion[xy]
  fit <- lm(y ~ x)
  png(file.path(FIGURE_DIR, "04_relacion_V3_V2.png"),
      width = 1800, height = 1200, res = 160)
  par(mar = c(5, 5, 4, 2), family = "sans")
  plot(x, y, pch = 19, col = "#2E6F95", xlim = c(1, 5), ylim = c(1, 5),
       xlab = "V2. Perceived administrative efficiency",
       ylab = "V3. Perceived digitalization",
       main = "Relationship between perceived efficiency and digitalization")
  abline(fit, col = "#D1495B", lwd = 2)
  abline(v = c(2.5, 3.5, 4.5), h = c(2.5, 3.5, 4.5),
         lty = 3, col = "grey75")
  if (exists("hypothesis") && nrow(hypothesis) > 0 && !is.na(hypothesis$estimador[1])) {
    legend("topleft", bty = "n",
           legend = paste0(hypothesis$metodo[1], ": r = ",
                           formatC(hypothesis$estimador[1], digits = 2, format = "f"),
                        ", p = ", format_p3(hypothesis$p_value[1])),
           text.col = "#333333")
  }
  dev.off()
}

###############################################################################
# Variables categóricas de ciudadanía
###############################################################################

plot_frequency <- function(x, title, name, colour = "#4C956C", wrap_width = 24,
                           label_map = NULL) {
  x <- x[!is.na(x) & trimws(x) != ""]
  if (!length(x)) return(invisible(NULL))
  x <- translate_labels(x, label_map)
  counts <- sort(table(x), decreasing = FALSE)
  labels <- vapply(strwrap(names(counts), width = wrap_width, simplify = FALSE),
                    paste, character(1), collapse = "\n")
  left_margin <- ifelse(max(nchar(labels)) > 18, 20, 14)
  png(file.path(FIGURE_DIR, paste0(name, ".png")),
      width = 2200, height = max(1200, 600 + 110 * length(counts)), res = 160)
  par(mar = c(5, left_margin, 4, 3), las = 1, family = "sans")
  bp <- barplot(counts, horiz = TRUE, names.arg = labels,
                col = colour, border = NA, xlab = "Frequency", main = title)
  text(as.numeric(counts), bp, labels = as.numeric(counts),
       pos = 4, cex = .9, xpd = NA)
  dev.off()
}
plot_frequency(ciudadanos$canal, "Typical service channel", "05_canal_ciudadania",
               label_map = c(Presencial = "In-person", Mixto = "Hybrid", Digital = "Digital"))
plot_frequency(ciudadanos$frecuencia_uso, "Usage frequency in the last year", "06_frecuencia_ciudadania",
               label_map = c(`Una vez` = "Once", `2 - 3 veces` = "2–3 times", `4 o más veces` = "4+ times"))
plot_frequency(ciudadanos$rango_edad, "Citizen age range", "07_edad_ciudadania",
               label_map = c(`30–44` = "30–44", `45–59` = "45–59", `60 o más` = "60+"))
plot_frequency(ciudadanos$tipo_tramite, "Most frequently completed service type", "08_tipo_tramite_ciudadania",
               label_map = c(`Certificaciones` = "Certificates",
                             `Consulta generales` = "General inquiries",
                             `Denuncias ambientales` = "Environmental complaints",
                             `Impuestos municipales` = "Municipal taxes",
                             `Pago de mantenimiento del cementerio.` = "Cemetery maintenance payment",
                             `Patentes comerciales` = "Business licenses"))

###############################################################################
# NPS
###############################################################################

nps_values <- suppressWarnings(as.numeric(ciudadanos$NPS1))
nps_values <- nps_values[is.finite(nps_values)]
if (length(nps_values)) {
  categories <- ifelse(nps_values >= 9, "Promoters",
                       ifelse(nps_values >= 7, "Passives", "Detractors"))
  counts <- table(factor(categories, levels = c("Detractors", "Passives", "Promoters")))
  png(file.path(FIGURE_DIR, "09_NPS.png"), width = 2000, height = 1400, res = 160)
  par(mar = c(5, 5, 5, 3), family = "sans")
  bp <- barplot(counts, ylim = c(0, max(counts) * 1.30 + 1),
                col = c("#D1495B", "#D9A441", "#4C956C"),
                border = NA, ylab = "Frequency", main = "Net Promoter Score distribution")
  text(bp, as.numeric(counts), labels = as.numeric(counts), pos = 3, offset = .4, cex = .95, xpd = NA)
  abline(h = 0, col = "grey30")
  dev.off()
}

###############################################################################
# Revisión documental
###############################################################################

levels_doc <- documental$digital_level
levels_doc <- levels_doc[!is.na(levels_doc) & trimws(levels_doc) != ""]
if (length(levels_doc)) {
  order_levels <- c("Presencial", "Informativo", "Parcialmente digital",
                    "Digital transaccional", "Digital completo")
  counts <- table(factor(levels_doc, levels = order_levels))
  level_map <- c(
    Presencial = "In-person",
    Informativo = "Informational",
    `Parcialmente digital` = "Partially digital",
    `Digital transaccional` = "Transactional digital",
    `Digital completo` = "Fully digital"
  )
  labels <- translate_labels(names(counts), level_map)
  labels <- vapply(strwrap(labels, width = 24, simplify = FALSE),
                    paste, character(1), collapse = "\n")
  png(file.path(FIGURE_DIR, "10_niveles_documental.png"),
      width = 2200, height = 1400, res = 160)
  par(mar = c(5, 22, 4, 3), las = 1, family = "sans")
  bp <- barplot(counts, horiz = TRUE, names.arg = labels,
                col = "#7A5195", border = NA, xlab = "Frequency",
                main = "Overall documentary maturity classification")
  text(as.numeric(counts), bp, labels = as.numeric(counts),
       pos = 4, cex = .95, xpd = NA)
  dev.off()
}
rd_matrix <- sapply(documental[, RD, drop = FALSE], function(x) {
  key <- toupper(trimws(as.character(x)))
  c(Cumple = sum(key == "1", na.rm = TRUE),
    `No cumple` = sum(key == "0", na.rm = TRUE),
    `No aplica` = sum(key %in% c("NA", "N/A", "N_A"), na.rm = TRUE),
    `No verificable` = sum(key %in% c("NV", "N/V", "N_V"), na.rm = TRUE))
})
if (length(rd_matrix)) {
  png(file.path(FIGURE_DIR, "11_criterios_documental.png"),
      width = 2200, height = 1400, res = 160)
  par(mar = c(5, 5, 4, 2), family = "sans")
  barplot(rd_matrix, beside = TRUE,
          col = c("#4C956C", "#D1495B", "#D9A441", "#7A5195"),
          names.arg = RD, ylab = "Frequency",
          main = "Documentary review criteria")
  legend("topright", legend = c("Complies", "Does not comply", "Not applicable", "Not verifiable"),
         fill = c("#4C956C", "#D1495B", "#D9A441", "#7A5195"),
         bty = "n")
  dev.off()
}

log_message("Gráficos cuantitativos generados en: ", FIGURE_DIR)
