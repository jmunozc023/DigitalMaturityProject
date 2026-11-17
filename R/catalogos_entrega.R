###############################################################################
# CATALOGOS PARA LA ENTREGA
# Numeracion sugerida de tablas y figuras para el informe escrito.
###############################################################################

figure_files <- list.files(FIGURE_DIR, pattern = "\\.png$", full.names = FALSE)
figure_files <- sort(figure_files)

figure_titles <- c(
  `01_medias_funcionarios_kpa.png` = "Mean digital maturity by KPA",
  `02_medias_ciudadania.png` = "Mean of citizen experience indicators",
  `03_distribucion_ciudadania.png` = "Distribution of citizen scores",
  `04_relacion_V3_V2.png` = "Relationship between digitalization and perceived efficiency",
  `05_canal_ciudadania.png` = "Channel used to complete the service request",
  `06_frecuencia_ciudadania.png` = "Usage frequency of municipal services",
  `07_edad_ciudadania.png` = "Age range distribution",
  `08_tipo_tramite_ciudadania.png` = "Most frequently completed service type",
  `09_NPS.png` = "Net Promoter Score distribution",
  `10_niveles_documental.png` = "Overall documentary maturity classification",
  `11_criterios_documental.png` = "Documentary review criteria compliance",
  `12_confiabilidad_alpha.png` = "Cronbach's alpha by scale",
  `13_medias_items_MD.png` = "Item-level means for institutional digital maturity",
  `14_medias_items_ciudadania.png` = "Item-level means for citizen experience",
  `15_histogramas_variables_principales.png` = "Histograms of main variables"
)

default_title <- function(file) {
  tools::file_path_sans_ext(file)
}

figure_catalog <- data.frame(
  figura = seq_along(figure_files),
  archivo = figure_files,
  titulo = vapply(figure_files, function(x) {
    if (x %in% names(figure_titles)) figure_titles[[x]] else default_title(x)
  }, character(1)),
  stringsAsFactors = FALSE
)
write_table(figure_catalog, "catalogo_figuras")

table_rows <- data.frame(
  tabla = seq_len(31),
  archivo = c(
    "descriptivos_funcionarios.csv", "descriptivos_ciudadanos.csv",
    "descriptivos_por_item.csv", "frecuencias_funcionarios.csv",
    "frecuencias_ciudadanos.csv", "confiabilidad.csv",
    "normalidad.csv", "levene.csv", "hipotesis.csv",
    "comparaciones.csv", "posthoc.csv", "nps.csv",
    "documental_criterios.csv", "documental_niveles.csv",
    "chi_cuadrado_exploratorio.csv", "regresion_exploratoria_V2_V3.csv",
    "validacion_metodologica.csv", "decisiones_metodologicas.csv",
    "matriz_objetivos_resultados.csv", "patrones_medias_por_indicador.csv",
    "limitaciones_actuales.csv", "coherencia_metodologica.csv",
    "cualitativo_fuentes.csv", "cualitativo_matriz_codificacion.csv",
    "cualitativo_resumen_codigos.csv", "cualitativo_resumen_categorias.csv",
    "cualitativo_resumen_entrevistas.csv", "cualitativo_verbatims.csv",
    "cualitativo_barreras_mayor_influencia.csv", "calidad_cualitativa.csv",
    "triangulacion_mixta.csv"
  ),
  titulo = c(
    "Descriptive statistics for staff",
    "Descriptive statistics for citizens",
    "Descriptive statistics by item",
    "Staff frequencies",
    "Citizen frequencies",
    "Scale reliability",
    "Normality tests",
    "Variance homogeneity tests",
    "Main hypothesis test",
    "Group comparisons",
    "Post hoc tests",
    "Net Promoter Score results",
    "Documentary review criteria",
    "Documentary maturity levels",
    "Exploratory categorical associations",
    "Exploratory regression between V3 and V2",
    "Available methodological validation",
    "Methodological and statistical decisions",
    "Alignment between objectives and results",
    "Mean patterns by indicator",
    "Current limitations",
    "Methodological coherence",
    "Qualitative sources and corpus coverage",
    "Qualitative coding matrix",
    "Qualitative code summary",
    "Qualitative category summary",
    "Summary by interview",
    "Illustrative verbatims and traceability",
    "Most influential barrier by interview",
    "Qualitative quality criteria",
    "Mixed-method triangulation"
  ),
  stringsAsFactors = FALSE
)
write_table(table_rows, "catalogo_tablas")

log_message("Catálogos de tablas y figuras para la entrega generados.")


