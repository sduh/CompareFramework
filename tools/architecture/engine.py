"""Architecture analyzer orchestration."""

from __future__ import annotations
from dataclasses import asdict
from pathlib import Path
from typing import Any

from .config import AnalyzerConfig, SCHEMA_VERSION
from .exporters import export_all
from .repository import load_repository
from .symbols import build_symbol_table
from .validation import validate_architecture_document

def _statistics(repository) -> dict[str, int]:
    symbols = build_symbol_table(repository)
    modules = repository.modules
    procedures = [p for m in modules for p in m.procedures]
    return {
        "module_count": len(modules),
        "line_count": sum(m.line_count for m in modules),
        "procedure_count": len(procedures),
        "public_procedure_count": sum(p.visibility == "Public" for p in procedures),
        "private_procedure_count": sum(p.visibility == "Private" for p in procedures),
        "constant_count": sum(len(m.constants) for m in modules),
        "module_variable_count": sum(len(m.variables) for m in modules),
        "type_count": sum(len(m.types) for m in modules),
        "enum_count": sum(len(m.enums) for m in modules),
        "symbol_count": len(symbols),
        "parse_warning_count": sum(len(m.parse_warnings) for m in modules),
    }

def build_architecture(repository_root: Path) -> dict[str, Any]:
    config = AnalyzerConfig.from_repository_root(repository_root)
    repository = load_repository(config.repository_root)
    statistics = _statistics(repository)

    document = {
        "schema_version": SCHEMA_VERSION,
        "repository": {
            "name": config.repository_root.name,
            "version": repository.version,
            "root": ".",
        },
        "languages": [
            {
                "id": "libreoffice-basic",
                "name": "LibreOffice Basic",
                "module_count": statistics["module_count"],
            }
        ],
        "modules": [asdict(module) for module in repository.modules],
        "statistics": statistics,
    }

    validate_architecture_document(document)
    export_all(config.output_dir, repository, document)
    return document
