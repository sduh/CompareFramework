from __future__ import annotations
from typing import Any

from .config import PUBLIC_API_MODULE, PUBLIC_API_PROCEDURES, SCHEMA_VERSION


class ArchitectureValidationError(ValueError):
    """Canonical architecture model validation failure."""


def validate_architecture_document(document: dict[str, Any]) -> None:
    required = {
        "schema_version","repository","languages","modules","statistics",
        "call_graph","dependency_analysis","privatization_analysis","entrypoint_audit",
        "public_api_contract",
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
    validate_entrypoint_audit(document)
    validate_public_api_contract(document)


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


def validate_entrypoint_audit(document: dict[str, Any]) -> None:
    audit = document["entrypoint_audit"]
    for key in ("policy", "reviews", "statistics"):
        if key not in audit:
            raise ArchitectureValidationError(f"entrypoint_audit.{key} is required")

    valid_dispositions = {
        "keep-public-api",
        "documentation-conflict-review",
        "maintenance-entrypoint-review",
        "private-after-regression-review",
        "unclassified-review",
    }
    ids = set()
    for item in audit["reviews"]:
        if item["id"] in ids:
            raise ArchitectureValidationError("duplicate entrypoint audit review")
        if item["disposition"] not in valid_dispositions:
            raise ArchitectureValidationError("unknown entrypoint audit disposition")
        ids.add(item["id"])

    if audit["statistics"]["review_count"] != len(audit["reviews"]):
        raise ArchitectureValidationError("entrypoint audit review count mismatch")


def validate_public_api_contract(document: dict[str, Any]) -> None:
    contract = document["public_api_contract"]
    expected = set(PUBLIC_API_PROCEDURES)
    status = contract.get("status")

    if status == "not-applicable":
        if contract.get("module") != PUBLIC_API_MODULE:
            raise ArchitectureValidationError("public API contract module mismatch")
        if contract.get("procedures") != [] or contract.get("procedure_count") != 0:
            raise ArchitectureValidationError("non-applicable public API contract must be empty")
        if any(module["name"] == PUBLIC_API_MODULE for module in document["modules"]):
            raise ArchitectureValidationError("public API contract cannot be non-applicable when facade exists")
        if document["statistics"].get("supported_public_api_count") != 0:
            raise ArchitectureValidationError("non-applicable supported public API count mismatch")
        return

    if status != "frozen":
        raise ArchitectureValidationError("public API contract must be frozen or not-applicable")
    if contract.get("module") != PUBLIC_API_MODULE:
        raise ArchitectureValidationError("public API contract module mismatch")
    if set(contract.get("procedures", [])) != expected:
        raise ArchitectureValidationError("public API contract procedure set mismatch")
    if contract.get("procedure_count") != len(expected):
        raise ArchitectureValidationError("public API contract procedure count mismatch")

    facade = next(
        (module for module in document["modules"] if module["name"] == PUBLIC_API_MODULE),
        None,
    )
    if facade is None:
        raise ArchitectureValidationError("public API facade module is missing")
    actual = {
        proc["name"] for proc in facade["procedures"] if proc["visibility"] == "Public"
    }
    if actual != expected:
        raise ArchitectureValidationError("public API facade differs from frozen contract")

    if document["statistics"].get("supported_public_api_count") != len(expected):
        raise ArchitectureValidationError("supported public API count mismatch")
