from __future__ import annotations
from typing import Any

class ArchitectureValidationError(ValueError):
    """Canonical architecture model validation failure."""

def validate_architecture_document(document: dict[str, Any]) -> None:
    required = {"schema_version", "repository", "languages", "modules", "statistics"}
    missing = sorted(required - document.keys())
    if missing:
        raise ArchitectureValidationError("Missing top-level field(s): " + ", ".join(missing))

    if document["schema_version"] != "1.0.0":
        raise ArchitectureValidationError(
            f"Unsupported schema_version: {document['schema_version']!r}"
        )

    repository = document["repository"]
    if not isinstance(repository, dict):
        raise ArchitectureValidationError("repository must be an object")
    for key in ("name", "version", "root"):
        if key not in repository:
            raise ArchitectureValidationError(f"repository.{key} is required")
    if not repository["version"]:
        raise ArchitectureValidationError("repository.version must not be empty")

    modules = document["modules"]
    if not isinstance(modules, list):
        raise ArchitectureValidationError("modules must be an array")

    paths = set()
    for index, module in enumerate(modules):
        if not isinstance(module, dict):
            raise ArchitectureValidationError(f"modules[{index}] must be an object")
        for key in ("name", "path", "line_count", "procedures"):
            if key not in module:
                raise ArchitectureValidationError(f"modules[{index}].{key} is required")
        if module["path"] in paths:
            raise ArchitectureValidationError(f"Duplicate module path: {module['path']}")
        paths.add(module["path"])
        if module["line_count"] < 0:
            raise ArchitectureValidationError(f"Negative line_count for {module['path']}")
        if not isinstance(module["procedures"], list):
            raise ArchitectureValidationError(
                f"modules[{index}].procedures must be an array"
            )

    stats = document["statistics"]
    if stats.get("module_count") != len(modules):
        raise ArchitectureValidationError(
            "statistics.module_count does not match modules length"
        )

    procedure_count = sum(len(module["procedures"]) for module in modules)
    if stats.get("procedure_count") != procedure_count:
        raise ArchitectureValidationError(
            "statistics.procedure_count does not match parsed procedures"
        )
