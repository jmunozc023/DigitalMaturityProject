# Análisis cuantitativo en R

El punto de entrada recomendado es `analisis_estadistico.R`, que llama a `R/analisis_cuantitativo.R`. Debe ejecutarse desde RStudio
o desde la carpeta `DatosExperiencia` después de generar los CSV con
`Proyecto_ETL/clean_data.py`.

```r
source("analisis_estadistico.R")
```

El análisis sigue el prompt del profesor y el documento de instrumentos:

- descriptivos de escalas y frecuencias de variables categóricas;
- consistencia interna de las escalas MD, EA, DGP y SAT;
- normalidad y homocedasticidad para los resultados que se comparen por grupos;
- hipótesis principal: relación entre V3 (digitalización percibida) y V2
  (eficiencia administrativa percibida), con correlación de Pearson o Spearman;
- pruebas t/ANOVA únicamente cuando una variable de agrupación tenga suficientes
  grupos observables; no se convierten en hipótesis confirmatorias de forma
  automática;
- NPS independiente del índice SAT;
- revisión documental como evidencia descriptiva complementaria.

El módulo `analisis_cualitativo.R` lee el manifiesto, el codebook y las transcripciones anonimizadas. La matriz manual documentada es la fuente principal; las coincidencias de texto solo son sugerencias de revisión. `triangulacion_mixta.R` integra cuantitativo, revisión documental y cualitativo después del recálculo definitivo.

Las medias compuestas se calculan con al menos 50% de ítems respondidos por
persona. Con los datos parciales actuales, confiabilidad y pruebas inferenciales
son preliminares y deben recalcularse cuando aumente la muestra.


`output/analysis_quantitative/figures/` contiene gráficos PNG para resultados principales, distribuciones, hipótesis V3–V2, NPS y revisión documental.


La guía cuantitativa también se aplica mediante `analisis_complementarios_guia.R` y `graficos_guia.R`: descriptivos ampliados (moda, varianza, CV, cuartiles e IQR), histogramas, boxplots, medias con IC95%, chi-cuadrado y regresión exploratorios. `catalogos_entrega.R` genera `catalogo_tablas.csv` y `catalogo_figuras.csv` para numerar los resultados en el informe.



El módulo `analisis_cualitativo.R` lee el manifiesto, el codebook y las transcripciones anonimizadas. `actualizar_entrega_cualitativa.R` cierra los estados metodológicos y `triangulacion_mixta.R` genera la matriz de integración final.



