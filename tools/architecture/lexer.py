"""Lexer for the LibreOffice Basic dialect used by CompareFramework.

This is a lexical analyser, not a compiler.  It recognises the constructs needed
by the architecture parser while preserving source positions and comments.  The
implementation is deterministic, has no external dependency and accepts the
whole current ``src/**/*.bas`` corpus.
"""

from __future__ import annotations

from collections.abc import Iterator
from pathlib import Path

from .tokens import Token, TokenKind


# LibreOffice Basic is case-insensitive.  Values are kept exactly as written in
# tokens, while this set is used for classification only.
KEYWORDS = frozenset(
    {
        "ACCESSCOMPATIBLE",
        "ALIAS",
        "AND",
        "ANY",
        "APPEND",
        "AS",
        "BASE",
        "BASIC",
        "BINARY",
        "BOOLEAN",
        "BYREF",
        "BYTE",
        "BYVAL",
        "CALL",
        "CASE",
        "CBOOL",
        "CBYTE",
        "CCUR",
        "CDATE",
        "CDBL",
        "CDEC",
        "CINT",
        "CLASSMODULE",
        "CLNG",
        "COMPARE",
        "CONST",
        "CSNG",
        "CSTR",
        "CURRENCY",
        "DATE",
        "DECLARE",
        "DEFBOOL",
        "DEFBYTE",
        "DEFCUR",
        "DEFDATE",
        "DEFDBL",
        "DEFERR",
        "DEFINT",
        "DEFLNG",
        "DEFOBJ",
        "DEFSNG",
        "DEFSTR",
        "DEFVAR",
        "DIM",
        "DO",
        "DOUBLE",
        "EACH",
        "ELSE",
        "ELSEIF",
        "EMPTY",
        "END",
        "ENUM",
        "EQV",
        "ERROR",
        "EVENT",
        "EXIT",
        "EXPLICIT",
        "FALSE",
        "FOR",
        "FUNCTION",
        "GET",
        "GLOBAL",
        "GOSUB",
        "GOTO",
        "IF",
        "IMP",
        "IMPLEMENTS",
        "IN",
        "INPUT",
        "INTEGER",
        "IS",
        "LET",
        "LIB",
        "LIKE",
        "LINE",
        "LOCK",
        "LONG",
        "LOOP",
        "LSET",
        "MOD",
        "NAME",
        "NEW",
        "NEXT",
        "NOT",
        "NOTHING",
        "NULL",
        "OBJECT",
        "ON",
        "OPEN",
        "OPTION",
        "OPTIONAL",
        "OR",
        "OUTPUT",
        "PARAMARRAY",
        "PRESERVE",
        "PRINT",
        "PRIVATE",
        "PROPERTY",
        "PUBLIC",
        "RANDOM",
        "READ",
        "REDIM",
        "REM",
        "RESUME",
        "RETURN",
        "RSET",
        "SELECT",
        "SET",
        "SHARED",
        "SINGLE",
        "STATIC",
        "STEP",
        "STOP",
        "STRING",
        "SUB",
        "SYSTEM",
        "TEXT",
        "THEN",
        "TO",
        "TRUE",
        "TYPE",
        "TYPEOF",
        "UNTIL",
        "VARIANT",
        "WEND",
        "WHILE",
        "WITH",
        "WRITE",
        "XOR",
    }
)

# Longest operators are tested first.
OPERATORS = ("<=", ">=", "<>", ":=", "=", "+", "-", "*", "/", "\\", "^", "&", "<", ">")
SEPARATORS = frozenset("(),.:;[]{}")
TYPE_SUFFIXES = frozenset("$%&!#@")


class LexerError(ValueError):
    """Raised for a malformed lexical construct."""

    def __init__(self, message: str, line: int, column: int) -> None:
        super().__init__(f"{message} at line {line}, column {column}")
        self.line = line
        self.column = column


class BasicLexer:
    """Tokenise LibreOffice Basic source text."""

    def __init__(self, source: str) -> None:
        # Normalising line endings makes positions and tests platform-neutral.
        self.source = source.replace("\r\n", "\n").replace("\r", "\n")
        self.length = len(self.source)
        self.index = 0
        self.line = 1
        self.column = 1
        self._line_has_code = False

    def tokenize(self) -> list[Token]:
        """Return all tokens, including a terminal EOF token."""

        return list(self.iter_tokens())

    def iter_tokens(self) -> Iterator[Token]:
        """Yield tokens from the source in lexical order."""

        while self.index < self.length:
            char = self._peek()

            if char in " \t\f\v":
                self._advance()
                continue

            if char == "\n":
                yield self._single_char_token(TokenKind.NEWLINE)
                self._line_has_code = False
                continue

            if char == "'":
                yield self._read_apostrophe_comment()
                continue

            if char == '"':
                token = self._read_string()
                self._line_has_code = True
                yield token
                continue

            if char == "#":
                # '#' is a type suffix when attached to an identifier, but at a
                # token boundary it starts a Basic date literal.
                token = self._read_date_literal()
                self._line_has_code = True
                yield token
                continue

            if char.isdigit() or (char == "." and self._peek(1).isdigit()) or (
                char == "&" and self._peek(1).upper() in {"H", "O"}
            ):
                token = self._read_number()
                self._line_has_code = True
                yield token
                continue

            if char == "_" and self._is_line_continuation():
                token = self._read_line_continuation()
                self._line_has_code = True
                yield token
                continue

            if self._is_identifier_start(char):
                token = self._read_word()
                if token.kind is not TokenKind.COMMENT:
                    self._line_has_code = True
                yield token
                continue

            operator = self._match_operator()
            if operator is not None:
                token = self._consume_text(TokenKind.OPERATOR, operator)
                self._line_has_code = True
                yield token
                continue

            if char in SEPARATORS:
                token = self._single_char_token(TokenKind.SEPARATOR)
                self._line_has_code = True
                yield token
                continue

            raise LexerError(f"Unexpected character {char!r}", self.line, self.column)

        yield Token(TokenKind.EOF, "", self.line, self.column, self.column)

    def _read_word(self) -> Token:
        start_line, start_column, start_index = self.line, self.column, self.index
        self._advance()
        while self._is_identifier_part(self._peek()):
            self._advance()

        # Basic permits declaration type characters on identifiers (name$,
        # count&, etc.).  They belong to the identifier token.
        if self._peek() in TYPE_SUFFIXES:
            self._advance()

        value = self.source[start_index : self.index]
        upper = value.upper()

        # REM starts a comment only as a standalone word.  As in Basic, it may
        # appear after a statement separator; retaining the entire tail is most
        # useful for documentation attachment.
        if upper == "REM" and self._next_is_word_boundary():
            while self.index < self.length and self._peek() != "\n":
                self._advance()
            value = self.source[start_index : self.index]
            return Token(TokenKind.COMMENT, value, start_line, start_column, self.column - 1)

        kind = TokenKind.KEYWORD if upper.rstrip("$%&!#@") in KEYWORDS else TokenKind.IDENTIFIER
        return Token(kind, value, start_line, start_column, self.column - 1)

    def _read_apostrophe_comment(self) -> Token:
        start_line, start_column, start_index = self.line, self.column, self.index
        while self.index < self.length and self._peek() != "\n":
            self._advance()
        return Token(
            TokenKind.COMMENT,
            self.source[start_index : self.index],
            start_line,
            start_column,
            self.column - 1,
        )

    def _read_string(self) -> Token:
        start_line, start_column, start_index = self.line, self.column, self.index
        self._advance()  # opening quote
        while self.index < self.length:
            char = self._peek()
            if char == "\n":
                raise LexerError("Unterminated string literal", start_line, start_column)
            if char == '"':
                if self._peek(1) == '"':
                    self._advance(2)  # escaped quote
                    continue
                self._advance()
                return Token(
                    TokenKind.STRING,
                    self.source[start_index : self.index],
                    start_line,
                    start_column,
                    self.column - 1,
                )
            self._advance()
        raise LexerError("Unterminated string literal", start_line, start_column)

    def _read_date_literal(self) -> Token:
        start_line, start_column, start_index = self.line, self.column, self.index
        self._advance()  # opening #
        while self.index < self.length:
            char = self._peek()
            if char == "\n":
                raise LexerError("Unterminated date literal", start_line, start_column)
            self._advance()
            if char == "#":
                return Token(
                    TokenKind.DATE,
                    self.source[start_index : self.index],
                    start_line,
                    start_column,
                    self.column - 1,
                )
        raise LexerError("Unterminated date literal", start_line, start_column)

    def _read_number(self) -> Token:
        start_line, start_column, start_index = self.line, self.column, self.index

        # Hexadecimal and octal literals: &HFF, &O77.  The ampersand is handled
        # here only when followed by the base marker.
        if self._peek() == "&" and self._peek(1).upper() in {"H", "O"}:
            self._advance(2)
            valid = "0123456789ABCDEFabcdef" if self.source[start_index + 1].upper() == "H" else "01234567"
            while self._peek() in valid:
                self._advance()
        else:
            if self._peek() == ".":
                self._advance()
                while self._peek().isdigit():
                    self._advance()
            else:
                while self._peek().isdigit():
                    self._advance()
                if self._peek() == ".":
                    self._advance()
                    while self._peek().isdigit():
                        self._advance()

            if self._peek().upper() in {"E", "D"}:
                exponent_index = self.index
                self._advance()
                if self._peek() in "+-":
                    self._advance()
                if not self._peek().isdigit():
                    consumed = self.index - exponent_index
                    self.index = exponent_index
                    self.column -= consumed
                else:
                    while self._peek().isdigit():
                        self._advance()

        if self._peek() in TYPE_SUFFIXES:
            self._advance()

        return Token(
            TokenKind.NUMBER,
            self.source[start_index : self.index],
            start_line,
            start_column,
            self.column - 1,
        )

    def _is_line_continuation(self) -> bool:
        # An underscore is a continuation marker only when the remainder of the
        # physical line contains whitespace and, optionally, a comment.
        cursor = self.index + 1
        while cursor < self.length and self.source[cursor] in " \t":
            cursor += 1
        return cursor >= self.length or self.source[cursor] in "\n'"

    def _read_line_continuation(self) -> Token:
        token = self._single_char_token(TokenKind.LINE_CONTINUATION)
        return token

    def _match_operator(self) -> str | None:
        # Numeric literals prefixed with &H / &O must be detected before '&'.
        if self._peek() == "&" and self._peek(1).upper() in {"H", "O"}:
            return None
        for operator in OPERATORS:
            if self.source.startswith(operator, self.index):
                return operator
        return None

    def _consume_text(self, kind: TokenKind, text: str) -> Token:
        start_line, start_column = self.line, self.column
        self._advance(len(text))
        return Token(kind, text, start_line, start_column, self.column - 1)

    def _single_char_token(self, kind: TokenKind) -> Token:
        value = self._peek()
        start_line, start_column = self.line, self.column
        self._advance()
        return Token(kind, value, start_line, start_column, start_column)

    def _peek(self, offset: int = 0) -> str:
        position = self.index + offset
        return self.source[position] if position < self.length else "\0"

    def _advance(self, count: int = 1) -> None:
        for _ in range(count):
            if self.index >= self.length:
                return
            char = self.source[self.index]
            self.index += 1
            if char == "\n":
                self.line += 1
                self.column = 1
            else:
                self.column += 1

    def _next_is_word_boundary(self) -> bool:
        return not self._is_identifier_part(self._peek())

    @staticmethod
    def _is_identifier_start(char: str) -> bool:
        return char == "_" or char.isalpha()

    @staticmethod
    def _is_identifier_part(char: str) -> bool:
        return char == "_" or char.isalnum()


def tokenize(source: str) -> list[Token]:
    """Convenience function for tokenising an in-memory Basic source."""

    return BasicLexer(source).tokenize()


def tokenize_file(path: Path) -> list[Token]:
    """Read and tokenise a UTF-8 Basic source file.

    ``utf-8-sig`` accepts both plain UTF-8 and UTF-8 files carrying a BOM.
    Invalid bytes are rejected rather than silently changing the source.
    """

    return tokenize(path.read_text(encoding="utf-8-sig"))
