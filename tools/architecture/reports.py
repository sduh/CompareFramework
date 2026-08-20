"""Human-readable architecture reports derived from the canonical analysis."""

from __future__ import annotations
from pathlib import Path
from typing import Any


def _md_table(headers: list[str], rows: list[list[object]]) -> str:
    def cell(value: object) -> str:
        return str(value).replace("|", r"\|").replace("\n", " ")
    lines = [
        "| " + " | ".join(headers) + " |",
        "| " + " | ".join("---" for _ in headers) + " |",
    ]
    lines.extend("| " + " | ".join(cell(v) for v in row) + " |" for row in rows)
    return "\n".join(lines)


def render_architecture_report(document: dict[str, Any]) -> str:
    stats = document["statistics"]
    analysis = document["dependency_analysis"]
    metrics = analysis["module_metrics"]
    cycles = analysis["cycles"]

    top = metrics[:10]
    coupling_table = _md_table(
        ["Module", "Fan-in", "Fan-out", "Coupling", "Instability"],
        [
            [
                item["module"],
                item["incoming_modules"],
                item["outgoing_modules"],
                item["coupling_score"],
                f'{item["instability"]:.3f}',
            ]
            for item in top
        ],
    )

    if cycles:
        cycle_text = "\n".join(
            f'{index}. **{cycle["size"]} modules** — ' +
            " → ".join(f'`{module}`' for module in cycle["modules"])
            for index, cycle in enumerate(cycles, start=1)
        )
    else:
        cycle_text = "Aucun cycle inter-module détecté."

    return f"""# CompareFramework — Architecture Report

Generated automatically from `build/architecture/architecture.json`.

## Repository

- Version: **{document["repository"]["version"]}**
- Canonical schema: **{document["schema_version"]}**
- LibreOffice Basic modules: **{stats["module_count"]}**
- Lines: **{stats["line_count"]}**
- Procedures: **{stats["procedure_count"]}**
- Public procedures: **{stats["public_procedure_count"]}**
- Private procedures: **{stats["private_procedure_count"]}**
- Parse warnings: **{stats["parse_warning_count"]}**

## Call graph

- Resolved procedure edges: **{stats["call_graph_edge_count"]}**
- Resolved call sites: **{stats["call_site_count"]}**
- Cross-module procedure edges: **{stats["cross_module_edge_count"]}**
- Recursive edges: **{stats["recursive_edge_count"]}**

## Module dependencies

- Directed module dependencies: **{stats["module_dependency_count"]}**
- Strongly connected cyclic components: **{stats["dependency_cycle_count"]}**
- Modules participating in cycles: **{stats["cyclic_module_count"]}**
- Largest cyclic component: **{stats["max_dependency_cycle_size"]}**

## Highest coupling

{coupling_table}

## Cyclic components

{cycle_text}

## Interpretation

`fan-in` is the number of modules depending on a module. `fan-out` is the
number of modules on which it depends. `coupling` is `fan-in + fan-out`.
`instability` is `fan-out / (fan-in + fan-out)`.

Cycles are strongly connected components of the directed module dependency
graph. They identify groups for which dependencies cannot be ordered
acyclically without refactoring.

## Machine-readable sources

- `architecture.json`
- `call_graph.json`
- `dependency_analysis.json`
- `module_dependencies.csv`
- `module_metrics.csv`
- `dependency_cycles.csv`
"""


def render_dependency_report(document: dict[str, Any]) -> str:
    analysis = document["dependency_analysis"]
    metrics = analysis["module_metrics"]
    dependencies = analysis["dependencies"]
    cycles = analysis["cycles"]

    metric_table = _md_table(
        [
            "Module", "Fan-in", "Fan-out", "Incoming edges", "Outgoing edges",
            "Incoming sites", "Outgoing sites", "Instability", "Coupling",
        ],
        [
            [
                item["module"],
                item["incoming_modules"],
                item["outgoing_modules"],
                item["incoming_edges"],
                item["outgoing_edges"],
                item["incoming_call_sites"],
                item["outgoing_call_sites"],
                f'{item["instability"]:.3f}',
                item["coupling_score"],
            ]
            for item in metrics
        ],
    )

    dependency_table = _md_table(
        ["Caller module", "Callee module", "Edges", "Call sites"],
        [
            [
                item["caller_module"],
                item["callee_module"],
                item["edge_count"],
                item["call_site_count"],
            ]
            for item in dependencies
        ],
    )

    if cycles:
        cycle_sections = []
        for index, cycle in enumerate(cycles, start=1):
            members = "\n".join(f'- `{module}`' for module in cycle["modules"])
            cycle_sections.append(
                f'### Cycle {index} — {cycle["size"]} modules\n\n{members}'
            )
        cycle_text = "\n\n".join(cycle_sections)
    else:
        cycle_text = "Aucun cycle inter-module détecté."

    return f"""# CompareFramework — Dependency Report

Generated automatically from the resolved LibreOffice Basic call graph.

## Module coupling metrics

{metric_table}

## Directed dependencies

{dependency_table}

## Cyclic components

{cycle_text}

## Reading the report

High fan-in indicates a shared dependency or architectural service. High
fan-out indicates orchestration or broad dependency usage. High coupling alone
is not a defect: it is a prioritization signal for architectural review.

A cyclic component is reported only when at least two modules are mutually
reachable through resolved calls.
"""


def write_reports(output_dir: Path, document: dict[str, Any]) -> list[Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    paths = [
        output_dir / "ARCHITECTURE_REPORT.md",
        output_dir / "DEPENDENCY_REPORT.md",
    ]
    contents = [
        render_architecture_report(document),
        render_dependency_report(document),
    ]
    for path, content in zip(paths, contents):
        path.write_text(content.rstrip() + "\n", encoding="utf-8")
    return paths
