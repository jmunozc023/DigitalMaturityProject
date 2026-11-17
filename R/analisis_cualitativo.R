###############################################################################
# ANALISIS CUALITATIVO REPRODUCIBLE
# Corpus: entrevistas semiestructuradas anonimizadas E1-E7.
# La codificación manual documentada es la fuente principal. Las coincidencias
# de texto solo sirven como control y sugerencia para nuevas entrevistas.
###############################################################################

QUAL_DIR <- file.path(PROJECT_DIR, "Proyecto_ETL", "data", "entrevistas")
MANIFEST_FILE <- file.path(QUAL_DIR, "manifest_entrevistas.csv")
CODEBOOK_FILE <- file.path(QUAL_DIR, "codebook_cualitativo.csv")

read_utf8 <- function(path) {
  paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = " ")
}

normalize_text <- function(x) {
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")
  tolower(ifelse(is.na(x), "", x))
}

count_matches <- function(text, pattern) {
  pattern <- normalize_text(pattern)
  if (!nzchar(pattern) || !nzchar(text)) return(0L)
  hit <- tryCatch(gregexpr(pattern, text, perl = TRUE)[[1]], error = function(e) -1L)
  if (length(hit) == 1 && hit[1] == -1) 0L else length(hit)
}

write_qual_pending <- function(message) {
  writeLines(c(
    "QUALITATIVE ANALYSIS PENDING",
    "",
    message,
    "Anonymous identifiers must be preserved and the manifest and codebook updated before running again."
  ), file.path(ANALYSIS_DIR, "cualitativo_pendiente.txt"), useBytes = TRUE)
}

candidate_dirs <- c(
  Sys.getenv("QUALITATIVE_TRANSCRIPTS_DIR", unset = ""),
  file.path(PROJECT_DIR, "Proyecto_ETL", "data", "entrevistas", "raw"),
  file.path(PROJECT_DIR, "..", "Transcripciones")
)
candidate_dirs <- candidate_dirs[nzchar(candidate_dirs)]
existing_dirs <- candidate_dirs[vapply(candidate_dirs, dir.exists, logical(1))]
TRANSCRIPT_DIR <- if (length(existing_dirs)) existing_dirs[1] else NA_character_

if (!file.exists(MANIFEST_FILE) || !file.exists(CODEBOOK_FILE)) {
    write_qual_pending("manifest_entrevistas.csv or codebook_cualitativo.csv were not found.")
    log_message("Qualitative analysis pending: structure files are missing.")
} else if (is.na(TRANSCRIPT_DIR)) {
    write_qual_pending("The transcript folder was not found.")
    log_message("Qualitative analysis pending: transcript folder not found.")
} else {
  manifest <- read.csv(MANIFEST_FILE, check.names = FALSE, stringsAsFactors = FALSE,
                       fileEncoding = "UTF-8")
  codebook <- read.csv(CODEBOOK_FILE, check.names = FALSE, stringsAsFactors = FALSE,
                       fileEncoding = "UTF-8")
  manifest$participant_id <- trimws(manifest$participant_id)
  codebook$codigo <- as.integer(codebook$codigo)

  source_paths <- file.path(TRANSCRIPT_DIR, manifest$source_file)
  source_exists <- file.exists(source_paths)
  source_text <- lapply(source_paths, function(p) if (file.exists(p)) read_utf8(p) else "")
  names(source_text) <- manifest$participant_id
  source_norm <- lapply(source_text, normalize_text)
  names(source_norm) <- manifest$participant_id

  source_summary <- data.frame(
    participant_id = manifest$participant_id,
    unit_or_department = manifest$unit_or_department,
    role_or_profile = manifest$role_or_profile,
    source_file = manifest$source_file,
    source_exists = source_exists,
    caracteres = vapply(source_text, nchar, integer(1)),
    palabras_aprox = vapply(source_text, function(x) {
      if (!nzchar(trimws(x))) 0L else length(strsplit(trimws(x), "\\s+")[[1]])
    }, integer(1)),
    stringsAsFactors = FALSE
  )
  write_table(source_summary, "cualitativo_fuentes")

  manual_ids <- strsplit(gsub("\\s+", "", codebook$entrevistas_documentadas), ",")
  coding_rows <- vector("list", nrow(codebook) * nrow(manifest))
  k <- 0L
  for (i in seq_len(nrow(codebook))) {
    for (j in seq_len(nrow(manifest))) {
      k <- k + 1L
      participant <- manifest$participant_id[j]
      manual <- participant %in% manual_ids[[i]]
      keyword_count <- count_matches(source_norm[[participant]], codebook$keywords_regex[i])
      coding_rows[[k]] <- data.frame(
        participant_id = participant,
        source_file = manifest$source_file[j],
        codigo = codebook$codigo[i],
        codigo_nombre = codebook$codigo_nombre[i],
        categoria_principal = codebook$categoria_principal[i],
        subcategoria = codebook$subcategoria[i],
        presencia_manual = as.integer(manual),
        coincidencias_keyword = keyword_count,
        sugerencia_textual = as.integer(keyword_count > 0),
        estado_revision = if (manual) "Documented coding" else if (keyword_count > 0) "Review text suggestion" else "No text match",
        nota = if (manual) "Taken from the qualitative matrix in the analysis document" else "The search alone does not determine whether the code is present",
        stringsAsFactors = FALSE
      )
    }
  }
  coding_matrix <- do.call(rbind, coding_rows)
  write_table(coding_matrix, "cualitativo_matriz_codificacion")

  code_summary <- do.call(rbind, lapply(split(coding_matrix, coding_matrix$codigo), function(d) {
    data.frame(
      codigo = d$codigo[1], codigo_nombre = d$codigo_nombre[1],
      categoria_principal = d$categoria_principal[1], subcategoria = d$subcategoria[1],
      n_entrevistas = sum(d$presencia_manual),
      porcentaje_entrevistas = 100 * sum(d$presencia_manual) / nrow(manifest),
      coincidencias_textuales = sum(d$coincidencias_keyword),
      stringsAsFactors = FALSE
    )
  }))
  code_summary <- code_summary[order(code_summary$codigo), ]
  write_table(code_summary, "cualitativo_resumen_codigos")

  categories <- unique(codebook$categoria_principal)
  category_summary <- do.call(rbind, lapply(categories, function(cat) {
    d <- coding_matrix[coding_matrix$categoria_principal == cat, , drop = FALSE]
    data.frame(
      categoria_principal = cat,
      n_codigos = length(unique(d$codigo)),
      n_menciones_manual = sum(d$presencia_manual),
      n_entrevistas_con_evidencia = length(unique(d$participant_id[d$presencia_manual == 1])),
      porcentaje_entrevistas = 100 * length(unique(d$participant_id[d$presencia_manual == 1])) / nrow(manifest),
      stringsAsFactors = FALSE
    )
  }))
  write_table(category_summary, "cualitativo_resumen_categorias")

  interview_summary <- do.call(rbind, lapply(manifest$participant_id, function(pid) {
    d <- coding_matrix[coding_matrix$participant_id == pid, , drop = FALSE]
    data.frame(participant_id = pid, n_codigos_documentados = sum(d$presencia_manual),
               categorias_con_evidencia = length(unique(d$categoria_principal[d$presencia_manual == 1])),
               stringsAsFactors = FALSE)
  }))
  write_table(interview_summary, "cualitativo_resumen_entrevistas")

  verbatims <- codebook[, c("codigo", "codigo_nombre", "categoria_principal", "subcategoria",
                             "definicion_operativa", "verbatim_ilustrativo",
                             "entrevistas_documentadas", "fuente_codificacion")]
  write_table(verbatims, "cualitativo_verbatims")

  barriers_file <- file.path(QUAL_DIR, "barreras_mayor_influencia.csv")
  if (file.exists(barriers_file)) {
    barriers <- read.csv(barriers_file, check.names = FALSE, stringsAsFactors = FALSE,
                         fileEncoding = "UTF-8")
    write_table(barriers, "cualitativo_barreras_mayor_influencia")
  }

  quality <- data.frame(
    criterio = c("Credibilidad", "Transferibilidad", "Dependencia", "Confirmabilidad"),
    evidencia_actual = c(
      "Seven interviews from different units, documented open/axial coding, recurrence by interview, and anonymized verbatims.",
      "The units, roles, and context of the Municipality of Tibás are described; the scope is limited to a single municipality.",
      "A codebook, manifest, coding matrix, and document source record exist; versions and decisions must be preserved.",
      "Data, codes, verbatims, and interpretation are separated; reflective memos should be preserved and negative cases justified."
    ),
    estado = c("Documented with partial scope", "Documented with contextual limitation", "Implemented in the reproducible workflow", "Partially documented"),
    limitacion = c("Participant feedback or peer review is not documented in the available file.", "It does not allow generalization beyond the studied municipal context.", "The matrix summarizes the available analysis, but a change log must still be maintained.", "A separate reflective memo or external audit was not received."),
    siguiente_paso = c("Record participant or peer review if it is performed.", "Describe context, selection, and collection conditions precisely.", "Version the codebook, matrices, and analytical decisions.", "Add a reflective memo and preserve evidence of discrepant cases."),
    stringsAsFactors = FALSE
  )
  write_table(quality, "calidad_cualitativa")

  leader_count <- sum(codebook$codigo == 10 & codebook$entrevistas_documentadas != "")
  emergent_count <- sum(codebook$codigo == 3 & codebook$entrevistas_documentadas != "")
  conclusions <- c(
    "QUALITATIVE SYNTHESIS - CORPUS OF SEVEN INTERVIEWS",
    "",
    "The organizational category concentrates the most consistent evidence, especially the code for the absence of institutional leadership.",
    paste0("The absence of leadership is documented in ", codebook$n_entrevistas_documentado[codebook$codigo == 10][1], " of 7 interviews."),
    paste0("The open TI management vacancy appears as a cross-cutting emergent category in ", codebook$n_entrevistas_documentado[codebook$codigo == 3][1], " of 7 interviews."),
    "The budget barrier depends on the observation point: it can appear as infrastructure insufficiency or as a lack of decision-making and coordination.",
    "The normative category is less dense and more heterogeneous; it should not be presented as a single, generalized barrier.",
    "The cultural dimension shows either a favorable or demanding citizen disposition, together with internal resistance conditioned by training, fear, and organizational climate.",
    "These conclusions are interpretive and should be triangulated with V1, V2-V4, NPS, and documentary review; they do not imply causality."
  )
  writeLines(conclusions, file.path(ANALYSIS_DIR, "interpretacion_cualitativa.txt"), useBytes = TRUE)
  writeLines(c(
    "QUALITATIVE TRIANGULATION AVAILABLE",
    "",
    "The corpus, codebook, coding matrix, verbatims, and quality criteria are already available.",
    "The final quantitative integration is generated in triangulacion_mixta.R after recalculating the results with the definitive data."
  ), file.path(ANALYSIS_DIR, "triangulacion_pendiente.txt"), useBytes = TRUE)
  if (file.exists(file.path(ANALYSIS_DIR, "cualitativo_pendiente.txt"))) unlink(file.path(ANALYSIS_DIR, "cualitativo_pendiente.txt"))
  log_message("Reproducible qualitative analysis generated with ", nrow(manifest), " interviews and ", nrow(codebook), " codes.")
}
