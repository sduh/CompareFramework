"""Contract-aware qualification of Public LibreOffice Basic procedures.

Static call-graph evidence is necessary but not sufficient for privatization.
Explicit decisions from ``docs/audit/PUBLIC_SYMBOL_INVENTORY.csv`` override
static heuristics. In particular, ``Keep Public`` symbols are protected and are
never returned as privatization candidates.
"""

from __future__ import annotations

import csv
from dataclasses import dataclass
from pathlib import Path

from .callgraph import CallGraph
from .model import Repository


ENTRYPOINT_PREFIXES = (
    "main", "test", "run", "execute", "initialize", "init",
    "on", "handle", "open", "close",
)


@dataclass(frozen=True, slots=True)
class PublicContract:
    module_path: str
    procedure: str
    classification: str
    decision: str
    notes: str = ""

    @property
    def keep_public(self) -> bool:
        return "keep public" in self.decision.casefold()


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


@dataclass(frozen=True, slots=True)
class ProtectedPublic:
    module: str
    module_path: str
    procedure: str
    kind: str
    line: int
    static_classification: str
    contract_classification: str
    contract_decision: str
    reason: str

    @property
    def qualified_name(self) -> str:
        return f"{self.module}.{self.procedure}"


@dataclass(slots=True)
class PrivatizationAnalysis:
    candidates: list[PrivatizationCandidate]
    protected_public: list[ProtectedPublic]
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
                "contract_inventory": "docs/audit/PUBLIC_SYMBOL_INVENTORY.csv",
                "contract_precedence": True,
                "keep_public_excluded_from_candidates": True,
                "automatic_source_change": False,
                "external_entry_points_proven_absent": False,
            },
            "protected_public": [
                {
                    "id": item.qualified_name,
                    "module": item.module,
                    "module_path": item.module_path,
                    "procedure": item.procedure,
                    "kind": item.kind,
                    "line": item.line,
                    "static_classification": item.static_classification,
                    "contract_classification": item.contract_classification,
                    "contract_decision": item.contract_decision,
                    "reason": item.reason,
                }
                for item in self.protected_public
            ],
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
                "protected_public_count": len(self.protected_public),
                "zero_caller_public_count": self.zero_caller_public_count,
                "classification_counts": counts,
            },
        }


def load_public_contracts(repository_root: Path) -> dict[tuple[str, str], PublicContract]:
    path = repository_root / "docs" / "audit" / "PUBLIC_SYMBOL_INVENTORY.csv"
    if not path.is_file():
        return {}

    contracts: dict[tuple[str, str], PublicContract] = {}
    with path.open(encoding="utf-8-sig", newline="") as handle:
        for row in csv.reader(handle):
            if len(row) < 7 or not row[2] or row[2] == "Symbol":
                continue
            contract = PublicContract(
                module_path=row[0],
                procedure=row[2],
                classification=row[5],
                decision=row[6],
                notes=row[7] if len(row) > 7 else "",
            )
            contracts[(contract.module_path.casefold(), contract.procedure.casefold())] = contract
    return contracts


def _entrypoint_like(name: str) -> bool:
    folded = name.casefold()
    return any(
        folded == prefix or folded.startswith(prefix + "_")
        for prefix in ENTRYPOINT_PREFIXES
    )


def _static_classification(local_edges: list, proc_name: str) -> tuple[str, str, str]:
    if local_edges:
        return (
            "local-only",
            "high",
            "Public procedure has resolved callers only inside its own module "
            "and no resolved cross-module incoming call.",
        )
    if _entrypoint_like(proc_name):
        return (
            "entrypoint-review",
            "low",
            "No resolved repository caller, but the name is entry-point-like; "
            "external LibreOffice or user invocation must be reviewed.",
        )
    return (
        "zero-caller-review",
        "medium",
        "No resolved repository caller. It may be dead/internal code, but "
        "external LibreOffice or user invocation cannot be excluded.",
    )


def analyze_privatization(
    repository: Repository,
    call_graph: CallGraph,
    repository_root: Path | None = None,
) -> PrivatizationAnalysis:
    incoming_local: dict[str, list] = {}
    incoming_cross: set[str] = set()

    for edge in call_graph.edges:
        key = edge.callee.casefold()
        if edge.caller_module == edge.callee_module:
            incoming_local.setdefault(key, []).append(edge)
        else:
            incoming_cross.add(key)

    contracts = load_public_contracts(repository_root) if repository_root else {}

    candidates: list[PrivatizationCandidate] = []
    protected: list[ProtectedPublic] = []
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
            classification, confidence, reason = _static_classification(
                local_edges, proc.name
            )

            if not local_edges:
                zero_caller_count += 1

            contract = contracts.get((module.path.casefold(), proc.name.casefold()))
            if contract is not None and contract.keep_public:
                protected.append(
                    ProtectedPublic(
                        module=module.name,
                        module_path=module.path,
                        procedure=proc.name,
                        kind=proc.kind,
                        line=proc.line,
                        static_classification=classification,
                        contract_classification=contract.classification,
                        contract_decision=contract.decision,
                        reason=(
                            "Explicit public API contract overrides static "
                            f"{classification} classification."
                        ),
                    )
                )
                continue

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
    protected.sort(
        key=lambda item: (
            item.module.casefold(),
            item.line,
            item.procedure.casefold(),
        )
    )

    return PrivatizationAnalysis(
        candidates=candidates,
        protected_public=protected,
        public_procedure_count=public_count,
        cross_module_used_count=cross_used,
        zero_caller_public_count=zero_caller_count,
    )
