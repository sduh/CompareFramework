"""Symbol-table construction for the CompareFramework architecture analyzer.

The symbol table is derived exclusively from the parsed repository model.  It
never reparses source files, keeping ``architecture.json`` and tabular exports
consistent with the canonical model.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

from .model import Module, Repository


@dataclass(frozen=True, slots=True)
class Symbol:
    """A normalized architecture-relevant symbol."""

    module: str
    module_path: str
    name: str
    kind: str
    visibility: str
    line: int
    end_line: int | None = None
    parent: str | None = None
    type_name: str | None = None
    signature: str | None = None
    value: str | None = None

    @property
    def qualified_name(self) -> str:
        if self.parent:
            return f"{self.module}.{self.parent}.{self.name}"
        return f"{self.module}.{self.name}"


def module_symbols(module: Module) -> Iterable[Symbol]:
    """Yield every symbol represented by one parsed Basic module."""

    for procedure in module.procedures:
        yield Symbol(
            module=module.name,
            module_path=module.path,
            name=procedure.name,
            kind="procedure",
            visibility=procedure.visibility,
            line=procedure.line,
            end_line=procedure.end_line,
            type_name=procedure.return_type,
            signature=procedure.signature,
        )
        for parameter in procedure.parameters:
            yield Symbol(
                module=module.name,
                module_path=module.path,
                name=parameter.name,
                kind="parameter",
                visibility="Local",
                line=procedure.line,
                end_line=procedure.end_line,
                parent=procedure.name,
                type_name=parameter.type_name,
            )

    for constant in module.constants:
        yield Symbol(
            module=module.name,
            module_path=module.path,
            name=constant.name,
            kind="constant",
            visibility=constant.visibility,
            line=constant.line,
            type_name=constant.type_name,
            value=constant.value,
        )

    for variable in module.variables:
        yield Symbol(
            module=module.name,
            module_path=module.path,
            name=variable.name,
            kind="variable",
            visibility=variable.visibility,
            line=variable.line,
            type_name=variable.type_name,
        )

    for user_type in module.types:
        yield Symbol(
            module=module.name,
            module_path=module.path,
            name=user_type.name,
            kind="type",
            visibility=user_type.visibility,
            line=user_type.line,
            end_line=user_type.end_line,
        )
        for member in user_type.members:
            yield Symbol(
                module=module.name,
                module_path=module.path,
                name=member.name,
                kind="type_member",
                visibility="Member",
                line=member.line,
                end_line=user_type.end_line,
                parent=user_type.name,
                type_name=member.type_name,
            )

    for enum in module.enums:
        yield Symbol(
            module=module.name,
            module_path=module.path,
            name=enum.name,
            kind="enum",
            visibility=enum.visibility,
            line=enum.line,
            end_line=enum.end_line,
        )
        for member in enum.members:
            yield Symbol(
                module=module.name,
                module_path=module.path,
                name=member.name,
                kind="enum_member",
                visibility="Member",
                line=member.line,
                end_line=enum.end_line,
                parent=enum.name,
                value=member.value,
            )


def build_symbol_table(repository: Repository) -> list[Symbol]:
    """Return a deterministic flattened symbol table for a repository."""

    symbols = [symbol for module in repository.modules for symbol in module_symbols(module)]
    return sorted(
        symbols,
        key=lambda symbol: (
            symbol.module_path.casefold(),
            symbol.line,
            symbol.kind,
            symbol.name.casefold(),
        ),
    )
