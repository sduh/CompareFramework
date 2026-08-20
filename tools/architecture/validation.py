from __future__ import annotations
from typing import Any

from .config import SCHEMA_VERSION


class ArchitectureValidationError(ValueError):
    """Canonical architecture model validation failure."""


def validate_architecture_document(document: dict[str, Any]) -> None:
    required = {
        "schema_version","repository","languages","modules","statistics",
        "call_graph","dependency_analysis","privatization_analysis",
    }
    missing = sorted(required - document.keys())
    if missing:
        raise ArchitectureValidationError(
            "Missing top-level field(s): " + ", ".join(missing)
        )

    if document["schema_version"] != SCHEMA_VERSION:
        raise ArchitectureValidationError(
            f"Unsupported schema_version: {document['schema_version']!r}"
        )

    repository = document["repository"]
    for key in ("name", "version", "root"):
        if key not in repository:
            raise ArchitectureValidationError(f"repository.{key} is required")
    if not repository["version"]:
        raise ArchitectureValidationError("repository.version must not be empty")

    modules = document["modules"]
    paths = set()
    module_names = set()
    procedure_ids = set()

    for index, module in enumerate(modules):
        for key in ("name", "path", "line_count", "procedures"):
            if key not in module:
                raise ArchitectureValidationError(f"modules[{index}].{key} is required")
        if module["path"] in paths:
            raise ArchitectureValidationError(f"Duplicate module path: {module['path']}")
        paths.add(module["path"])
        module_names.add(module["name"])
        for proc in module["procedures"]:
            procedure_ids.add(f"{module['name']}.{proc['name']}")

    stats = document["statistics"]
    if stats.get("module_count") != len(modules):
        raise ArchitectureValidationError(
            "statistics.module_count does not match modules length"
        )
    if stats.get("procedure_count") != sum(len(m["procedures"]) for m in modules):
        raise ArchitectureValidationError(
            "statistics.procedure_count does not match parsed procedures"
        )

    graph = document["call_graph"]
    node_ids = {node["id"] for node in graph["nodes"]}
    if node_ids != procedure_ids:
        raise ArchitectureValidationError(
            "call_graph nodes do not exactly match parsed procedures"
        )
    for edge in graph["edges"]:
        if edge["caller"] not in node_ids or edge["callee"] not in node_ids:
            raise ArchitectureValidationError("call_graph edge references unknown node")

    analysis = document["dependency_analysis"]
    for key in ("dependencies","module_metrics","cycles","statistics"):
        if key not in analysis:
            raise ArchitectureValidationError(f"dependency_analysis.{key} is required")

    metric_modules = {item["module"] for item in analysis["module_metrics"]}
    if metric_modules != module_names:
        raise ArchitectureValidationError(
            "dependency_analysis module metrics do not match parsed modules"
        )
    for dep in analysis["dependencies"]:
        if dep["caller_module"] not in module_names:
            raise ArchitectureValidationError("Unknown dependency caller module")
        if dep["callee_module"] not in module_names:
            raise ArchitectureValidationError("Unknown dependency callee module")
        if dep["caller_module"] == dep["callee_module"]:
            raise ArchitectureValidationError("module dependencies must be cross-module")
    for cycle in analysis["cycles"]:
        if cycle["size"] != len(cycle["modules"]):
            raise ArchitectureValidationError("dependency cycle size mismatch")
        if not set(cycle["modules"]).issubset(module_names):
            raise ArchitectureValidationError("dependency cycle references unknown module")

    validate_privatization_analysis(document)


def validate_privatization_analysis(document: dict[str, Any]) -> None:
    analysis = document["privatization_analysis"]
    for key in ("policy", "candidates", "protected_public", "statistics"):
        if key not in analysis:
            raise ArchitectureValidationError(
                f"privatization_analysis.{key} is required"
            )

    ids = set()
    for item in analysis["candidates"]:
        if item["id"] in ids:
            raise ArchitectureValidationError("duplicate privatization candidate")
        ids.add(item["id"])
        if item["classification"] not in {
            "local-only", "zero-caller-review", "entrypoint-review"
        }:
            raise ArchitectureValidationError("unknown privatization classification")
        if item["confidence"] not in {"high", "medium", "low"}:
            raise ArchitectureValidationError("unknown privatization confidence")

    protected_ids = set()
    for item in analysis["protected_public"]:
        if item["id"] in protected_ids:
            raise ArchitectureValidationError("duplicate protected public symbol")
        if item["id"] in ids:
            raise ArchitectureValidationError(
                "protected public symbol also appears as privatization candidate"
            )
        if "keep public" not in item["contract_decision"].casefold():
            raise ArchitectureValidationError(
                "protected public symbol lacks Keep Public contract"
            )
        protected_ids.add(item["id"])

    if analysis["statistics"]["candidate_count"] != len(analysis["candidates"]):
        raise ArchitectureValidationError("privatization candidate count mismatch")
    if analysis["statistics"]["protected_public_count"] != len(
        analysis["protected_public"]
    ):
        raise ArchitectureValidationError("protected public count mismatch")
