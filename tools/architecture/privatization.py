"""Qualification of Public LibreOffice Basic procedures for possible privatization.

This analysis is conservative: it identifies evidence-based candidates, not
automatic source transformations. A Public procedure is a candidate only when
the resolved repository call graph contains no cross-module incoming edge.

Entry-point-like procedures and procedures with no resolved callers are kept
separate because static repository analysis cannot prove that LibreOffice,
dialogs, macros, external documents or user actions do not invoke them.
"""

from __future__ import annotations
from dataclasses import dataclass

from .callgraph import CallGraph
from .model import Repository


ENTRYPOINT_PREFIXES = (
    "main", "test", "run", "execute", "initialize", "init",
    "on", "handle", "open", "close",
)


@dataclass(frozen=True, slots=True)
class PrivatizationCandidate:
    module: str
    module_path: str
    procedure: str
    kind: str
    line: int
    local_incoming_edges: int
    local_call_sites: int
    classification: str
    confidence: str
    reason: str

    @property
    def qualified_name(self) -> str:
        return f"{self.module}.{self.procedure}"


@dataclass(slots=True)
class PrivatizationAnalysis:
    candidates: list[PrivatizationCandidate]
    public_procedure_count: int
    cross_module_used_count: int
    zero_caller_public_count: int

    def as_dict(self) -> dict[str, object]:
        counts: dict[str, int] = {}
        for item in self.candidates:
            counts[item.classification] = counts.get(item.classification, 0) + 1
        return {
            "policy": {
                "scope": "Public procedures only",
                "candidate_rule": "no resolved cross-module incoming call",
                "automatic_source_change": False,
                "external_entry_points_proven_absent": False,
            },
            "candidates": [
                {
                    "id": item.qualified_name,
                    "module": item.module,
                    "module_path": item.module_path,
                    "procedure": item.procedure,
                    "kind": item.kind,
                    "line": item.line,
                    "local_incoming_edges": item.local_incoming_edges,
                    "local_call_sites": item.local_call_sites,
                    "classification": item.classification,
                    "confidence": item.confidence,
                    "reason": item.reason,
                }
                for item in self.candidates
            ],
            "statistics": {
                "public_procedure_count": self.public_procedure_count,
                "cross_module_used_public_count": self.cross_module_used_count,
                "candidate_count": len(self.candidates),
                "zero_caller_public_count": self.zero_caller_public_count,
                "classification_counts": counts,
            },
        }


def _entrypoint_like(name: str) -> bool:
    folded = name.casefold()
    return any(folded == prefix or folded.startswith(prefix + "_")
               for prefix in ENTRYPOINT_PREFIXES)


def analyze_privatization(
    repository: Repository,
    call_graph: CallGraph,
) -> PrivatizationAnalysis:
    incoming_local: dict[str, list] = {}
    incoming_cross: set[str] = set()

    for edge in call_graph.edges:
        key = edge.callee.casefold()
        if edge.caller_module == edge.callee_module:
            incoming_local.setdefault(key, []).append(edge)
        else:
            incoming_cross.add(key)

    candidates = []
    public_count = 0
    cross_used = 0
    zero_caller_count = 0

    for module in repository.modules:
        for proc in module.procedures:
            if proc.visibility != "Public":
                continue
            public_count += 1
            qname = f"{module.name}.{proc.name}"
            key = qname.casefold()
            if key in incoming_cross:
                cross_used += 1
                continue

            local_edges = incoming_local.get(key, [])
            local_sites = sum(edge.call_count for edge in local_edges)

            if local_edges:
                classification = "local-only"
                confidence = "high"
                reason = (
                    "Public procedure has resolved callers only inside its own module "
                    "and no resolved cross-module incoming call."
                )
            else:
                zero_caller_count += 1
                if _entrypoint_like(proc.name):
                    classification = "entrypoint-review"
                    confidence = "low"
                    reason = (
                        "No resolved repository caller, but the name is entry-point-like; "
                        "external LibreOffice or user invocation must be reviewed."
                    )
                else:
                    classification = "zero-caller-review"
                    confidence = "medium"
                    reason = (
                        "No resolved repository caller. It may be dead/internal code, "
                        "but external LibreOffice or user invocation cannot be excluded."
                    )

            candidates.append(
                PrivatizationCandidate(
                    module=module.name,
                    module_path=module.path,
                    procedure=proc.name,
                    kind=proc.kind,
                    line=proc.line,
                    local_incoming_edges=len(local_edges),
                    local_call_sites=local_sites,
                    classification=classification,
                    confidence=confidence,
                    reason=reason,
                )
            )

    rank = {"high": 0, "medium": 1, "low": 2}
    candidates.sort(
        key=lambda item: (
            rank[item.confidence],
            item.module.casefold(),
            item.line,
            item.procedure.casefold(),
        )
    )
    return PrivatizationAnalysis(
        candidates=candidates,
        public_procedure_count=public_count,
        cross_module_used_count=cross_used,
        zero_caller_public_count=zero_caller_count,
    )
