"""Architecture analyzer orchestration."""

from __future__ import annotations
from dataclasses import asdict
from pathlib import Path
from typing import Any

from .callgraph import build_call_graph
from .config import (
    AnalyzerConfig,
    PUBLIC_API_MODULE,
    PUBLIC_API_PROCEDURES,
    SCHEMA_VERSION,
)
from .dependencies import analyze_dependencies
from .entrypoints import build_entrypoint_audit
from .exporters import export_all
from .repository import load_repository
from .reports import write_reports
from .privatization import analyze_privatization
from .symbols import build_symbol_table
from .validation import validate_architecture_document


def _statistics(repository) -> dict[str, int]:
    symbols = build_symbol_table(repository)
    procedures = [p for m in repository.modules for p in m.procedures]
    return {
        "module_count": len(repository.modules),
        "line_count": sum(m.line_count for m in repository.modules),
        "procedure_count": len(procedures),
        "public_procedure_count": sum(p.visibility == "Public" for p in procedures),
        "private_procedure_count": sum(p.visibility == "Private" for p in procedures),
        "constant_count": sum(len(m.constants) for m in repository.modules),
        "module_variable_count": sum(len(m.variables) for m in repository.modules),
        "type_count": sum(len(m.types) for m in repository.modules),
        "enum_count": sum(len(m.enums) for m in repository.modules),
        "symbol_count": len(symbols),
        "parse_warning_count": sum(len(m.parse_warnings) for m in repository.modules),
    }


def _public_api_contract() -> dict[str, Any]:
    return {
        "status": "frozen",
        "module": PUBLIC_API_MODULE,
        "procedure_count": len(PUBLIC_API_PROCEDURES),
        "procedures": list(PUBLIC_API_PROCEDURES),
        "policy": (
            "Only these procedures form the supported user API. Other Public "
            "procedures are technical cross-module contracts and are outside the user API."
        ),
    }


def build_architecture(repository_root: Path) -> dict[str, Any]:
    config = AnalyzerConfig.from_repository_root(repository_root)
    repository = load_repository(config.repository_root)
    statistics = _statistics(repository)

    call_graph = build_call_graph(config.repository_root, repository)
    graph_data = call_graph.as_dict()

    dependency_analysis = analyze_dependencies(repository, call_graph)
    dependency_data = dependency_analysis.as_dict()

    privatization_analysis = analyze_privatization(repository, call_graph, config.repository_root)
    privatization_data = privatization_analysis.as_dict()

    entrypoint_audit = build_entrypoint_audit(config.repository_root, privatization_analysis)
    entrypoint_data = entrypoint_audit.as_dict()
    public_api_contract = _public_api_contract()

    statistics.update({
        "call_graph_edge_count": graph_data["statistics"]["edge_count"],
        "call_site_count": graph_data["statistics"]["call_site_count"],
        "cross_module_edge_count": graph_data["statistics"]["cross_module_edge_count"],
        "recursive_edge_count": graph_data["statistics"]["recursive_edge_count"],
        "module_dependency_count": dependency_data["statistics"]["module_dependency_count"],
        "dependency_cycle_count": dependency_data["statistics"]["cycle_count"],
        "cyclic_module_count": dependency_data["statistics"]["cyclic_module_count"],
        "max_dependency_cycle_size": dependency_data["statistics"]["max_cycle_size"],
        "privatization_candidate_count": privatization_data["statistics"]["candidate_count"],
        "local_only_public_count": privatization_data["statistics"]["classification_counts"].get("local-only", 0),
        "protected_public_count": privatization_data["statistics"]["protected_public_count"],
        "zero_caller_public_count": privatization_data["statistics"]["zero_caller_public_count"],
        "entrypoint_review_count": entrypoint_data["statistics"]["review_count"],
        "supported_public_api_count": public_api_contract["procedure_count"],
    })

    document = {
        "schema_version": SCHEMA_VERSION,
        "repository": {
            "name": config.repository_root.name,
            "version": repository.version,
            "root": ".",
        },
        "languages": [{
            "id": "libreoffice-basic",
            "name": "LibreOffice Basic",
            "module_count": statistics["module_count"],
        }],
        "modules": [asdict(module) for module in repository.modules],
        "call_graph": graph_data,
        "dependency_analysis": dependency_data,
        "privatization_analysis": privatization_data,
        "entrypoint_audit": entrypoint_data,
        "public_api_contract": public_api_contract,
        "statistics": statistics,
    }

    validate_architecture_document(document)
    export_all(
        config.output_dir,
        repository,
        document,
        call_graph,
        dependency_analysis,
    )
    write_reports(config.output_dir, document)

    import csv
    import json
    privatization_json = config.output_dir / "privatization_candidates.json"
    privatization_json.write_text(
        json.dumps(privatization_data, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    privatization_csv = config.output_dir / "privatization_candidates.csv"
    fields = [
        "id", "module", "module_path", "procedure", "kind", "line",
        "local_incoming_edges", "local_call_sites", "classification",
        "confidence", "reason",
    ]
    with privatization_csv.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(privatization_data["candidates"])

    entrypoint_json = config.output_dir / "entrypoint_audit.json"
    entrypoint_json.write_text(
        json.dumps(entrypoint_data, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    entrypoint_csv = config.output_dir / "entrypoint_audit.csv"
    entrypoint_fields = [
        "id", "module", "module_path", "procedure", "static_classification",
        "inventory_classification", "inventory_decision",
        "user_document_references", "disposition", "rationale",
    ]
    with entrypoint_csv.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=entrypoint_fields)
        writer.writeheader()
        for row in entrypoint_data["reviews"]:
            exported = dict(row)
            exported["user_document_references"] = ";".join(
                exported["user_document_references"]
            )
            writer.writerow(exported)

    return document
