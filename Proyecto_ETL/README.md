# ETL reproducible para “Del papel a lo digital”

Este proyecto transforma las exportaciones de Excel de los instrumentos de funcionarios, ciudadanos y revisión documental en archivos CSV listos para R. La estructura se basa en `Instrumentos de recoleccion de datos.docx`: los ítems se identifican por su texto y se renombran con los códigos metodológicos MD, EA, DGP, SAT y RD.

## Uso

1. Coloque las nuevas exportaciones de Excel en `data/` conservando los nombres configurados en `clean_data.py`.
2. Ejecute desde esta carpeta:

```powershell
python clean_data.py
```

3. Use los archivos de `output/clean/` en R. Los reportes de `output/reports/` permiten revisar faltantes, tipos y las columnas originales detectadas.

## Salidas

- `funcionarios.csv`: datos generales, MD01–MD24, medias por KPA y cantidad respondida.
- `ciudadanos.csv`: datos generales, EA01–EA08, DGP01–DGP05, SAT01–SAT05, NPS1, medias por variable y cantidad respondida.
- `documental.csv`: identificación del trámite, RD01–RD08, clasificación global y su código 1–5.
- `calidad_*.csv`: faltantes, porcentaje de faltantes y tipo de cada variable.
- `diccionario_variables.csv`: relación entre código analítico y encabezado original.
- `ejecucion.json`: archivos, filas y columnas procesadas.

## Criterios de limpieza

- Las respuestas Likert se codifican 1–5: totalmente en desacuerdo=1, en desacuerdo=2, neutral=3, de acuerdo=4, totalmente de acuerdo=5.
- NPS1 se conserva en escala 0–10; no se mezcla con el índice SAT.
- RD se codifica como 1, 0, `NA` o `NV` según el registro documental.
- Vacíos, `None`, `NULL` y `N/A` se convierten en faltantes. No se eliminan respuestas incompletas.
- Los índices son medias por fila usando las respuestas disponibles y se acompaña `*_n_answered`; se debe definir en el análisis de R el umbral mínimo de respuestas antes de interpretar una media.
- No se exportan correo, nombre ni otras columnas administrativas identificables.

Si Microsoft Forms cambia el texto de una pregunta, el script detiene la ejecución y reporta el código faltante; esto evita producir un CSV aparentemente válido con columnas equivocadas.
