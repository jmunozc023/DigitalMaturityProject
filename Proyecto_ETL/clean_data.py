"""ETL reproducible para los instrumentos de investigación.

Uso desde la carpeta de este archivo:
    python clean_data.py

El script lee los Excel de data/, detecta las columnas por el texto de cada
ítem, conserva los faltantes como NA y genera CSV UTF-8 para R en output/clean.
También genera un libro de códigos, reportes de faltantes y un resumen de la
ejecución. Las columnas originales nunca se modifican.
"""

from __future__ import annotations

import json
import re
import unicodedata
from datetime import datetime
from pathlib import Path

import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parent
DATA = ROOT / "data"
OUT = ROOT / "output"
CLEAN = OUT / "clean"
REPORTS = OUT / "reports"

FILES = {
    "funcionarios": "Del papel a lo digital_ percepción de la madurez digital en los servicios municipales.xlsx",
    "ciudadanos": "Del papel a lo digital_ percepción de la madurez digital en los servicios municipales - C.xlsx",
    "documental": "Ficha complementaria de revisión documental para la triangulación.xlsx",
}

LIKERT = {
    "totalmente en desacuerdo": 1,
    "en desacuerdo": 2,
    "desacuerdo": 2,
    "neutral": 3,
    "ni de acuerdo ni en desacuerdo": 3,
    "de acuerdo": 4,
    "acuerdo": 4,
    "totalmente de acuerdo": 5,
}

MD = {
    "MD01": "estrategia institucional claramente definida",
    "MD02": "prioridades institucionales de digitalización",
    "MD03": "alineadas con los objetivos y prioridades institucionales",
    "MD04": "responsables claramente definidos para dirigir",
    "MD05": "consulta a la ciudadanía y otras partes interesadas",
    "MD06": "mecanismos formales para recopilar retroalimentación",
    "MD07": "oportunidades para participar en la mejora",
    "MD08": "información obtenida de las personas usuarias se utiliza",
    "MD09": "servicios digitales se diseñan considerando las necesidades",
    "MD10": "se definen claramente su alcance, requisitos y responsables",
    "MD11": "requisitos y características de los servicios digitales se documentan",
    "MD12": "facilidad de uso y accesibilidad",
    "MD13": "personal recibe capacitación",
    "MD14": "sistemas o servicios digitales son probados",
    "MD15": "cambios asociados con la implementación",
    "MD16": "condiciones técnicas y organizacionales necesarias",
    "MD17": "funcionan de manera estable",
    "MD18": "responsables claramente designados para brindar soporte",
    "MD19": "mantener o recuperar la prestación",
    "MD20": "funcionamiento de los servicios digitales es monitoreado",
    "MD21": "evalúa periódicamente el desempeño",
    "MD22": "indicadores o información sobre el desempeño",
    "MD23": "oportunidades de mejora identificadas se traducen",
    "MD24": "seguimiento a los cambios implementados",
}

EA = {
    "EA01": "tiempo de respuesta de la Municipalidad",
    "EA02": "trámites municipales que utilizo se gestionan",
    "EA03": "procedimientos para realizar trámites municipales",
    "EA04": "servicios digitales disponibles me permiten reducir",
    "EA05": "trámites municipales que realizo son resueltos",
    "EA06": "puedo acceder a los servicios municipales",
    "EA07": "proceso de atención y resolución",
    "EA08": "gestiona los trámites municipales de manera eficiente",
}

DGP = {
    "DGP01": "ofrece alternativas digitales",
    "DGP02": "cantidad suficiente de los trámites municipales",
    "DGP03": "pueden realizarse de principio a fin",
    "DGP04": "consultar en línea el estado",
    "DGP05": "comunica por medios digitales información",
}

SAT = {
    "SAT01": "fácil utilizar los servicios digitales",
    "SAT02": "servicios digitales municipales ofrecen una atención",
    "SAT03": "información proporcionada mediante los servicios digitales",
    "SAT04": "estoy satisfecho",
    "SAT05": "confío en los servicios digitales",
}

RD = {
    "RD01": "Información del trámite disponible en línea",
    "RD02": "Inicio digital del trámite",
    "RD03": "Envío digital de documentos",
    "RD04": "Autenticación o identificación digital",
    "RD05": "Pago electrónico",
    "RD06": "Completitud sin presencialidad",
    "RD07": "Seguimiento digital del trámite",
    "RD08": "Comunicación digital del resultado",
}

DIMENSIONS = {
    "MD": {"MD01": "estrategia", "MD02": "estrategia", "MD03": "estrategia", "MD04": "estrategia",
           "MD05": "participacion", "MD06": "participacion", "MD07": "participacion", "MD08": "participacion",
           "MD09": "diseno", "MD10": "diseno", "MD11": "diseno", "MD12": "diseno",
           "MD13": "transicion", "MD14": "transicion", "MD15": "transicion", "MD16": "transicion",
           "MD17": "operacion", "MD18": "operacion", "MD19": "operacion", "MD20": "operacion",
           "MD21": "mejora_continua", "MD22": "mejora_continua", "MD23": "mejora_continua", "MD24": "mejora_continua"},
    "EA": {f"EA{i:02d}": "eficiencia" for i in range(1, 9)},
    "DGP": {f"DGP{i:02d}": "digitalizacion" for i in range(1, 6)},
    "SAT": {f"SAT{i:02d}": "satisfaccion" for i in range(1, 6)},
}


def norm(value: object) -> str:
    text = "" if value is None else str(value)
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii")
    return re.sub(r"\s+", " ", text.lower().strip())


def clean_text(value: object):
    if pd.isna(value):
        return pd.NA
    text = str(value).strip()
    return pd.NA if norm(text) in {"", "none", "null", "na", "n/a"} else text


def locate_columns(columns, definitions):
    normalized = {col: norm(col) for col in columns}
    found, missing = {}, []
    for code, phrase in definitions.items():
        key = norm(phrase)
        candidates = [col for col, value in normalized.items() if key in value]
        if len(candidates) == 1:
            found[code] = candidates[0]
        elif not candidates:
            missing.append(code)
        else:
            raise ValueError(f"{code}: coincidencia ambigua en {candidates}")
    if missing:
        raise ValueError(f"No se encontraron columnas para: {', '.join(missing)}")
    return found


def likert(value):
    if pd.isna(value):
        return pd.NA
    key = norm(value)
    if key in LIKERT:
        return LIKERT[key]
    try:
        number = int(float(str(value).replace(",", ".")))
        return number if 1 <= number <= 5 else pd.NA
    except (ValueError, TypeError):
        return pd.NA


def nps(value):
    if pd.isna(value):
        return pd.NA
    try:
        number = int(float(str(value).replace(",", ".")))
        return number if 0 <= number <= 10 else pd.NA
    except (ValueError, TypeError):
        return pd.NA


def binary_or_na(value):
    key = norm(value)
    if key in {"1", "cumple", "si", "s", "true"}: return 1
    if key in {"0", "no cumple", "no", "n", "false"}: return 0
    if key in {"na", "n/a", "nv", "n/v", "no aplica", "no verificable"}: return key.upper().replace("/", "_")
    return pd.NA


def basic_columns(df):
    result = pd.DataFrame(index=df.index)
    result["response_id"] = df["Id"].astype("string") if "Id" in df else pd.Series(range(1, len(df) + 1), index=df.index, dtype="string")
    if "Start time" in df: result["start_time"] = pd.to_datetime(df["Start time"], errors="coerce")
    if "Completion time" in df: result["completion_time"] = pd.to_datetime(df["Completion time"], errors="coerce")
    return result


def add_dimension_scores(result, groups):
    for name, codes in groups.items():
        result[f"{name}_mean"] = result[codes].apply(pd.to_numeric, errors="coerce").mean(axis=1, skipna=True).where(result[codes].notna().any(axis=1))
        result[f"{name}_n_answered"] = result[codes].notna().sum(axis=1)


def process_survey(path, kind, definitions, prefix_groups, metadata):
    source = pd.read_excel(path)
    result = basic_columns(source)
    # Variables generales: se conservan con nombres estables y valores de texto.
    general = {
        "funcionarios": {"Dependencia o área en la que labora": "area", "Años de laborar": "antiguedad", "Nivel de relación": "relacion_tecnologia"},
        "ciudadanos": {"Tipo de trámite": "tipo_tramite", "Canal habitualmente": "canal", "Frecuencia de uso": "frecuencia_uso", "Rango de edad": "rango_edad"},
    }[kind]
    for start, target in general.items():
        matches = [c for c in source.columns if norm(start) in norm(c)]
        if matches: result[target] = source[matches[0]].map(clean_text).astype("string")
    located = locate_columns(source.columns, definitions)
    for code, column in located.items():
        result[code] = source[column].map(likert).astype("Int64")
        metadata.append({"dataset": kind, "variable": code, "source_column": column, "type": "likert_1_5", "missing": int(result[code].isna().sum())})
    if kind == "ciudadanos":
        nps_cols = [c for c in source.columns if "recomiende los servicios digitales" in norm(c)]
        if len(nps_cols) != 1: raise ValueError("No se encontró de forma única la columna NPS1")
        result["NPS1"] = source[nps_cols[0]].map(nps).astype("Int64")
        metadata.append({"dataset": kind, "variable": "NPS1", "source_column": nps_cols[0], "type": "nps_0_10", "missing": int(result["NPS1"].isna().sum())})
    add_dimension_scores(result, prefix_groups)
    return result, source


def process_documentary(path, metadata):
    source = pd.read_excel(path)
    result = basic_columns(source)
    general = {"Código de la unidad": "document_id", "Nombre del trámite": "service_name", "Dependencia municipal": "responsible_unit", "Fuente o sección": "source_url", "Fecha de revisión": "review_date", "Clasificación global": "digital_level", "Justificación": "classification_justification", "Limitaciones": "review_limitations", "Observaciones adicionales": "observations"}
    for start, target in general.items():
        matches = [c for c in source.columns if norm(start) in norm(c)]
        if matches: result[target] = source[matches[0]].map(clean_text).astype("string")
    located = locate_columns(source.columns, RD)
    for code, column in located.items():
        result[code] = source[column].map(binary_or_na)
        metadata.append({"dataset": "documental", "variable": code, "source_column": column, "type": "binary_or_NA_NV", "missing": int(result[code].isna().sum())})
    level = result.get("digital_level", pd.Series(pd.NA, index=result.index)).map(norm)
    level_map = {"presencial": 1, "informativo": 2, "parcialmente digital": 3, "digital transaccional": 4, "digital completo": 5}
    result["digital_level_code"] = level.map(level_map).astype("Int64")
    return result, source


def export_dataset(df, name):
    path = CLEAN / f"{name}.csv"
    df.to_csv(path, index=False, encoding="utf-8-sig", date_format="%Y-%m-%dT%H:%M:%S")
    return path


def main():
    CLEAN.mkdir(parents=True, exist_ok=True); REPORTS.mkdir(parents=True, exist_ok=True)
    metadata, run = [], {"started_at": datetime.now().isoformat(timespec="seconds"), "files": {}, "warnings": []}
    for kind, filename in FILES.items():
        path = DATA / filename
        if not path.exists(): raise FileNotFoundError(path)
        if kind == "funcionarios":
            df, source = process_survey(path, kind, MD, {name: [code for code, dim in DIMENSIONS["MD"].items() if dim == name] for name in set(DIMENSIONS["MD"].values())}, metadata)
        elif kind == "ciudadanos":
            defs = {**EA, **DGP, **SAT}
            groups = {name: [code for code, dim in {**DIMENSIONS["EA"], **DIMENSIONS["DGP"], **DIMENSIONS["SAT"]}.items() if dim == name] for name in {"eficiencia", "digitalizacion", "satisfaccion"}}
            df, source = process_survey(path, kind, defs, groups, metadata)
        else:
            df, source = process_documentary(path, metadata)
        out = export_dataset(df, kind)
        report = pd.DataFrame({"variable": df.columns, "n": len(df), "missing": df.isna().sum().values, "missing_pct": (df.isna().mean().values * 100).round(2), "class": [str(df[c].dtype) for c in df.columns]})
        report.to_csv(REPORTS / f"calidad_{kind}.csv", index=False, encoding="utf-8-sig")
        run["files"][kind] = {"input": str(path), "output": str(out), "rows": len(source), "output_columns": len(df.columns)}
    pd.DataFrame(metadata).to_csv(REPORTS / "diccionario_variables.csv", index=False, encoding="utf-8-sig")
    (REPORTS / "ejecucion.json").write_text(json.dumps(run, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(run, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
