from pathlib import Path

import pytest

from tools.architecture.lexer import BasicLexer, LexerError, tokenize, tokenize_file
from tools.architecture.tokens import TokenKind


def compact(source: str):
    return [(token.kind, token.value) for token in tokenize(source)]


def test_tokenizes_procedure_declaration_and_positions():
    tokens = tokenize("Public Function CF_ContextGet(ByVal key As String) As String\nEnd Function\n")

    assert [token.kind for token in tokens[:4]] == [
        TokenKind.KEYWORD,
        TokenKind.KEYWORD,
        TokenKind.IDENTIFIER,
        TokenKind.SEPARATOR,
    ]
    assert tokens[0].value == "Public"
    assert tokens[0].line == 1
    assert tokens[0].column == 1
    assert tokens[2].value == "CF_ContextGet"
    assert tokens[2].column == 17
    assert tokens[-1].kind is TokenKind.EOF


def test_strings_keep_basic_double_quote_escape():
    tokens = compact('message = "A ""quoted"" value"\n')
    assert (TokenKind.STRING, '"A ""quoted"" value"') in tokens


def test_apostrophe_and_rem_comments_are_preserved():
    tokens = compact("' header\nRem legacy comment\nx = 1 ' tail\n")
    comments = [value for kind, value in tokens if kind is TokenKind.COMMENT]
    assert comments == ["' header", "Rem legacy comment", "' tail"]


def test_line_continuation_is_explicit_token():
    tokens = compact("value = first _\n    + second\n")
    assert (TokenKind.LINE_CONTINUATION, "_") in tokens


def test_numbers_dates_operators_and_type_suffixes():
    tokens = compact("Dim total# As Double: total# = 1.25E+2 + #2026-07-20#\n")
    assert (TokenKind.IDENTIFIER, "total#") in tokens
    assert (TokenKind.NUMBER, "1.25E+2") in tokens
    assert (TokenKind.DATE, "#2026-07-20#") in tokens
    assert (TokenKind.OPERATOR, "+") in tokens


def test_unterminated_string_is_reported_with_location():
    with pytest.raises(LexerError, match=r"line 1, column 5"):
        tokenize('x = "broken\n')


def test_every_repository_basic_module_is_lexable():
    root = Path(__file__).resolve().parents[1]
    source_files = sorted((root / "src").rglob("*.bas"))
    assert source_files, "No Basic source file discovered"

    for source_file in source_files:
        tokens = tokenize_file(source_file)
        assert tokens[-1].kind is TokenKind.EOF
        assert any(token.kind is TokenKind.NEWLINE for token in tokens)
