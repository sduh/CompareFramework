"""Audit unresolved Public procedures against API contracts and user documentation."""

from __future__ import annotations

import csv
import re
from dataclasses import dataclass
from pathlib import Path

from .privatization import PrivatizationAnalysis


USER_DOCUMENTS = (
    "README.md",
    "docs/USER_GUIDE.md",
    "docs/API_REFERENCE.md",
    "STEP4_INTERACTIVE_CHECKLIST.md",
)


@dataclass(frozen=True, slots=True)
class EntrypointReview:
    id: str
    module: str
    module_path: str
    procedure: str
    static_classification: str
    inventory_classification: str
    inventory_decision: str
    user_document_references: tuple[str, ...]
    disposition: str
    rationale: str


@dataclass(slots=True)
class EntrypointAudit:
    reviews: list[EntrypointReview]

    def as_dict(self) -> dict[str, object]:
        counts: dict[str, int] = {}
        for item in self.reviews:
            counts[item.disposition] = counts.get(item.disposition, 0) + 1
        return {
            "policy": {
                "scope": "unresolved Public procedures remaining after high-confidence privatization",
                "automatic_source_change": False,
                "primary_inventory": "docs/audit/D1_PUBLIC_API_INVENTORY.csv",
                "supporting_inventory": "docs/audit/PUBLIC_SYMBOL_INVENTORY.csv",
                "documentation_conflicts_require_review": True,
            },
            "reviews": [
                {
                    "id": item.id,
                    "module": item.module,
                    "module_path": item.module_path,
                    "procedure": item.procedure,
                    "static_classification": item.static_classification,
                    "inventory_classification": item.inventory_classification,
                    "inventory_decision": item.inventory_decision,
                    "user_document_references": list(item.user_document_references),
                    "disposition": item.disposition,
                    "rationale": item.rationale,
                }
                for item in self.reviews
            ],
            "statistics": {
                "review_count": len(self.reviews),
                "disposition_counts": counts,
            },
        }


def _normalise_module_path(value: str) -> str:
    value = value.strip().replace("\\", "/")
    if value.casefold().startswith("src/"):
        value = value[4:]
    return value


def _load_d1_inventory(repository_root: Path) -> dict[tuple[str, str], dict[str, str]]:
    path = repository_root / "docs" / "audit" / "D1_PUBLIC_API_INVENTORY.csv"
    result: dict[tuple[str, str], dict[str, str]] = {}
    if not path.is_file():
        return result

    with path.open(encoding="utf-8-sig", newline="") as handle:
        rows = csv.reader(handle)
        for row in rows:
            if len(row) < 8 or row[5].casefold() == "symbol":
                continue
            module_path = _normalise_module_path(row[0])
            symbol = row[5].strip()
            if not module_path or not symbol:
                continue
            result[(module_path.casefold(), symbol.casefold())] = {
                "classification": row[6].strip(),
                "decision": row[7].strip(),
            }
    return result


def _load_supporting_inventory(
    repository_root: Path,
) -> dict[tuple[str, str], dict[str, str]]:
    path = repository_root / "docs" / "audit" / "PUBLIC_SYMBOL_INVENTORY.csv"
    result: dict[tuple[str, str], dict[str, str]] = {}
    if not path.is_file():
        return result

    with path.open(encoding="utf-8-sig", newline="") as handle:
        for row in csv.reader(handle):
            if len(row) < 7 or row[2].casefold() == "symbol":
                continue
            module_path = _normalise_module_path(row[0])
            symbol = row[2].strip()
            if not module_path or not symbol:
                continue
            result[(module_path.casefold(), symbol.casefold())] = {
                "classification": row[5].strip(),
                "decision": row[6].strip(),
            }
    return result


def _document_references(repository_root: Path, procedure: str) -> tuple[str, ...]:
    pattern = re.compile(rf"\b{re.escape(procedure)}\b", re.IGNORECASE)
    found = []
    for relative in USER_DOCUMENTS:
        path = repository_root / relative
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8-sig")
        if pattern.search(text):
            found.append(relative)
    return tuple(found)


def _disposition(
    inventory_classification: str,
    inventory_decision: str,
    references: tuple[str, ...],
) -> tuple[str, str]:
    classification = inventory_classification.casefold()
    decision = inventory_decision.casefold()

    if "keep-public" in decision or "keep public" in decision or "official-api" in classification:
        return (
            "keep-public-api",
            "Explicit official API contract requires Public visibility.",
        )

    if "review-public-maintenance" in decision or "maintenance-test" in classification:
        return (
            "maintenance-entrypoint-review",
            "Maintenance/test entry point requires an explicit lifecycle decision.",
        )

    if references:
        return (
            "documentation-conflict-review",
            "Inventory suggests privatization, but user-facing documentation still references "
            "the procedure; documentation and contract must be reconciled first.",
        )

    if "candidate-private-after-regression" in decision or "review -> private" in decision:
        return (
            "private-after-regression-review",
            "Both inventories identify a module-internal candidate; regression and external "
            "macro checks are still required before changing visibility.",
        )

    return (
        "unclassified-review",
        "Available inventories do not provide a decisive disposition.",
    )


def build_entrypoint_audit(
    repository_root: Path,
    privatization: PrivatizationAnalysis,
) -> EntrypointAudit:
    d1 = _load_d1_inventory(repository_root)
    supporting = _load_supporting_inventory(repository_root)

    unresolved = [
        item
        for item in privatization.candidates
        if item.classification in {"zero-caller-review", "entrypoint-review"}
    ]

    reviews = []
    for item in unresolved:
        key = (item.module_path.casefold(), item.procedure.casefold())
        primary = d1.get(key)
        fallback = supporting.get(key, {})
        contract = primary or fallback

        inventory_classification = contract.get("classification", "") if contract else ""
        inventory_decision = contract.get("decision", "") if contract else ""
        references = _document_references(repository_root, item.procedure)

        disposition, rationale = _disposition(
            inventory_classification,
            inventory_decision,
            references,
        )

        reviews.append(
            EntrypointReview(
                id=item.qualified_name,
                module=item.module,
                module_path=item.module_path,
                procedure=item.procedure,
                static_classification=item.classification,
                inventory_classification=inventory_classification,
                inventory_decision=inventory_decision,
                user_document_references=references,
                disposition=disposition,
                rationale=rationale,
            )
        )

    rank = {
        "keep-public-api": 0,
        "documentation-conflict-review": 1,
        "maintenance-entrypoint-review": 2,
        "private-after-regression-review": 3,
        "unclassified-review": 4,
    }
    reviews.sort(
        key=lambda item: (
            rank.get(item.disposition, 99),
            item.module.casefold(),
            item.procedure.casefold(),
        )
    )
    return EntrypointAudit(reviews)
