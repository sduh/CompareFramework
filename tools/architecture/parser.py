"""Declaration parser for the LibreOffice Basic dialect used by CompareFramework.

The parser intentionally focuses on architecture-relevant declarations.  It is
not a compiler and does not evaluate expressions.  It consumes the lossless
lexer stream and extracts module options, procedures, constants, module-level
variables, user-defined types and enums with precise source locations.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Iterator

from .lexer import tokenize, tokenize_file
from .model import (
    Constant,
    Enum,
    EnumMember,
    Module,
    Parameter,
    Procedure,
    TypeMember,
    UserType,
    Variable,
)
from .tokens import Token, TokenKind


class ParserError(ValueError):
    """Raised when a declaration is structurally malformed."""


@dataclass(slots=True)
class Statement:
    tokens: list[Token]

    @property
    def line(self) -> int:
        return self.tokens[0].line if self.tokens else 0

    def words(self) -> list[str]:
        return [token.value.upper() for token in self.tokens]


_VISIBILITIES = {"PUBLIC", "PRIVATE", "GLOBAL"}
_PROCEDURE_KINDS = {"SUB", "FUNCTION", "PROPERTY"}
_STORAGE_KINDS = {"DIM", "STATIC", "GLOBAL", "PUBLIC", "PRIVATE"}
_TYPE_SUFFIX_MAP = {
    "$": "String",
    "%": "Integer",
    "&": "Long",
    "!": "Single",
    "#": "Double",
    "@": "Currency",
}


def _logical_statements(tokens: Iterable[Token]) -> Iterator[Statement]:
    """Yield Basic logical statements.

    Newlines terminate statements unless preceded by a continuation token.
    Colons split multiple statements on one physical line.  Comments are not
    part of declarations and terminate the current statement.
    """

    current: list[Token] = []
    continued = False
    for token in tokens:
        if token.kind is TokenKind.EOF:
            if current:
                yield Statement(current)
            return
        if token.kind is TokenKind.COMMENT:
            if current and not continued:
                yield Statement(current)
                current = []
            continue
        if token.kind is TokenKind.LINE_CONTINUATION:
            continued = True
            continue
        if token.kind is TokenKind.NEWLINE:
            if continued:
                continued = False
                continue
            if current:
                yield Statement(current)
                current = []
            continue
        if token.kind is TokenKind.SEPARATOR and token.value == ":":
            if current:
                yield Statement(current)
                current = []
            continued = False
            continue
        current.append(token)


def _visibility(tokens: list[Token], default: str = "Public") -> tuple[str, int]:
    if tokens and tokens[0].value.upper() in _VISIBILITIES:
        value = tokens[0].value.upper()
        return ("Public" if value in {"PUBLIC", "GLOBAL"} else "Private", 1)
    return default, 0


def _identifier_name(token: Token) -> str:
    return token.value.rstrip("$%&!#@")


def _suffix_type(token: Token) -> str | None:
    return _TYPE_SUFFIX_MAP.get(token.value[-1:])


def _tokens_text(tokens: Iterable[Token]) -> str:
    """Produce a deterministic readable representation of a token slice."""

    result = ""
    previous: Token | None = None
    no_space_before = {",", ")", "]", ";", "."}
    no_space_after = {"(", "[", "."}
    for token in tokens:
        value = token.value
        if result and value not in no_space_before and (previous is None or previous.value not in no_space_after):
            result += " "
        result += value
        previous = token
    return result


def _find_matching(tokens: list[Token], start: int, opening: str = "(", closing: str = ")") -> int:
    depth = 0
    for index in range(start, len(tokens)):
        value = tokens[index].value
        if value == opening:
            depth += 1
        elif value == closing:
            depth -= 1
            if depth == 0:
                return index
    raise ParserError(f"Unclosed {opening!r} at line {tokens[start].line}")


def _split_top_level(tokens: list[Token], separator: str = ",") -> list[list[Token]]:
    chunks: list[list[Token]] = []
    current: list[Token] = []
    depth = 0
    for token in tokens:
        if token.value in {"(", "["}:
            depth += 1
        elif token.value in {")",
            "]",
        }:
            depth = max(0, depth - 1)
        if token.value == separator and depth == 0:
            chunks.append(current)
            current = []
        else:
            current.append(token)
    if current:
        chunks.append(current)
    return chunks


def _parse_parameter(tokens: list[Token]) -> Parameter | None:
    if not tokens:
        return None
    upper = [token.value.upper() for token in tokens]
    optional = "OPTIONAL" in upper
    param_array = "PARAMARRAY" in upper
    passing = "ByVal" if "BYVAL" in upper else "ByRef"

    skip = {"OPTIONAL", "PARAMARRAY", "BYVAL", "BYREF"}
    name_index = next((i for i, value in enumerate(upper) if value not in skip), None)
    if name_index is None:
        return None
    name_token = tokens[name_index]
    name = _identifier_name(name_token)
    is_array = name_index + 1 < len(tokens) and tokens[name_index + 1].value == "("
    type_name = _suffix_type(name_token) or "Variant"

    as_index = next((i for i in range(name_index + 1, len(tokens)) if upper[i] == "AS"), None)
    if as_index is not None and as_index + 1 < len(tokens):
        type_name = _tokens_text(tokens[as_index + 1 :]).split(" = ", 1)[0]

    default_value = None
    equals_index = next((i for i, token in enumerate(tokens) if token.value == "="), None)
    if equals_index is not None:
        default_value = _tokens_text(tokens[equals_index + 1 :])
        if as_index is not None:
            type_name = _tokens_text(tokens[as_index + 1 : equals_index])

    return Parameter(
        name=name,
        type_name=type_name or "Variant",
        passing=passing,
        optional=optional,
        param_array=param_array,
        default_value=default_value,
        is_array=is_array,
    )


def _parse_procedure_start(statement: Statement) -> Procedure | None:
    tokens = statement.tokens
    visibility, index = _visibility(tokens)
    if index >= len(tokens):
        return None

    # Static Sub/Function is legal and module-visible by default.
    if tokens[index].value.upper() == "STATIC":
        index += 1
    if index >= len(tokens) or tokens[index].value.upper() not in _PROCEDURE_KINDS:
        return None

    kind = tokens[index].value.title()
    index += 1
    # Property Get/Let/Set has a second kind word.
    if kind == "Property" and index < len(tokens) and tokens[index].value.upper() in {"GET", "LET", "SET"}:
        kind = f"Property {tokens[index].value.title()}"
        index += 1
    if index >= len(tokens):
        raise ParserError(f"Missing procedure name at line {statement.line}")

    name_token = tokens[index]
    name = _identifier_name(name_token)
    index += 1
    parameters: list[Parameter] = []
    return_type = _suffix_type(name_token)

    close_index = index - 1
    if index < len(tokens) and tokens[index].value == "(":
        close_index = _find_matching(tokens, index)
        for chunk in _split_top_level(tokens[index + 1 : close_index]):
            parameter = _parse_parameter(chunk)
            if parameter is not None:
                parameters.append(parameter)

    upper = [token.value.upper() for token in tokens]
    as_index = next((i for i in range(close_index + 1, len(tokens)) if upper[i] == "AS"), None)
    if as_index is not None and as_index + 1 < len(tokens):
        return_type = _tokens_text(tokens[as_index + 1 :])
    if kind == "Sub":
        return_type = None

    return Procedure(
        name=name,
        kind=kind,
        visibility=visibility,
        line=statement.line,
        end_line=statement.line,
        signature=_tokens_text(tokens),
        return_type=return_type,
        parameters=parameters,
    )


def _parse_constant(statement: Statement) -> list[Constant]:
    tokens = statement.tokens
    visibility, index = _visibility(tokens)
    if index >= len(tokens) or tokens[index].value.upper() != "CONST":
        return []
    declarations = _split_top_level(tokens[index + 1 :])
    result: list[Constant] = []
    for declaration in declarations:
        if not declaration:
            continue
        name_token = declaration[0]
        upper = [token.value.upper() for token in declaration]
        type_name = _suffix_type(name_token)
        as_index = next((i for i, value in enumerate(upper) if value == "AS"), None)
        equals_index = next((i for i, token in enumerate(declaration) if token.value == "="), None)
        if as_index is not None and as_index + 1 < len(declaration):
            end = equals_index if equals_index is not None else len(declaration)
            type_name = _tokens_text(declaration[as_index + 1 : end])
        value = _tokens_text(declaration[equals_index + 1 :]) if equals_index is not None else None
        result.append(Constant(_identifier_name(name_token), visibility, statement.line, type_name, value))
    return result


def _parse_variables(statement: Statement) -> list[Variable]:
    tokens = statement.tokens
    if not tokens:
        return []
    first = tokens[0].value.upper()
    if first not in _STORAGE_KINDS:
        return []

    visibility = "Private"
    storage = tokens[0].value.title()
    index = 1
    if first in {"PUBLIC", "PRIVATE", "GLOBAL"}:
        visibility = "Public" if first in {"PUBLIC", "GLOBAL"} else "Private"
        if index < len(tokens) and tokens[index].value.upper() in {"DIM", "STATIC"}:
            storage = tokens[index].value.title()
            index += 1
    elif first == "STATIC":
        visibility = "Private"
    elif first == "DIM":
        visibility = "Private"

    # Procedure/Const/Type/Enum declarations using the same visibility prefix.
    if index < len(tokens) and tokens[index].value.upper() in _PROCEDURE_KINDS | {"CONST", "TYPE", "ENUM"}:
        return []

    result: list[Variable] = []
    for declaration in _split_top_level(tokens[index:]):
        if not declaration:
            continue
        name_token = declaration[0]
        upper = [token.value.upper() for token in declaration]
        is_array = len(declaration) > 1 and declaration[1].value == "("
        type_name = _suffix_type(name_token) or "Variant"
        as_index = next((i for i, value in enumerate(upper) if value == "AS"), None)
        if as_index is not None and as_index + 1 < len(declaration):
            type_name = _tokens_text(declaration[as_index + 1 :])
        result.append(
            Variable(
                name=_identifier_name(name_token),
                visibility=visibility,
                line=statement.line,
                type_name=type_name,
                is_array=is_array,
                storage=storage,
            )
        )
    return result


def parse_module(source: str, name: str, path: str = "") -> Module:
    """Parse a Basic module from memory."""

    lines = source.replace("\r\n", "\n").replace("\r", "\n").splitlines()
    module = Module(name=name, path=path, line_count=len(lines))
    statements = list(_logical_statements(tokenize(source)))

    active_procedure: Procedure | None = None
    active_type: UserType | None = None
    active_enum: Enum | None = None

    for statement in statements:
        if not statement.tokens:
            continue
        words = statement.words()

        if active_procedure is not None:
            if len(words) >= 2 and words[0] == "END" and (
                words[1] == active_procedure.kind.split()[0].upper()
                or (active_procedure.kind.startswith("Property") and words[1] == "PROPERTY")
            ):
                active_procedure.end_line = statement.line
                active_procedure = None
            continue

        if active_type is not None:
            if words[:2] == ["END", "TYPE"]:
                active_type.end_line = statement.line
                active_type = None
                continue
            members = _parse_variables(Statement([Token(TokenKind.KEYWORD, "Dim", statement.line, 1, 3)] + statement.tokens))
            for member in members:
                active_type.members.append(TypeMember(member.name, member.line, member.type_name, member.is_array))
            continue

        if active_enum is not None:
            if words[:2] == ["END", "ENUM"]:
                active_enum.end_line = statement.line
                active_enum = None
                continue
            declaration = statement.tokens
            if declaration:
                equals_index = next((i for i, token in enumerate(declaration) if token.value == "="), None)
                value = _tokens_text(declaration[equals_index + 1 :]) if equals_index is not None else None
                active_enum.members.append(EnumMember(_identifier_name(declaration[0]), statement.line, value))
            continue

        if words[:2] == ["OPTION", "EXPLICIT"]:
            module.option_explicit = True
            continue

        procedure = _parse_procedure_start(statement)
        if procedure is not None:
            module.procedures.append(procedure)
            active_procedure = procedure
            continue

        visibility, index = _visibility(statement.tokens)
        if index < len(statement.tokens) and statement.tokens[index].value.upper() == "TYPE":
            if index + 1 >= len(statement.tokens):
                raise ParserError(f"Missing Type name at line {statement.line}")
            active_type = UserType(
                _identifier_name(statement.tokens[index + 1]), visibility, statement.line, statement.line
            )
            module.types.append(active_type)
            continue
        if index < len(statement.tokens) and statement.tokens[index].value.upper() == "ENUM":
            if index + 1 >= len(statement.tokens):
                raise ParserError(f"Missing Enum name at line {statement.line}")
            active_enum = Enum(
                _identifier_name(statement.tokens[index + 1]), visibility, statement.line, statement.line
            )
            module.enums.append(active_enum)
            continue

        constants = _parse_constant(statement)
        if constants:
            module.constants.extend(constants)
            continue
        module.variables.extend(_parse_variables(statement))

    if active_procedure is not None:
        module.parse_warnings.append(
            f"Procedure {active_procedure.name} opened at line {active_procedure.line} has no matching End"
        )
    if active_type is not None:
        module.parse_warnings.append(f"Type {active_type.name} opened at line {active_type.line} has no matching End Type")
    if active_enum is not None:
        module.parse_warnings.append(f"Enum {active_enum.name} opened at line {active_enum.line} has no matching End Enum")
    return module


def parse_module_file(path: Path, source_root: Path | None = None) -> Module:
    """Parse a UTF-8 Basic module file."""

    source = path.read_text(encoding="utf-8-sig")
    relative = path.relative_to(source_root) if source_root is not None else path
    return parse_module(source, path.stem, relative.as_posix())
