###############################################################################
# GRAFICO DE CONSISTENCIA INTERNA
# Se ejecuta después de calcular el objeto `reliability`.
###############################################################################

alpha_plot <- reliability[is.finite(reliability$alfa), , drop = FALSE]
if (nrow(alpha_plot) > 0) {
  alpha_labels <- c(
    V1_estrategia = "V1 Strategy",
    V1_participacion = "V1 Participation",
    V1_diseno = "V1 Design",
    V1_transicion = "V1 Transition",
    V1_operacion = "V1 Operation",
    V1_mejora_continua = "V1 Continuous improvement",
    V1_global_24_items = "V1 Overall (24 items)",
    V2_eficiencia = "V2 Efficiency",
    V3_digitalizacion = "V3 Digitalization",
    V4_satisfaccion = "V4 Satisfaction"
  )
  labels <- unname(alpha_labels[alpha_plot$escala])
  labels[is.na(labels)] <- alpha_plot$escala[is.na(labels)]
  order_alpha <- order(alpha_plot$alfa)
  values <- alpha_plot$alfa[order_alpha]
  labels <- labels[order_alpha]
  colours <- cut(values,
                 breaks = c(-Inf, .60, .70, .80, .90, Inf),
                 labels = c("#D1495B", "#F4A261", "#E9C46A", "#4C956C", "#2A9D8F"),
                 right = FALSE)
  colours <- as.character(colours)
  png(file.path(FIGURE_DIR, "12_confiabilidad_alpha.png"),
      width = 2400, height = 1800, res = 160)
  par(mar = c(5, 22, 4, 3), las = 1, family = "sans")
  bp <- barplot(values, horiz = TRUE, names.arg = labels,
                xlim = c(min(0, min(values) - .10), max(1, max(values) + .15)),
                col = colours, border = NA, xlab = "Cronbach's alpha",
                main = "Cronbach's alpha by scale")
  abline(v = c(.60, .70, .80, .90), lty = 3, lwd = 1, col = "#777777")
  text(values, bp, labels = sprintf("%.2f", values),
       pos = ifelse(values >= 0, 4, 2), cex = .9, xpd = NA)
  legend("bottomright",
         legend = c("Excellent >= .90", "Good .80-.89", "Acceptable .70-.79",
                    "Questionable .60-.69", "Unacceptable < .60"),
         fill = c("#2A9D8F", "#4C956C", "#E9C46A", "#F4A261", "#D1495B"),
         border = NA, bty = "n", cex = .9)
  dev.off()
}

log_message("Gráfico de confiabilidad generado en: ", FIGURE_DIR)
