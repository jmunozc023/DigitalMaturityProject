###############################################################################
# ACTUALIZACION DE ENTREGABLES METODOLOGICOS CON EVIDENCIA CUALITATIVA
###############################################################################

qual_available <- file.exists(file.path(TABLE_DIR, "cualitativo_resumen_categorias.csv"))
if (qual_available) {
  validacion <- read.csv(file.path(TABLE_DIR, "validacion_metodologica.csv"),
                         check.names = FALSE, stringsAsFactors = FALSE,
                         fileEncoding = "UTF-8")
  idx <- grepl("Calidad cualitativa", validacion$componente)
  validacion$estado[idx] <- c("Documented with partial scope", "Documented with contextual limitation", "Partially documented")
  validacion$evidencia_disponible[idx] <- c(
    "7 interviews, codebook, coding matrix, and anonymized verbatims",
    "Manifest of units and roles; municipal context described",
    "Codebook, manifest, coding matrix, and reproducible output"
  )
  validacion$accion_siguiente[idx] <- c(
    "Record participant feedback or peer review if it is carried out",
    "Specify contextual scope and case selection criteria",
    "Version memos, codebook changes, and analytical decisions"
  )
  write_table(validacion, "validacion_metodologica")

  objectives <- read.csv(file.path(TABLE_DIR, "matriz_objetivos_resultados.csv"),
                         check.names = FALSE, stringsAsFactors = FALSE,
                         fileEncoding = "UTF-8")
  objectives$estado_actual[objectives$objetivo == "OE3"] <- "Available: 7 interviews, open/axial coding, and interpretive synthesis"
  objectives$estado_actual[objectives$objetivo == "Triangulation"] <- "Prepared: the integration must be recalculated and reviewed with the definitive quantitative data"
  objectives$salida[objectives$objetivo == "OE3"] <- "cualitativo_resumen_categorias.csv, cualitativo_matriz_codificacion.csv, and interpretacion_cualitativa.txt"
  objectives$salida[objectives$objetivo == "Triangulation"] <- "triangulacion_mixta.csv and triangulacion_mixta.txt"
  write_table(objectives, "matriz_objetivos_resultados")

  limitations <- read.csv(file.path(TABLE_DIR, "limitaciones_actuales.csv"),
                          check.names = FALSE, stringsAsFactors = FALSE,
                          fileEncoding = "UTF-8")
  limitations$limitacion[limitations$limitacion == "Falta de entrevistas"] <- "Scope and selection of the qualitative corpus"
  limitations$impacto_potencial[limitations$limitacion == "Scope and selection of the qualitative corpus"] <- "The corpus includes seven units from a single municipality; it does not allow generalization beyond the studied context"
  limitations$tratamiento[limitations$limitacion == "Scope and selection of the qualitative corpus"] <- "Report units, roles, anonymization, specific thematic saturation, and transferability limits"
  write_table(limitations, "limitaciones_actuales")

  coherence <- read.csv(file.path(TABLE_DIR, "coherencia_metodologica.csv"),
                        check.names = FALSE, stringsAsFactors = FALSE,
                        fileEncoding = "UTF-8")
  coherence$correspondencia[coherence$componente == "OE3 y categorías de barreras"] <- "The C1-C4 categories and the emergent category are supported by seven coded interviews; the distinction between perception and causal evidence is preserved"
  coherence$estado[coherence$componente == "OE3 y categorías de barreras"] <- "Consistent and available"
  coherence$correspondencia[coherence$componente == "Método mixto"] <- "Quantitative, documentary, and qualitative evidence is organized for triangulation; the final interpretation is generated after the definitive recalculation"
  coherence$estado[coherence$componente == "Método mixto"] <- "Ready for triangulation"
  coherence$estado[coherence$componente == "Interpretación"] <- "Ready; review with definitive quantitative results"
  write_table(coherence, "coherencia_metodologica")

  writeLines(c(
    "QUALITATIVE COMPONENT QUALITY",
    "",
    "Credibility: seven interviews, open/axial coding, recurrence by interview, and anonymized verbatims; participant feedback is not yet documented.",
    "Transferability: units and roles are described, but the scope is limited to the Municipality of Tibás.",
    "Dependability: the codebook, manifest, matrix, and script allow the process to be traced; versions and decisions must be preserved.",
    "Confirmability: data, codes, verbatims, and interpretation are separated; a reflective memo and external audit are still missing.",
    "These criteria are reported with their limits and not as a guarantee of generalization."
  ), file.path(ANALYSIS_DIR, "calidad_cualitativa.txt"), useBytes = TRUE)
  if (file.exists(file.path(ANALYSIS_DIR, "calidad_cualitativa_pendiente.txt"))) unlink(file.path(ANALYSIS_DIR, "calidad_cualitativa_pendiente.txt"))
  log_message("Entregables metodológicos actualizados con la evidencia cualitativa.")
}
