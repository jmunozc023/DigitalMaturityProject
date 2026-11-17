###############################################################################
# TRIANGULACION MIXTA
# Integra resultados cuantitativos, revisión documental y hallazgos cualitativos.
# La salida es una matriz de apoyo; la redacción final requiere revisión del investigador.
###############################################################################

qual_file <- file.path(TABLE_DIR, "cualitativo_resumen_categorias.csv")
if (file.exists(qual_file)) {
  read_output <- function(name) {
    path <- file.path(TABLE_DIR, paste0(name, ".csv"))
    if (!file.exists(path)) return(NULL)
    read.csv(path, check.names = FALSE, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  }
  qcat <- read_output("cualitativo_resumen_categorias")
  qcodes <- read_output("cualitativo_resumen_codigos")
  desc_f <- read_output("descriptivos_funcionarios")
  desc_c <- read_output("descriptivos_ciudadanos")
  hypothesis_mix <- read_output("hipotesis_principal_V3_V2")
  doc_levels <- read_output("documental_niveles")

  mean_text <- function(data, variable, label = variable) {
    if (is.null(data) || !("variable" %in% names(data))) return("No disponible")
    hit <- data[data$variable == variable, , drop = FALSE]
    if (!nrow(hit) || !("media" %in% names(hit))) return("No disponible")
    paste0(label, " = ", formatC(hit$media[1], format = "f", digits = 2), " (n = ", hit$n[1], ")")
  }
  category_text <- function(name) {
    if (is.null(qcat)) return("No disponible")
    hit <- qcat[qcat$categoria_principal == name, , drop = FALSE]
    if (!nrow(hit)) return("No disponible")
    paste0(name, ": ", hit$n_entrevistas_con_evidencia[1], "/7 interviews; ", hit$n_codigos[1], " codes")
  }
  hypothesis_text <- if (!is.null(hypothesis_mix) && nrow(hypothesis_mix)) {
    paste0("Method = ", hypothesis_mix$metodo[1], "; p = ", formatC(hypothesis_mix$p_value[1], format = "f", digits = 3), "; decision = ", hypothesis_mix$decision[1])
  } else "Not available"
  documentary_text <- if (!is.null(doc_levels) && nrow(doc_levels)) "Documentary classification available in documental_niveles.csv" else "Not available"

  variable_labels <- c(
    V1_global = "V1 overall",
    estrategia = "Strategy",
    diseno = "Design",
    V2_eficiencia = "V2 efficiency",
    V3_digitalizacion = "V3 digitalization",
    V4_satisfaccion = "V4 satisfaction"
  )

  triang <- data.frame(
    objetivo = c("Objective 1", "Objective 2", "Objective 3", "Integrative question"),
    fuente_cuantitativa = c(
      paste(mean_text(desc_f, "V1_global", variable_labels[["V1_global"]]), ";", mean_text(desc_f, "estrategia", variable_labels[["estrategia"]]), ";", mean_text(desc_f, "diseno", variable_labels[["diseno"]])),
      paste(mean_text(desc_c, "V2_eficiencia", variable_labels[["V2_eficiencia"]]), ";", mean_text(desc_c, "V3_digitalizacion", variable_labels[["V3_digitalizacion"]]), ";", mean_text(desc_c, "V4_satisfaccion", variable_labels[["V4_satisfaccion"]]), ";", hypothesis_text),
      documentary_text,
      "V1, V2-V4/NPS, documentary review, and inferential results"
    ),
    evidencia_cualitativa = c(
      category_text("C2. Barreras organizacionales"),
      paste(category_text("C4. Barreras culturales"), "y demanda ciudadana reportada por funcionarios"),
      paste(category_text("C1. Barreras presupuestarias"), ";", category_text("C2. Barreras organizacionales"), "; categoría emergente de jefatura de TI"),
      "Absence of leadership as the organizing axis; budgetary and normative barriers show greater heterogeneity"
    ),
    evidencia_documental = c(
      "Documentary review as context for institutional maturity",
      "Documentary review as complementary evidence of observable services",
      documentary_text,
      "Documentary review is contrasted with surveys and interviews; it does not replace the other sources"
    ),
    relacion = c(
      "Complementarity: the qualitative evidence proposes an organizational mechanism to interpret the quantitative scores.",
      "Complementarity: staff perceptions about demand, access, and resistance should be distinguished from direct citizen responses.",
      "Expected thematic convergence: interviews identify leadership and coordination as barriers; review their correspondence with V1 and documentary review.",
      "The matrix organizes convergences and divergences; it does not prove causality or generalize beyond the studied context."
    ),
    estado = "Generated automatically; requires final interpretive review",
    stringsAsFactors = FALSE
  )
  write_table(triang, "triangulacion_mixta")
  writeLines(c(
    "MIXED-METHOD TRIANGULATION",
    "",
    "The matrix triangulacion_mixta.csv integrates the available results from the three sources.",
    "The relationship is presented as convergence, complementarity, or divergence to guide the discussion; it is not interpreted as causality.",
    "The final writing should review the definitive quantitative values, negative cases, and the context of each interview."
  ), file.path(ANALYSIS_DIR, "triangulacion_mixta.txt"), useBytes = TRUE)
  writeLines(c(
    "INTEGRATED INTERPRETATION OF RESULTS",
    "",
    "The quantitative component contributes descriptive statistics, reliability, hypothesis tests, and exploratory comparisons; its values should be read alongside sample size and the reported assumptions.",
    "The qualitative component identifies the absence of institutional leadership as the organizing axis of organizational barriers, with an open TI management position as a cross-cutting emergent category.",
    "The qualitative evidence complements the survey by proposing organizational mechanisms that may help interpret maturity and experience scores; it does not replace the quantitative evidence or demonstrate causality.",
    "The budget barrier should be interpreted as dependent on the observation point, and the normative barrier as heterogeneous; these readings should be contrasted with the documentary review and the final results.",
    "The integration should be presented as convergence, complementarity, or divergence across sources and should maintain the limits of a cross-sectional study in a single municipality."
  ), file.path(ANALYSIS_DIR, "interpretacion_resultados_mixtos.txt"), useBytes = TRUE)
  if (file.exists(file.path(ANALYSIS_DIR, "triangulacion_pendiente.txt"))) unlink(file.path(ANALYSIS_DIR, "triangulacion_pendiente.txt"))
  log_message("Matriz de triangulación mixta generada.")
} else {
  log_message("Triangulación mixta pendiente: no existe la salida cualitativa.")
}


