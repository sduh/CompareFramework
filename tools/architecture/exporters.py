"""Deterministic architecture exports derived from the canonical model."""

from __future__ import annotations

import csv
import json
from dataclasses import asdict
from pathlib import Path
from typing import Any, Iterable

from .callgraph import CallGraph
from .dependencies import DependencyAnalysis
from .model import Repository
from .symbols import Symbol, build_symbol_table


def _write_csv(path: Path, fieldnames: list[str], rows: Iterable[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {key: "" if row.get(key) is None else row.get(key) for key in fieldnames}
            )


def _write_json(path: Path, data: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def export_modules_csv(path: Path, repository: Repository) -> None:
    rows = []
    for module in repository.modules:
        rows.append({
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
        })
    _write_csv(path, [
        "name","path","line_count","option_explicit","procedure_count",
        "public_procedure_count","private_procedure_count","constant_count",
        "variable_count","type_count","enum_count","parse_warning_count"
    ], rows)


def export_procedures_csv(path: Path, repository: Repository) -> None:
    rows = []
    for module in repository.modules:
        for procedure in module.procedures:
            rows.append({
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
            })
    _write_csv(path, [
        "module","module_path","name","kind","visibility","line","end_line",
        "return_type","parameter_count","signature"
    ], rows)


def export_symbol_index_csv(path: Path, symbols: list[Symbol]) -> None:
    rows = []
    for symbol in symbols:
        row = asdict(symbol)
        row["qualified_name"] = symbol.qualified_name
        rows.append(row)
    _write_csv(path, [
        "qualified_name","module","module_path","name","kind","visibility",
        "line","end_line","parent","type_name","signature","value"
    ], rows)


def export_cross_module_calls_csv(path: Path, call_graph: CallGraph) -> None:
    rows = []
    for edge in call_graph.edges:
        if edge.caller_module != edge.callee_module:
            rows.append({
                "caller": edge.caller,
                "caller_module": edge.caller_module,
                "callee": edge.callee,
                "callee_module": edge.callee_module,
                "call_count": edge.call_count,
                "lines": ";".join(str(line) for line in edge.lines),
            })
    _write_csv(path, [
        "caller","caller_module","callee","callee_module","call_count","lines"
    ], rows)


def export_dependency_matrix_csv(path: Path, repository: Repository, call_graph: CallGraph) -> None:
    modules = [module.name for module in repository.modules]
    counts = {(caller, callee): 0 for caller in modules for callee in modules}
    for edge in call_graph.edges:
        if edge.caller_module != edge.callee_module:
            counts[(edge.caller_module, edge.callee_module)] += edge.call_count
    rows = []
    for caller in modules:
        row = {"module": caller}
        for callee in modules:
            row[callee] = counts[(caller, callee)]
        rows.append(row)
    _write_csv(path, ["module", *modules], rows)


def export_module_dependencies_csv(path: Path, analysis: DependencyAnalysis) -> None:
    _write_csv(path, [
        "caller_module","callee_module","edge_count","call_site_count"
    ], [
        {
            "caller_module": dep.caller_module,
            "callee_module": dep.callee_module,
            "edge_count": dep.edge_count,
            "call_site_count": dep.call_site_count,
        }
        for dep in analysis.dependencies
    ])


def export_module_metrics_csv(path: Path, analysis: DependencyAnalysis) -> None:
    _write_csv(path, [
        "module","outgoing_modules","incoming_modules","outgoing_edges",
        "incoming_edges","outgoing_call_sites","incoming_call_sites",
        "instability","coupling_score"
    ], [
        {
            "module": item.module,
            "outgoing_modules": item.outgoing_modules,
            "incoming_modules": item.incoming_modules,
            "outgoing_edges": item.outgoing_edges,
            "incoming_edges": item.incoming_edges,
            "outgoing_call_sites": item.outgoing_call_sites,
            "incoming_call_sites": item.incoming_call_sites,
            "instability": f"{item.instability:.6f}",
            "coupling_score": item.coupling_score,
        }
        for item in analysis.metrics
    ])


def export_cycles_csv(path: Path, analysis: DependencyAnalysis) -> None:
    _write_csv(path, ["cycle_id","size","modules"], [
        {
            "cycle_id": index,
            "size": cycle.size,
            "modules": ";".join(cycle.modules),
        }
        for index, cycle in enumerate(analysis.cycles, start=1)
    ])


def export_all(
    build_dir: Path,
    repository: Repository,
    data: dict[str, Any],
    call_graph: CallGraph,
    dependency_analysis: DependencyAnalysis,
) -> list[Symbol]:
    symbols = build_symbol_table(repository)
    _write_json(build_dir / "architecture.json", data)
    export_modules_csv(build_dir / "modules.csv", repository)
    export_procedures_csv(build_dir / "procedures.csv", repository)
    export_symbol_index_csv(build_dir / "symbol_index.csv", symbols)
    _write_json(build_dir / "statistics.json", data["statistics"])
    _write_json(build_dir / "call_graph.json", call_graph.as_dict())
    export_cross_module_calls_csv(build_dir / "cross_module_calls.csv", call_graph)
    export_dependency_matrix_csv(build_dir / "dependency_matrix.csv", repository, call_graph)
    _write_json(build_dir / "dependency_analysis.json", dependency_analysis.as_dict())
    export_module_dependencies_csv(build_dir / "module_dependencies.csv", dependency_analysis)
    export_module_metrics_csv(build_dir / "module_metrics.csv", dependency_analysis)
    export_cycles_csv(build_dir / "dependency_cycles.csv", dependency_analysis)
    return symbols
