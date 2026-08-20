"""Procedure call-graph extraction for LibreOffice Basic.

The extractor resolves calls only against procedures parsed from the repository.
This deliberately avoids guessing about UNO methods or Basic built-ins.  It
supports local procedure precedence, public cross-module resolution and
explicit ``ModuleName.Procedure`` qualification.

A function's result assignment (``FunctionName = value``) is not considered a
recursive call.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable

from .lexer import tokenize_file
from .model import Module, Procedure, Repository
from .tokens import Token, TokenKind


@dataclass(frozen=True, slots=True)
class ProcedureRef:
    module: str
    module_path: str
    name: str
    visibility: str
    kind: str
    line: int

    @property
    def qualified_name(self) -> str:
        return f"{self.module}.{self.name}"


@dataclass(slots=True)
class CallEdge:
    caller: str
    caller_module: str
    callee: str
    callee_module: str
    call_count: int = 0
    lines: list[int] = field(default_factory=list)
    recursive: bool = False

    def add_call(self, line: int) -> None:
        self.call_count += 1
        if line not in self.lines:
            self.lines.append(line)
            self.lines.sort()


@dataclass(slots=True)
class CallGraph:
    nodes: list[ProcedureRef]
    edges: list[CallEdge]
    unresolved_candidate_count: int = 0
    ambiguous_candidate_count: int = 0

    def as_dict(self) -> dict[str, object]:
        return {
            "nodes": [
                {
                    "id": node.qualified_name,
                    "module": node.module,
                    "module_path": node.module_path,
                    "name": node.name,
                    "visibility": node.visibility,
                    "kind": node.kind,
                    "line": node.line,
                }
                for node in self.nodes
            ],
            "edges": [
                {
                    "caller": edge.caller,
                    "caller_module": edge.caller_module,
                    "callee": edge.callee,
                    "callee_module": edge.callee_module,
                    "call_count": edge.call_count,
                    "lines": edge.lines,
                    "recursive": edge.recursive,
                }
                for edge in self.edges
            ],
            "statistics": {
                "node_count": len(self.nodes),
                "edge_count": len(self.edges),
                "call_site_count": sum(edge.call_count for edge in self.edges),
                "cross_module_edge_count": sum(
                    edge.caller_module != edge.callee_module for edge in self.edges
                ),
                "recursive_edge_count": sum(edge.recursive for edge in self.edges),
                "unresolved_candidate_count": self.unresolved_candidate_count,
                "ambiguous_candidate_count": self.ambiguous_candidate_count,
            },
        }


class ProcedureResolver:
    """Resolve Basic procedure names according to module visibility."""

    def __init__(self, repository: Repository):
        self._modules = {module.name.casefold(): module for module in repository.modules}
        self._local: dict[tuple[str, str], ProcedureRef] = {}
        self._public: dict[str, list[ProcedureRef]] = {}
        self._all_names: set[str] = set()

        for module in repository.modules:
            for proc in module.procedures:
                ref = ProcedureRef(
                    module=module.name,
                    module_path=module.path,
                    name=proc.name,
                    visibility=proc.visibility,
                    kind=proc.kind,
                    line=proc.line,
                )
                key = proc.name.casefold()
                self._all_names.add(key)
                self._local[(module.name.casefold(), key)] = ref
                if proc.visibility == "Public":
                    self._public.setdefault(key, []).append(ref)

    @property
    def known_names(self) -> set[str]:
        return self._all_names

    @property
    def module_names(self) -> set[str]:
        return set(self._modules)

    def resolve(
        self,
        caller_module: str,
        procedure_name: str,
        explicit_module: str | None = None,
    ) -> tuple[ProcedureRef | None, bool]:
        """Return ``(target, ambiguous)``.

        Local procedures win for unqualified calls.  Explicit module
        qualification resolves only inside that module and still respects
        visibility for cross-module calls.
        """

        proc_key = procedure_name.casefold()
        caller_key = caller_module.casefold()

        if explicit_module is not None:
            module_key = explicit_module.casefold()
            target = self._local.get((module_key, proc_key))
            if target is None:
                return None, False
            if module_key == caller_key or target.visibility == "Public":
                return target, False
            return None, False

        local = self._local.get((caller_key, proc_key))
        if local is not None:
            return local, False

        candidates = self._public.get(proc_key, [])
        if len(candidates) == 1:
            return candidates[0], False
        if len(candidates) > 1:
            return None, True
        return None, False


def _significant(tokens: Iterable[Token]) -> list[Token]:
    return [
        token
        for token in tokens
        if token.kind not in {
            TokenKind.COMMENT,
            TokenKind.NEWLINE,
            TokenKind.LINE_CONTINUATION,
            TokenKind.EOF,
        }
    ]


def _body_tokens(tokens: list[Token], procedure: Procedure) -> list[Token]:
    # Procedure declarations and End Sub/Function are intentionally excluded.
    return [
        token
        for token in tokens
        if procedure.line < token.line < procedure.end_line
    ]


def _is_function_result_assignment(
    tokens: list[Token],
    index: int,
    caller: Procedure,
) -> bool:
    token = tokens[index]
    if token.value.casefold() != caller.name.casefold():
        return False

    # In Basic a function returns a value by assigning to its own name.
    next_token = tokens[index + 1] if index + 1 < len(tokens) else None
    return (
        caller.kind.casefold() == "function"
        and next_token is not None
        and next_token.value == "="
    )


def _explicit_module(tokens: list[Token], index: int, resolver: ProcedureResolver) -> str | None:
    if index < 2 or tokens[index - 1].value != ".":
        return None
    owner = tokens[index - 2]
    if owner.kind is not TokenKind.IDENTIFIER:
        return None
    if owner.value.casefold() in resolver.module_names:
        return owner.value
    return None


def _is_object_member(tokens: list[Token], index: int, resolver: ProcedureResolver) -> bool:
    if index == 0 or tokens[index - 1].value != ".":
        return False
    # Module-qualified calls are valid; other dotted names are UNO/object members.
    return _explicit_module(tokens, index, resolver) is None


def _procedure_nodes(repository: Repository) -> list[ProcedureRef]:
    nodes = []
    for module in repository.modules:
        for proc in module.procedures:
            nodes.append(
                ProcedureRef(
                    module=module.name,
                    module_path=module.path,
                    name=proc.name,
                    visibility=proc.visibility,
                    kind=proc.kind,
                    line=proc.line,
                )
            )
    return sorted(
        nodes,
        key=lambda ref: (ref.module_path.casefold(), ref.line, ref.name.casefold()),
    )


def build_call_graph(repository_root: Path, repository: Repository) -> CallGraph:
    resolver = ProcedureResolver(repository)
    edge_map: dict[tuple[str, str], CallEdge] = {}
    unresolved = 0
    ambiguous = 0

    for module in repository.modules:
        source_path = repository_root / "src" / module.path
        tokens = tokenize_file(source_path)

        for caller in module.procedures:
            body = _significant(_body_tokens(tokens, caller))

            for index, token in enumerate(body):
                if token.kind is not TokenKind.IDENTIFIER:
                    continue
                if token.value.casefold() not in resolver.known_names:
                    continue
                if _is_function_result_assignment(body, index, caller):
                    continue
                if _is_object_member(body, index, resolver):
                    continue

                explicit_module = _explicit_module(body, index, resolver)
                target, is_ambiguous = resolver.resolve(
                    module.name,
                    token.value,
                    explicit_module=explicit_module,
                )
                if is_ambiguous:
                    ambiguous += 1
                    continue
                if target is None:
                    unresolved += 1
                    continue

                caller_id = f"{module.name}.{caller.name}"
                callee_id = target.qualified_name
                key = (caller_id.casefold(), callee_id.casefold())
                edge = edge_map.get(key)
                if edge is None:
                    edge = CallEdge(
                        caller=caller_id,
                        caller_module=module.name,
                        callee=callee_id,
                        callee_module=target.module,
                        recursive=caller_id.casefold() == callee_id.casefold(),
                    )
                    edge_map[key] = edge
                edge.add_call(token.line)

    edges = sorted(
        edge_map.values(),
        key=lambda edge: (
            edge.caller.casefold(),
            edge.callee.casefold(),
        ),
    )
    return CallGraph(
        nodes=_procedure_nodes(repository),
        edges=edges,
        unresolved_candidate_count=unresolved,
        ambiguous_candidate_count=ambiguous,
    )
