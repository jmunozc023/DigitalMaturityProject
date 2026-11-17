###############################################################################
# GRAFICOS ADICIONALES SEGUN LA GUIA
# Histogramas, boxplots por grupos y medias con IC95%.
###############################################################################

histogram_panel <- function(values, labels, title, name, breaks = 5) {
  keep <- vapply(values, function(x) sum(is.finite(x)) >= 2, logical(1))
  values <- values[keep]
  labels <- labels[keep]
  if (!length(values)) return(invisible(NULL))
  png(file.path(FIGURE_DIR, paste0(name, ".png")),
      width = 2200, height = 1500, res = 160)
  par(mfrow = c(2, ceiling(length(values) / 2)), mar = c(4, 4, 3, 1),
      oma = c(0, 0, 3, 0),
      family = "sans")
  for (i in seq_along(values)) {
    x <- values[[i]][is.finite(values[[i]])]
    hist(x, breaks = breaks, col = "#A8DADC", border = "white",
         main = labels[i], xlab = "Score", ylab = "Frequency")
  }
  mtext(title, outer = TRUE, line = 1, font = 2, cex = 1.1)
  dev.off()
}

histogram_panel(
  c(list(func_scores$V1_global), list(cit_scores$V2_eficiencia),
    list(cit_scores$V3_digitalizacion), list(cit_scores$V4_satisfaccion),
    list(ciudadanos$NPS1)),
  c("V1 overall", "V2 efficiency", "V3 digitalization", "V4 satisfaction", "Net Promoter Score"),
  "Histograms of main variables", "15_histogramas_variables_principales",
  breaks = 6
)

group_data <- function(values, group) {
  keep <- complete.cases(values, group)
  y <- suppressWarnings(as.numeric(values[keep]))
  g <- droplevels(factor(group[keep]))
  counts <- table(g)
  if (length(counts) < 2 || any(counts < 2)) return(NULL)
  list(y = y, g = g, counts = counts)
}

translate_labels <- function(x, map = NULL) {
  x <- as.character(x)
  if (is.null(map)) return(x)
  idx <- match(x, names(map))
  out <- x
  out[!is.na(idx)] <- unname(map[idx[!is.na(idx)]])
  out
}

plot_group_box <- function(values, group, outcome_label, group_label, name, colour,
                           group_map = NULL) {
  dat <- group_data(values, group)
  if (is.null(dat)) return(invisible(NULL))
  labels <- translate_labels(levels(dat$g), group_map)
  labels <- vapply(strwrap(labels, width = 20, simplify = FALSE),
                   paste, character(1), collapse = "\n")
  png(file.path(FIGURE_DIR, paste0(name, ".png")),
      width = 2200, height = max(1300, 700 + 120 * length(labels)), res = 160)
  par(mar = c(7, 5, 4, 2), family = "sans")
  boxplot(dat$y ~ dat$g, names = labels, ylim = c(1, 5), col = colour,
          border = NA, ylab = outcome_label, xlab = group_label,
          main = paste("Distribution of", outcome_label, "by", group_label))
  stripchart(dat$y ~ dat$g, vertical = TRUE, method = "jitter", add = TRUE,
             pch = 19, col = "#333333")
  abline(h = c(2.5, 3.5, 4.5), lty = 3, col = "grey70")
  dev.off()
}

plot_group_means_ci <- function(values, group, outcome_label, group_label, name, colour,
                                group_map = NULL) {
  dat <- group_data(values, group)
  if (is.null(dat)) return(invisible(NULL))
  means <- tapply(dat$y, dat$g, mean)
  ns <- tapply(dat$y, dat$g, length)
  ses <- tapply(dat$y, dat$g, sd) / sqrt(ns)
  ci <- 1.96 * ses
  labels <- translate_labels(names(means), group_map)
  labels <- vapply(strwrap(labels, width = 20, simplify = FALSE),
                   paste, character(1), collapse = "\n")
  x <- seq_along(means)
  png(file.path(FIGURE_DIR, paste0(name, ".png")),
      width = 2200, height = max(1300, 700 + 120 * length(labels)), res = 160)
  par(mar = c(7, 5, 4, 2), family = "sans")
  plot(NA, type = "n", xlim = c(.5, length(means) + .5), ylim = c(0, 5),
       axes = FALSE, ylab = paste0(outcome_label, " (mean)"), xlab = group_label,
       main = paste("Mean", outcome_label, "by", group_label))
  axis(1, at = x, labels = labels, tick = FALSE, line = 0)
  axis(2, at = 0:5, las = 1)
  abline(h = c(1, 2.5, 3.5, 4.5), lty = 3, col = "grey70")
  rect(x - .35, 0, x + .35, means, col = colour, border = NA)
  lower <- pmax(0, means - ci)
  upper <- pmin(5, means + ci)
  arrows(x, lower, x, upper, angle = 90, code = 3,
         length = .08, lwd = 1.5, col = "#333333")
  label_y <- ifelse(upper > 4.75, upper - .10, upper + .08)
  label_pos <- ifelse(upper > 4.75, 1, 3)
  text(x, label_y, labels = sprintf("%.2f", means), pos = label_pos,
       cex = .85, xpd = NA)
  box()
  dev.off()
}

group_plots <- list(
  list(values = func_scores$V1_global, group = funcionarios$antiguedad,
       outcome = "V1 overall", group_label = "Tenure", prefix = "func_antiguedad",
       group_map = c(`Menos de 1 año` = "Less than 1 year",
                     `1–5 años` = "1–5 years",
                     `6–10 años` = "6–10 years",
                     `más de 10 años` = "More than 10 years")),
  list(values = cit_scores$V2_eficiencia, group = ciudadanos$canal,
       outcome = "V2 efficiency", group_label = "Channel", prefix = "cit_canal_V2",
       group_map = c(Presencial = "In-person", Mixto = "Hybrid", Digital = "Digital")),
  list(values = cit_scores$V3_digitalizacion, group = ciudadanos$canal,
       outcome = "V3 digitalization", group_label = "Channel", prefix = "cit_canal_V3",
       group_map = c(Presencial = "In-person", Mixto = "Hybrid", Digital = "Digital")),
  list(values = cit_scores$V4_satisfaccion, group = ciudadanos$canal,
       outcome = "V4 satisfaction", group_label = "Channel", prefix = "cit_canal_V4",
       group_map = c(Presencial = "In-person", Mixto = "Hybrid", Digital = "Digital")),
  list(values = cit_scores$V2_eficiencia, group = ciudadanos$frecuencia_uso,
       outcome = "V2 efficiency", group_label = "Usage frequency", prefix = "cit_frecuencia_V2",
       group_map = c(`Una vez` = "Once", `2 - 3 veces` = "2–3 times", `4 o más veces` = "4+ times")),
  list(values = cit_scores$V3_digitalizacion, group = ciudadanos$rango_edad,
       outcome = "V3 digitalization", group_label = "Age range", prefix = "cit_edad_V3",
       group_map = c(`30–44` = "30–44", `45–59` = "45–59", `60 o más` = "60+"))
)

for (item in group_plots) {
  plot_group_box(item$values, item$group, item$outcome, item$group_label,
                 paste0("16_boxplot_", item$prefix), "#B7D7A8",
                 group_map = item$group_map)
  plot_group_means_ci(item$values, item$group, item$outcome, item$group_label,
                      paste0("17_medias_IC95_", item$prefix), "#4C956C",
                      group_map = item$group_map)
}

log_message("Histogramas, boxplots y medias con IC95% generados según la guía.")



