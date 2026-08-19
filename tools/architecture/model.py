"""Canonical in-memory model for the CompareFramework architecture analyzer."""

from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any


@dataclass(slots=True)
class Parameter:
    name: str
    type_name: str = "Variant"
    passing: str = "ByRef"
    optional: bool = False
    param_array: bool = False
    default_value: str | None = None
    is_array: bool = False


@dataclass(slots=True)
class Procedure:
    name: str
    kind: str
    visibility: str
    line: int
    end_line: int
    signature: str
    return_type: str | None = None
    parameters: list[Parameter] = field(default_factory=list)


@dataclass(slots=True)
class Constant:
    name: str
    visibility: str
    line: int
    type_name: str | None = None
    value: str | None = None


@dataclass(slots=True)
class Variable:
    name: str
    visibility: str
    line: int
    type_name: str = "Variant"
    is_array: bool = False
    storage: str = "Dim"


@dataclass(slots=True)
class TypeMember:
    name: str
    line: int
    type_name: str = "Variant"
    is_array: bool = False


@dataclass(slots=True)
class UserType:
    name: str
    visibility: str
    line: int
    end_line: int
    members: list[TypeMember] = field(default_factory=list)


@dataclass(slots=True)
class EnumMember:
    name: str
    line: int
    value: str | None = None


@dataclass(slots=True)
class Enum:
    name: str
    visibility: str
    line: int
    end_line: int
    members: list[EnumMember] = field(default_factory=list)


@dataclass(slots=True)
class Module:
    name: str
    path: str
    line_count: int
    option_explicit: bool = False
    procedures: list[Procedure] = field(default_factory=list)
    constants: list[Constant] = field(default_factory=list)
    variables: list[Variable] = field(default_factory=list)
    types: list[UserType] = field(default_factory=list)
    enums: list[Enum] = field(default_factory=list)
    parse_warnings: list[str] = field(default_factory=list)


@dataclass(slots=True)
class Repository:
    version: str = ""
    modules: list[Module] = field(default_factory=list)

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)
