"""Token definitions for the LibreOffice Basic architecture lexer.

The lexer is intentionally lossless enough for architecture analysis: comments,
newlines, literals and punctuation are retained together with their exact source
position.  Later parser stages can therefore attach declarations to comments and
report precise line numbers without reading the source a second time.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class TokenKind(str, Enum):
    """Kinds of lexical elements emitted by :class:`BasicLexer`."""

    KEYWORD = "keyword"
    IDENTIFIER = "identifier"
    NUMBER = "number"
    STRING = "string"
    DATE = "date"
    COMMENT = "comment"
    OPERATOR = "operator"
    SEPARATOR = "separator"
    NEWLINE = "newline"
    LINE_CONTINUATION = "line_continuation"
    EOF = "eof"


@dataclass(frozen=True, slots=True)
class Token:
    """A token and its one-based source location."""

    kind: TokenKind
    value: str
    line: int
    column: int
    end_column: int

    def as_dict(self) -> dict[str, object]:
        """Return a stable JSON-compatible representation."""

        return {
            "kind": self.kind.value,
            "value": self.value,
            "line": self.line,
            "column": self.column,
            "end_column": self.end_column,
        }
