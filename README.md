# DigitalMaturityProject

Reproducible project for cleaning, analyzing, and triangulating data from the
study **“From Paper to Digital: Perceived Digital Maturity in Municipal
Services.”**

The repository combines:

- a Python ETL pipeline that transforms Microsoft Forms exports (`.xlsx`) into
  clean CSV files;
- quantitative analysis in R covering municipal employees, citizens, and
  documentary review;
- optional qualitative analysis and mixed-methods triangulation modules for use
  when interview data is available.

## Requirements

- Python 3.10 or later, with `pandas`, `numpy`, and `openpyxl`;
- R 4.0 or later, with the `psych` and `car` packages;
- RStudio is optional.

Example dependency installation:

```bash
python -m pip install pandas numpy openpyxl
Rscript -e 'install.packages(c("psych", "car"), repos="https://cloud.r-project.org")'
```

## Usage

Run the following steps from the repository root.

### 1. Generate clean data

Place the original exports in `Proyecto_ETL/data/` using the filenames
configured in `Proyecto_ETL/clean_data.py`, then run:

```bash
python Proyecto_ETL/clean_data.py
```

The ETL identifies questions by their text, encodes Likert scales from 1 to 5,
preserves missing values, and stops if a question is missing or ambiguous.

### 2. Run the analysis

After generating the clean CSV files, run:

```bash
Rscript analisis_estadistico.R
```

You can also open `DatosExperiencia.Rproj` in RStudio and run:

```r
source("analisis_estadistico.R")
```

The analysis calculates descriptive statistics, frequencies, reliability,
assumption checks, exploratory comparisons, the main V3–V2 relationship, NPS,
documentary review results, charts, and table and figure catalogs.

## Outputs and purpose

Outputs are generated under `Proyecto_ETL/output/`:

| Directory | Contents | Purpose |
| --- | --- | --- |
| `clean/` | `funcionarios.csv`, `ciudadanos.csv`, `documental.csv` | Normalized data consumed by R |
| `reports/` | Quality reports, variable dictionary, and `ejecucion.json` | ETL auditing and traceability |
| `analysis_quantitative/tables/` | Descriptives, reliability, hypotheses, comparisons, NPS, and triangulation | Tables for interpreting and documenting results |
| `analysis_quantitative/figures/` | PNG charts for scales, hypotheses, NPS, and documentary review | Figures for the report |
| `analysis_quantitative/*.txt` | Interpretations, methodological decisions, and summaries | Support for report writing |

These results provide descriptive and exploratory evidence about perceived
digital maturity. They should be interpreted alongside sample size, statistical
assumptions, and methodological limitations; they do not, on their own,
constitute causal evidence or support generalization beyond the collected
sample.

## Project structure

```text
.
├── Proyecto_ETL/
│   ├── clean_data.py             # Excel cleaning and transformation
│   ├── data/                     # Original exports and qualitative inputs
│   └── output/                   # Clean data, tables, figures, and reports
├── R/
│   ├── analisis_cuantitativo.R   # Main quantitative workflow
│   ├── analisis_cualitativo.R   # Optional interview processing
│   ├── triangulacion_mixta.R    # Quantitative-documentary-qualitative integration
│   ├── graficos*.R              # Figure generation
│   ├── preparar_entrega.R       # Deliverable preparation
│   └── catalogos_entrega.R      # Table and figure catalogs
├── analisis_estadistico.R       # Root-level entry point
├── ciudadanos.csv               # Reference CSV files
├── funcionarios.csv
├── documental.csv
└── DatosExperiencia.Rproj       # RStudio project
```

Add interviews under `Proyecto_ETL/data/entrevistas/` following its README and
using anonymous identifiers. Until transcripts and complete coding matrices are
available, qualitative and mixed-methods outputs should be considered partial.

## Reproducibility notes

- Incomplete responses are not automatically removed.
- Composite means require at least 50% of items answered per person.
- NPS remains on a 0–10 scale and is not combined with the SAT index.
- Identifiable administrative columns are not exported to the clean CSV files.
- If a question's text changes in Microsoft Forms, review the ETL error before
  using the outputs.
