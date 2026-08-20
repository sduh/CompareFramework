"""Dependency, coupling and cycle analysis derived from the resolved call graph."""

from __future__ import annotations
from dataclasses import dataclass
from typing import Iterable

from .callgraph import CallGraph
from .model import Repository


@dataclass(frozen=True, slots=True)
class ModuleDependency:
    caller_module: str
    callee_module: str
    edge_count: int
    call_site_count: int


@dataclass(frozen=True, slots=True)
class ModuleMetrics:
    module: str
    outgoing_modules: int
    incoming_modules: int
    outgoing_edges: int
    incoming_edges: int
    outgoing_call_sites: int
    incoming_call_sites: int
    instability: float
    coupling_score: int


@dataclass(frozen=True, slots=True)
class DependencyCycle:
    modules: tuple[str, ...]

    @property
    def size(self) -> int:
        return len(self.modules)


@dataclass(slots=True)
class DependencyAnalysis:
    dependencies: list[ModuleDependency]
    metrics: list[ModuleMetrics]
    cycles: list[DependencyCycle]

    def as_dict(self) -> dict[str, object]:
        return {
            "dependencies": [
                {
                    "caller_module": item.caller_module,
                    "callee_module": item.callee_module,
                    "edge_count": item.edge_count,
                    "call_site_count": item.call_site_count,
                }
                for item in self.dependencies
            ],
            "module_metrics": [
                {
                    "module": item.module,
                    "outgoing_modules": item.outgoing_modules,
                    "incoming_modules": item.incoming_modules,
                    "outgoing_edges": item.outgoing_edges,
                    "incoming_edges": item.incoming_edges,
                    "outgoing_call_sites": item.outgoing_call_sites,
                    "incoming_call_sites": item.incoming_call_sites,
                    "instability": round(item.instability, 6),
                    "coupling_score": item.coupling_score,
                }
                for item in self.metrics
            ],
            "cycles": [
                {"modules": list(cycle.modules), "size": cycle.size}
                for cycle in self.cycles
            ],
            "statistics": {
                "module_dependency_count": len(self.dependencies),
                "cycle_count": len(self.cycles),
                "cyclic_module_count": len(
                    {module for cycle in self.cycles for module in cycle.modules}
                ),
                "max_cycle_size": max((cycle.size for cycle in self.cycles), default=0),
            },
        }


def build_module_dependencies(call_graph: CallGraph) -> list[ModuleDependency]:
    counts: dict[tuple[str, str], list[int]] = {}
    for edge in call_graph.edges:
        if edge.caller_module == edge.callee_module:
            continue
        key = (edge.caller_module, edge.callee_module)
        bucket = counts.setdefault(key, [0, 0])
        bucket[0] += 1
        bucket[1] += edge.call_count

    return [
        ModuleDependency(caller, callee, values[0], values[1])
        for (caller, callee), values in sorted(
            counts.items(),
            key=lambda item: (item[0][0].casefold(), item[0][1].casefold()),
        )
    ]


def _strongly_connected_components(
    modules: Iterable[str],
    dependencies: list[ModuleDependency],
) -> list[tuple[str, ...]]:
    adjacency = {module: set() for module in modules}
    for dep in dependencies:
        adjacency.setdefault(dep.caller_module, set()).add(dep.callee_module)
        adjacency.setdefault(dep.callee_module, set())

    index = 0
    stack: list[str] = []
    indices: dict[str, int] = {}
    lowlink: dict[str, int] = {}
    on_stack: set[str] = set()
    components: list[tuple[str, ...]] = []

    def visit(node: str) -> None:
        nonlocal index
        indices[node] = index
        lowlink[node] = index
        index += 1
        stack.append(node)
        on_stack.add(node)

        for target in sorted(adjacency[node], key=str.casefold):
            if target not in indices:
                visit(target)
                lowlink[node] = min(lowlink[node], lowlink[target])
            elif target in on_stack:
                lowlink[node] = min(lowlink[node], indices[target])

        if lowlink[node] == indices[node]:
            component = []
            while True:
                current = stack.pop()
                on_stack.remove(current)
                component.append(current)
                if current == node:
                    break
            components.append(tuple(sorted(component, key=str.casefold)))

    for module in sorted(adjacency, key=str.casefold):
        if module not in indices:
            visit(module)

    return [component for component in components if len(component) > 1]


def build_module_metrics(
    repository: Repository,
    dependencies: list[ModuleDependency],
) -> list[ModuleMetrics]:
    names = [module.name for module in repository.modules]
    outgoing_modules = {name: set() for name in names}
    incoming_modules = {name: set() for name in names}
    outgoing_edges = {name: 0 for name in names}
    incoming_edges = {name: 0 for name in names}
    outgoing_sites = {name: 0 for name in names}
    incoming_sites = {name: 0 for name in names}

    for dep in dependencies:
        outgoing_modules[dep.caller_module].add(dep.callee_module)
        incoming_modules[dep.callee_module].add(dep.caller_module)
        outgoing_edges[dep.caller_module] += dep.edge_count
        incoming_edges[dep.callee_module] += dep.edge_count
        outgoing_sites[dep.caller_module] += dep.call_site_count
        incoming_sites[dep.callee_module] += dep.call_site_count

    metrics = []
    for name in names:
        fan_out = len(outgoing_modules[name])
        fan_in = len(incoming_modules[name])
        denominator = fan_in + fan_out
        instability = fan_out / denominator if denominator else 0.0
        metrics.append(
            ModuleMetrics(
                module=name,
                outgoing_modules=fan_out,
                incoming_modules=fan_in,
                outgoing_edges=outgoing_edges[name],
                incoming_edges=incoming_edges[name],
                outgoing_call_sites=outgoing_sites[name],
                incoming_call_sites=incoming_sites[name],
                instability=instability,
                coupling_score=fan_in + fan_out,
            )
        )

    return sorted(metrics, key=lambda item: (-item.coupling_score, item.module.casefold()))


def analyze_dependencies(
    repository: Repository,
    call_graph: CallGraph,
) -> DependencyAnalysis:
    dependencies = build_module_dependencies(call_graph)
    metrics = build_module_metrics(repository, dependencies)
    cycles = [
        DependencyCycle(component)
        for component in _strongly_connected_components(
            (module.name for module in repository.modules),
            dependencies,
        )
    ]
    cycles.sort(key=lambda cycle: (-cycle.size, tuple(m.casefold() for m in cycle.modules)))
    return DependencyAnalysis(dependencies, metrics, cycles)
