"""Architecture analyzer orchestration."""

from __future__ import annotations
from dataclasses import asdict
from pathlib import Path
from typing import Any

from .callgraph import build_call_graph
from .config import AnalyzerConfig, SCHEMA_VERSION
from .dependencies import analyze_dependencies
from .exporters import export_all
from .repository import load_repository
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


def build_architecture(repository_root: Path) -> dict[str, Any]:
    config = AnalyzerConfig.from_repository_root(repository_root)
    repository = load_repository(config.repository_root)
    statistics = _statistics(repository)

    call_graph = build_call_graph(config.repository_root, repository)
    graph_data = call_graph.as_dict()

    dependency_analysis = analyze_dependencies(repository, call_graph)
    dependency_data = dependency_analysis.as_dict()

    statistics.update({
        "call_graph_edge_count": graph_data["statistics"]["edge_count"],
        "call_site_count": graph_data["statistics"]["call_site_count"],
        "cross_module_edge_count": graph_data["statistics"]["cross_module_edge_count"],
        "recursive_edge_count": graph_data["statistics"]["recursive_edge_count"],
        "module_dependency_count": dependency_data["statistics"]["module_dependency_count"],
        "dependency_cycle_count": dependency_data["statistics"]["cycle_count"],
        "cyclic_module_count": dependency_data["statistics"]["cyclic_module_count"],
        "max_dependency_cycle_size": dependency_data["statistics"]["max_cycle_size"],
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
    return document
