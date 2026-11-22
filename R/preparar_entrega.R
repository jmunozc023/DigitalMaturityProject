###############################################################################
# PREPARACIÓN DE LA ENTREGA CUANTITATIVA Y METODOLÓGICA
# Se ejecuta desde analisis_cuantitativo.R cuando ya existen los resultados.
###############################################################################

###############################################################################
# Descriptivos por ítem
###############################################################################

items_funcionarios <- safe_describe(funcionarios, MD, MD)
items_funcionarios$instrumento <- "A - Funcionarios"
items_ciudadanos <- safe_describe(ciudadanos, c(EA, DGP, SAT), c(EA, DGP, SAT))
items_ciudadanos$instrumento <- "B - Ciudadanía"
item_nps <- safe_describe(data.frame(NPS1 = ciudadanos$NPS1), "NPS1", "NPS1")
item_nps$instrumento <- "B - Ciudadanía"
write_table(rbind(items_funcionarios, items_ciudadanos, item_nps),
            "descriptivos_por_item")

###############################################################################
# Validación de instrumentos y calidad metodológica
###############################################################################

validacion <- data.frame(
  componente = c(
    "Validez de contenido - Instrumento A",
    "Validez de contenido - Instrumento B",
    "Validez de contenido - Ficha documental",
    "Juicio de personas expertas",
    "Prueba piloto",
    "Confiabilidad Instrumento A",
    "Confiabilidad Instrumento B",
    "Confiabilidad ficha documental",
    "Calidad cualitativa: credibilidad",
    "Calidad cualitativa: transferibilidad",
    "Calidad cualitativa: dependencia y confirmabilidad"
  ),
  estado = c(
    "Documentada en el instrumento",
    "Documentada en el instrumento",
    "Documentada en el instrumento",
    "Pendiente de evidencia de aplicación",
    "Pendiente o no documentada en los archivos disponibles",
    "Calculada; preliminar por muestra parcial",
    "Calculada; preliminar por muestra parcial",
    "No corresponde alfa a RD1-RD8; son criterios documentales categóricos",
    "Pendiente de entrevistas y revisión por participantes o pares",
    "Pendiente de descripción contextual y selección de casos",
    "Pendiente de bitácora, trazabilidad y revisión del proceso"
  ),
  evidencia_disponible = c(
    "Matrix of MD01-MD24 and six KPAs",
    "Matrix of EA01-EA08, DGP01-DGP05, SAT01-SAT05, and NPS1",
    "Criterios RD1-RD8 y escala de clasificación 1-5",
    "No se recibió base de valoraciones de jueces",
    "No se recibió base separada de pilotaje",
    "Archivo confiabilidad.csv y gráfica 12_confiabilidad_alpha.png",
    "Archivo confiabilidad.csv y gráfica 12_confiabilidad_alpha.png",
    "Frecuencias de RD1-RD8 y clasificación global",
    "No hay transcripciones disponibles",
    "No hay corpus cualitativo disponible",
    "No hay entrevistas ni bitácora cualitativa disponible"
  ),
  accion_siguiente = c(
    "Mantener; revisar redacción si el juicio experto lo indica",
    "Mantener; revisar que NPS1 no se incluya en SAT",
    "Mantener; justificar N/A y N/V por criterio",
    "Incorporar matriz de claridad, pertinencia, coherencia y suficiencia; calcular V de Aiken",
    "Incorporar resultados del piloto, comprensión, tiempo y ajustes",
    "Recalcular con muestra definitiva y reportar por KPA y escala global",
    "Recalcular con muestra definitiva y reportar por V2, V3 y V4",
    "Reportar cumplimiento, no cumplimiento, N/A y N/V; no usar alfa",
    "Aplicar codificación, búsqueda de casos negativos y revisión de interpretaciones",
    "Describir contexto, participantes y condiciones de recolección",
    "Conservar decisiones analíticas, memos y trazabilidad de códigos"
  ),
  stringsAsFactors = FALSE
)
write_table(validacion, "validacion_metodologica")

###############################################################################
# Justificación estadística y reglas de decisión
###############################################################################

decisiones <- data.frame(
  elemento = c(
    "Nivel de significancia",
    "Puntajes compuestos",
    "Normalidad con n < 50",
    "Normalidad con n >= 50",
    "Homocedasticidad",
    "Dos grupos",
    "Tres o más grupos",
    "Hipótesis principal",
    "NPS1",
    "Criterios documentales"
  ),
  regla = c(
    "α = .05; se rechaza H0 si p < .05",
    "Media por persona con al menos 50% de ítems respondidos",
    "Shapiro-Wilk",
    "Kolmogorov-Smirnov, según el prompt del profesor",
    "Prueba de Levene",
    "t de Student si Levene no es significativo; t de Welch si lo es; d de Cohen",
    "ANOVA de un factor y Tukey si hay homocedasticidad; ANOVA de Welch y Games-Howell si no la hay",
    "Relación entre V3 digitalización percibida y V2 eficiencia administrativa percibida",
    "Indicador independiente de SAT; promotores 9-10, pasivos 7-8, detractores 0-6",
    "Descriptivos de RD1-RD8 y nivel global; no se calcula alfa"
  ),
  justificacion = c(
    "Umbral definido para las decisiones inferenciales",
    "Reduce el efecto de respuestas incompletas sin eliminar automáticamente casos",
    "Adecuada para muestras pequeñas según el prompt",
    "Regla solicitada para muestras de 50 o más casos",
    "Determina si se usa la versión clásica o robusta de las comparaciones",
    "Contrasta una diferencia de medias entre dos grupos independientes",
    "Contrasta diferencias entre tres o más grupos y controla comparaciones múltiples",
    "Es la relación definida en la operacionalización y el objetivo específico 2",
    "La recomendación no forma parte del índice compuesto de satisfacción",
    "Son evidencias observables con categorías N/A y N/V, no ítems psicométricos equivalentes"
  ),
  stringsAsFactors = FALSE
)
write_table(decisiones, "decisiones_metodologicas")

###############################################################################
# Objetivos, hallazgos disponibles y patrones
###############################################################################

objective_matrix <- data.frame(
  objetivo = c("OE1", "OE2", "OE3", "Triangulation"),
  enunciado_resumido = c(
    "Analyze institutional digital maturity through six KPAs",
    "Evaluate efficiency, digitalization, and satisfaction; analyze V3 and V2",
    "Identify budgetary, organizational, normative, and cultural barriers",
    "Contrast surveys, documentary review, and interviews"
  ),
  fuentes = c("Staff: MD01-MD24", "Citizens: EA, DGP, SAT, and NPS1",
              "Interviews with key staff", "Staff, citizens, documentary review, and interviews"),
  estado_actual = c("Available: descriptives, reliability, and V1 plots",
                    "Available: descriptives, reliability, V3-V2 correlation, and exploratory groups",
                    "Pending: no interview transcripts are available",
                    "Pending: the qualitative source is missing"),
  salida = c("descriptivos_funcionarios.csv y 01_medias_funcionarios_kpa.png",
             "descriptivos_ciudadanos.csv, hipotesis_principal_V3_V2.csv, and 04_relacion_V3_V2.png",
             "triangulacion_pendiente.txt and calidad_cualitativa_pendiente.txt",
             "No mixed conclusions are generated until interviews are received"),
  stringsAsFactors = FALSE
)
write_table(objective_matrix, "matriz_objetivos_resultados")

means_pattern <- rbind(
  data.frame(fuente = "funcionarios", indicador = names(func_scores),
             media = vapply(func_scores, mean, numeric(1), na.rm = TRUE)),
  data.frame(fuente = "ciudadanos", indicador = names(cit_scores),
             media = vapply(cit_scores, mean, numeric(1), na.rm = TRUE))
)
means_pattern <- means_pattern[is.finite(means_pattern$media), ]
means_pattern <- means_pattern[order(means_pattern$fuente, -means_pattern$media), ]
means_pattern$patron <- ifelse(means_pattern$media >= 3.5, "Nivel alto",
                               ifelse(means_pattern$media >= 2.5, "Nivel medio", "Nivel bajo"))
write_table(means_pattern, "patrones_medias_por_indicador")

###############################################################################
# Limitaciones y coherencia interna
###############################################################################

sample_limitations <- data.frame(
  limitacion = c(
    "Muestra cuantitativa parcial",
    "Casos incompletos",
    "Grupos con pocos casos",
    "Falta de entrevistas",
    "Falta de evidencia de jueces expertos",
    "Diseño transversal y datos de percepción",
    "Revisión documental acotada al portal consultado"
  ),
  impacto_potencial = c(
    "Alfas, p-valores y tamaños de efecto pueden ser inestables; no generalizar todavía",
    "Reduce n por escala y puede cambiar las medias compuestas",
    "Algunas t/ANOVA no son estimables o tienen baja potencia",
    "Does not allow barrier analysis or closure of the mixed-method triangulation",
    "No permite reportar V de Aiken ni evidencia empírica de validez de contenido",
    "Permite asociaciones, no inferencias causales ni cambios en el tiempo",
    "La evidencia depende de disponibilidad, actualización y observabilidad del portal"
  ),
  tratamiento = c(
    "Reportar n y nota preliminar; actualizar al completar la recolección",
    "Conservar NA y exigir mínimo de 50% de ítems respondidos",
    "No ejecutar automáticamente cuando no hay al menos 2 casos por grupo",
    "Dejar pendiente y no inventar patrones cualitativos",
    "Solicitar matriz de evaluación y calcular el coeficiente correspondiente",
    "Redactar la limitación en resultados y discusión",
    "Reportar fuente, fecha de revisión y campos N/A o N/V"
  ),
  stringsAsFactors = FALSE
)
write_table(sample_limitations, "limitaciones_actuales")

coherence <- data.frame(
  componente = c("Research question and hypothesis", "OE1 and V1", "OE2 and V2-V4", "OE3 and barrier categories",
                 "Documentary review", "Mixed method", "Interpretation"),
  correspondencia = c(
    "Formal H1: relationship between V3 and V2; analyzed with correlation in the same citizen sample",
    "MD01-MD24 are grouped into six KPAs and described for staff",
    "EA, DGP, and SAT are described for citizens; NPS1 remains separate",
    "The categories require interviews; they are not replaced by closed responses",
    "RD1-RD8 and the overall level provide complementary observable evidence",
    "The quantitative and documentary parts are available; the qualitative and triangulation parts remain pending",
    "Descriptive, exploratory, and inferential evidence are distinguished; causality is not claimed"
  ),
  estado = c("Coherente y disponible", "Coherente y disponible", "Coherente y disponible",
             "Pendiente por datos", "Coherente y disponible", "Parcialmente ejecutado",
             "Preparada; debe actualizarse con entrevistas"),
  stringsAsFactors = FALSE
)
write_table(coherence, "coherencia_metodologica")

###############################################################################
# Entregables narrativos actuales
###############################################################################

fmt_p <- function(p) {
  if (is.na(p)) return("p no estimable")
  p <- max(p, 0.001)
  paste0("p = ", formatC(p, format = "f", digits = 3))
}

hypothesis_line <- if (nrow(hypothesis) && !is.na(hypothesis$p_value[1])) {
  paste0("The main V3-V2 hypothesis was evaluated using ", hypothesis$metodo[1],
         ": r = ", formatC(hypothesis$estimador[1], format = "f", digits = 2),
         ", ", fmt_p(hypothesis$p_value[1]), ", n = ", hypothesis$n[1], ". ",
         hypothesis$decision[1], ".")
} else {
  "The main V3-V2 hypothesis was not estimable with the available data."
}

interpretation_text <- c(
  "PREPARING RESULTS FOR DELIVERY",
  "",
  "1. Descriptive statistics",
  "Measures of central tendency and dispersion were prepared for the composite scores and for each item. Categorical variables are presented using frequencies and valid percentages.",
  "",
  "2. Reliability",
  "Cronbach's alpha was estimated for the MD scales by KPA and overall, and for V2, V3, and V4. The current estimates should be presented as preliminary while the sample remains partial.",
  "",
  "3. Hypotheses and tests",
  "The significance level is α = .05. Test selection is based on normality and Levene, and the statistic, p-value, and effect size are reported.",
  hypothesis_line,
  "Group comparisons are considered exploratory because a specific hypothesis was not defined for each sociodemographic variable.",
  "",
  "4. Findings and patterns",
  "Mean patterns are stored in patrones_medias_por_indicador.csv. They should not be interpreted as causal evidence or generalized beyond the collected sample.",
  "",
  "5. Limitations",
  "The partial sample, small groups, absence of interviews, and lack of a judges matrix limit the strength of the current conclusions.",
  "",
  "6. Pending components",
  "The qualitative analysis, the interview-based credibility/transferability/dependability/confirmability criteria, and the final mixed-method triangulation remain pending."
)
writeLines(interpretation_text, file.path(ANALYSIS_DIR, "interpretacion_resultados_actuales.txt"), useBytes = TRUE)

quality_pending <- c(
  "QUALITATIVE COMPONENT QUALITY - PENDING",
  "",
  "Credibility: traceable coding, negative cases, review of interpretations, and, if possible, participant feedback.",
  "Transferability: thick description of the municipal context, participant profiles, and collection conditions.",
  "Dependability: decision log, code versions, and a record of category changes.",
  "Confirmability: reflective memos, separation between data and researcher opinion, and textual evidence for each theme.",
  "These criteria are not yet scored because there are no transcripts or coding matrix."
)
writeLines(quality_pending, file.path(ANALYSIS_DIR, "calidad_cualitativa_pendiente.txt"), useBytes = TRUE)

log_message("Tablas de entrega, coherencia, limitaciones y validación metodológica generadas.")
