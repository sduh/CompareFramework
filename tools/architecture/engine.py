"""Architecture analyzer orchestration."""

from __future__ import annotations

import json
from dataclasses import asdict

from .config import BUILD_DIR
from .repository import load_repository

SCHEMA_VERSION = "1.0.0"


def run() -> dict[str, object]:
    repository = load_repository()
    BUILD_DIR.mkdir(parents=True, exist_ok=True)

    procedure_count = sum(len(module.procedures) for module in repository.modules)
    public_procedure_count = sum(
        1
        for module in repository.modules
        for procedure in module.procedures
        if procedure.visibility == "Public"
    )
    private_procedure_count = procedure_count - public_procedure_count
    data: dict[str, object] = {
        "schema_version": SCHEMA_VERSION,
        "repository": {"version": repository.version},
        "modules": [asdict(module) for module in repository.modules],
        "statistics": {
            "module_count": len(repository.modules),
            "procedure_count": procedure_count,
            "public_procedure_count": public_procedure_count,
            "private_procedure_count": private_procedure_count,
            "constant_count": sum(len(module.constants) for module in repository.modules),
            "module_variable_count": sum(len(module.variables) for module in repository.modules),
            "type_count": sum(len(module.types) for module in repository.modules),
            "enum_count": sum(len(module.enums) for module in repository.modules),
            "parse_warning_count": sum(len(module.parse_warnings) for module in repository.modules),
        },
    }
    output = BUILD_DIR / "architecture.json"
    output.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return data
