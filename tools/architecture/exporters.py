"""Deterministic architecture exports derived from the canonical model."""

from __future__ import annotations

import csv
import json
from dataclasses import asdict
from pathlib import Path
from typing import Any, Iterable

from .model import Repository
from .symbols import Symbol, build_symbol_table


def _write_csv(path: Path, fieldnames: list[str], rows: Iterable[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow({key: "" if row.get(key) is None else row.get(key) for key in fieldnames})


def export_architecture_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def export_modules_csv(path: Path, repository: Repository) -> None:
    rows = []
    for module in repository.modules:
        rows.append(
            {
                "name": module.name,
                "path": module.path,
                "line_count": module.line_count,
                "option_explicit": module.option_explicit,
                "procedure_count": len(module.procedures),
                "public_procedure_count": sum(p.visibility == "Public" for p in module.procedures),
                "private_procedure_count": sum(p.visibility == "Private" for p in module.procedures),
                "constant_count": len(module.constants),
                "variable_count": len(module.variables),
                "type_count": len(module.types),
                "enum_count": len(module.enums),
                "parse_warning_count": len(module.parse_warnings),
            }
        )
    _write_csv(
        path,
        [
            "name",
            "path",
            "line_count",
            "option_explicit",
            "procedure_count",
            "public_procedure_count",
            "private_procedure_count",
            "constant_count",
            "variable_count",
            "type_count",
            "enum_count",
            "parse_warning_count",
        ],
        rows,
    )


def export_procedures_csv(path: Path, repository: Repository) -> None:
    rows = []
    for module in repository.modules:
        for procedure in module.procedures:
            rows.append(
                {
                    "module": module.name,
                    "module_path": module.path,
                    "name": procedure.name,
                    "kind": procedure.kind,
                    "visibility": procedure.visibility,
                    "line": procedure.line,
                    "end_line": procedure.end_line,
                    "return_type": procedure.return_type,
                    "parameter_count": len(procedure.parameters),
                    "signature": procedure.signature,
                }
            )
    _write_csv(
        path,
        [
            "module",
            "module_path",
            "name",
            "kind",
            "visibility",
            "line",
            "end_line",
            "return_type",
            "parameter_count",
            "signature",
        ],
        rows,
    )


def export_symbol_index_csv(path: Path, symbols: list[Symbol]) -> None:
    rows = []
    for symbol in symbols:
        row = asdict(symbol)
        row["qualified_name"] = symbol.qualified_name
        rows.append(row)
    _write_csv(
        path,
        [
            "qualified_name",
            "module",
            "module_path",
            "name",
            "kind",
            "visibility",
            "line",
            "end_line",
            "parent",
            "type_name",
            "signature",
            "value",
        ],
        rows,
    )


def export_statistics_json(path: Path, statistics: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(statistics, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def export_all(build_dir: Path, repository: Repository, data: dict[str, Any]) -> list[Symbol]:
    """Write every A1 tabular export and return the symbol table used."""

    symbols = build_symbol_table(repository)
    export_architecture_json(build_dir / "architecture.json", data)
    export_modules_csv(build_dir / "modules.csv", repository)
    export_procedures_csv(build_dir / "procedures.csv", repository)
    export_symbol_index_csv(build_dir / "symbol_index.csv", symbols)
    export_statistics_json(build_dir / "statistics.json", data["statistics"])
    return symbols
