# DigitalMaturityProject

Proyecto reproducible para limpiar, analizar y triangular la información del
estudio **“Del papel a lo digital: percepción de la madurez digital en los
servicios municipales”**.

El repositorio combina:

- un ETL en Python para transformar las exportaciones de Microsoft Forms
  (`.xlsx`) en CSV limpios;
- análisis cuantitativo en R sobre funcionarios, ciudadanía y revisión
  documental;
- módulos opcionales para análisis cualitativo y triangulación mixta cuando
  estén disponibles las entrevistas.

## Requisitos

- Python 3.10 o posterior, con `pandas`, `numpy` y `openpyxl`;
- R 4.0 o posterior, con los paquetes `psych` y `car`;
- RStudio es opcional.

Instalación de dependencias de ejemplo:

```bash
python -m pip install pandas numpy openpyxl
Rscript -e 'install.packages(c("psych", "car"), repos="https://cloud.r-project.org")'
```

## Uso

Ejecute los pasos desde la raíz del repositorio.

### 1. Generar los datos limpios

Coloque las exportaciones originales en `Proyecto_ETL/data/` usando los nombres
configurados en `Proyecto_ETL/clean_data.py` y ejecute:

```bash
python Proyecto_ETL/clean_data.py
```

El ETL identifica las preguntas por su texto, codifica las escalas Likert de
1 a 5, conserva los faltantes y detiene la ejecución si una pregunta falta o
es ambigua.

### 2. Ejecutar el análisis

Después de generar los CSV limpios, ejecute:

```bash
Rscript analisis_estadistico.R
```

También puede abrir `DatosExperiencia.Rproj` en RStudio y ejecutar:

```r
source("analisis_estadistico.R")
```

El análisis calcula descriptivos, frecuencias, confiabilidad, supuestos,
comparaciones exploratorias, la relación principal V3–V2, NPS, resultados de
revisión documental, gráficos y catálogos de tablas y figuras.

## Salidas y propósito

Las salidas se generan en `Proyecto_ETL/output/`:

| Directorio | Contenido | Propósito |
| --- | --- | --- |
| `clean/` | `funcionarios.csv`, `ciudadanos.csv`, `documental.csv` | Datos normalizados que consume R |
| `reports/` | Calidad, diccionario de variables y `ejecucion.json` | Auditoría del ETL y trazabilidad |
| `analysis_quantitative/tables/` | Descriptivos, confiabilidad, hipótesis, comparaciones, NPS y triangulación | Tablas para interpretar y documentar los resultados |
| `analysis_quantitative/figures/` | Gráficos PNG de escalas, hipótesis, NPS y revisión documental | Figuras para el informe |
| `analysis_quantitative/*.txt` | Interpretaciones, decisiones metodológicas y resúmenes | Apoyo para la redacción del informe |

Estos resultados sirven como evidencia descriptiva y exploratoria de la
madurez digital percibida. Deben interpretarse junto con el tamaño de muestra,
los supuestos estadísticos y las limitaciones metodológicas; no constituyen por
sí solos evidencia causal ni permiten generalizar más allá de la muestra
recolectada.

## Estructura del proyecto

```text
.
├── Proyecto_ETL/
│   ├── clean_data.py             # Limpieza y transformación de Excel
│   ├── data/                     # Exportaciones originales y entradas cualitativas
│   └── output/                   # Datos limpios, tablas, figuras y reportes
├── R/
│   ├── analisis_cuantitativo.R   # Flujo cuantitativo principal
│   ├── analisis_cualitativo.R   # Procesamiento opcional de entrevistas
│   ├── triangulacion_mixta.R    # Integración cuantitativa-documental-cualitativa
│   ├── graficos*.R              # Generación de figuras
│   ├── preparar_entrega.R       # Preparación de entregables
│   └── catalogos_entrega.R      # Catálogos de tablas y figuras
├── analisis_estadistico.R       # Punto de entrada desde la raíz
├── ciudadanos.csv               # Archivos CSV de referencia
├── funcionarios.csv
├── documental.csv
└── DatosExperiencia.Rproj       # Proyecto para RStudio
```

Las entrevistas se incorporan en `Proyecto_ETL/data/entrevistas/` siguiendo su
README y usando identificadores anónimos. Hasta disponer de transcripciones y
matrices completas, las salidas cualitativas y mixtas deben considerarse
parciales.

## Notas de reproducibilidad

- No se eliminan automáticamente respuestas incompletas.
- Las medias compuestas requieren al menos 50% de ítems respondidos por persona.
- NPS se mantiene en escala 0–10 y no se combina con el índice SAT.
- Las columnas administrativas identificables no se exportan a los CSV limpios.
- Si cambia el texto de una pregunta en Microsoft Forms, revise el error del
  ETL antes de usar las salidas.
