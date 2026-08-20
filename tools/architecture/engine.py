"""Architecture analyzer orchestration."""

from __future__ import annotations

from dataclasses import asdict

from .config import BUILD_DIR
from .exporters import export_all
from .repository import load_repository
from .symbols import build_symbol_table

SCHEMA_VERSION = "1.0.0"


def _statistics(repository) -> dict[str, int]:
    procedure_count = sum(len(module.procedures) for module in repository.modules)
    public_procedure_count = sum(
        1
        for module in repository.modules
        for procedure in module.procedures
        if procedure.visibility == "Public"
    )
    symbols = build_symbol_table(repository)
    return {
        "module_count": len(repository.modules),
        "line_count": sum(module.line_count for module in repository.modules),
        "procedure_count": procedure_count,
        "public_procedure_count": public_procedure_count,
        "private_procedure_count": procedure_count - public_procedure_count,
        "constant_count": sum(len(module.constants) for module in repository.modules),
        "module_variable_count": sum(len(module.variables) for module in repository.modules),
        "type_count": sum(len(module.types) for module in repository.modules),
        "enum_count": sum(len(module.enums) for module in repository.modules),
        "symbol_count": len(symbols),
        "parse_warning_count": sum(len(module.parse_warnings) for module in repository.modules),
    }


def run() -> dict[str, object]:
    repository = load_repository()
    BUILD_DIR.mkdir(parents=True, exist_ok=True)

    data: dict[str, object] = {
        "schema_version": SCHEMA_VERSION,
        "repository": {"version": repository.version},
        "languages": [
            {
                "name": "LibreOffice Basic",
                "modules": [asdict(module) for module in repository.modules],
            }
        ],
        # Kept for schema 1.0 compatibility with A1.3 consumers.
        "modules": [asdict(module) for module in repository.modules],
        "statistics": _statistics(repository),
    }
    export_all(BUILD_DIR, repository, data)
    return data
