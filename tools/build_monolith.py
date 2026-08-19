#!/usr/bin/env python3
"""Build the CompareFramework LibreOffice Basic monolith from modular sources."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path


OPTION_EXPLICIT_RE = re.compile(r"^\s*Option\s+Explicit\s*$", re.IGNORECASE | re.MULTILINE)
OPTIONAL_DEFAULT_RE = re.compile(
    r"Optional\s+\w+\s+As\s+\w+\s*=",
    re.IGNORECASE,
)
ROUND_RE = re.compile(r"(?<![A-Za-z0-9_])Round\s*\(", re.IGNORECASE)
PUBLIC_SYMBOL_RE = re.compile(
    r"^\s*Public\s+(?:Sub|Function)\s+([A-Za-z_][A-Za-z0-9_]*)",
    re.IGNORECASE | re.MULTILINE,
)
VERSION_TOKEN = "@COMPAREFRAMEWORK_VERSION@"
VERSION_RE = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?$")



def read_version(root: Path) -> str:
    version_path = root / "VERSION"
    if not version_path.is_file():
        raise FileNotFoundError("Fichier VERSION absent.")
    version = version_path.read_text(encoding="utf-8").strip()
    if not VERSION_RE.fullmatch(version):
        raise ValueError(f"Version invalide dans VERSION: {version!r}")
    return version


def inject_version(text: str, version: str) -> str:
    return text.replace(VERSION_TOKEN, version)


def read_order(root: Path, order_file: Path) -> list[Path]:
    entries: list[Path] = []
    for raw_line in order_file.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        path = root / line
        if not path.is_file():
            raise FileNotFoundError(f"Module absent: {line}")
        entries.append(path)
    if not entries:
        raise ValueError("MODULE_ORDER.txt ne contient aucun module.")
    return entries


def strip_option_explicit(text: str) -> str:
    return OPTION_EXPLICIT_RE.sub("", text).strip()


def find_duplicate_public_symbols(parts: list[tuple[Path, str]]) -> dict[str, list[str]]:
    locations: dict[str, list[str]] = {}
    for path, text in parts:
        for match in PUBLIC_SYMBOL_RE.finditer(text):
            key = match.group(1).lower()
            locations.setdefault(key, []).append(path.as_posix())
    return {name: files for name, files in locations.items() if len(files) > 1}



def strip_basic_comments_and_strings(text: str) -> str:
    """Remove Basic comments and string contents while preserving line breaks."""
    output: list[str] = []

    for line in text.splitlines(keepends=True):
        cleaned: list[str] = []
        in_string = False
        i = 0

        while i < len(line):
            char = line[i]

            if in_string:
                if char == '"':
                    if i + 1 < len(line) and line[i + 1] == '"':
                        cleaned.extend((" ", " "))
                        i += 2
                        continue
                    in_string = False
                    cleaned.append(" ")
                else:
                    cleaned.append("\n" if char == "\n" else " ")
                i += 1
                continue

            if char == '"':
                in_string = True
                cleaned.append(" ")
                i += 1
                continue

            if char == "'":
                while i < len(line) and line[i] != "\n":
                    cleaned.append(" ")
                    i += 1
                continue

            cleaned.append(char)
            i += 1

        output.append("".join(cleaned))

    return "".join(output)


def find_forbidden_round_calls(text: str) -> list[dict[str, object]]:
    executable_text = strip_basic_comments_and_strings(text)
    findings: list[dict[str, object]] = []
    original_lines = text.splitlines()

    for match in ROUND_RE.finditer(executable_text):
        line_number = executable_text.count("\n", 0, match.start()) + 1
        original_line = original_lines[line_number - 1].strip()
        findings.append({"line": line_number, "source": original_line})

    return findings

def validate(parts: list[tuple[Path, str]], monolith: str) -> dict[str, object]:
    duplicate_symbols = find_duplicate_public_symbols(parts)
    forbidden_round_calls = find_forbidden_round_calls(monolith)
    single_option_explicit = monolith.lower().count("option explicit") == 1
    optional_defaults_absent = not bool(OPTIONAL_DEFAULT_RE.search(monolith))
    round_calls_absent = not forbidden_round_calls

    return {
        "module_count": len(parts),
        "single_option_explicit": single_option_explicit,
        "optional_default_syntax_absent": optional_defaults_absent,
        "round_calls_absent": round_calls_absent,
        "forbidden_round_calls": forbidden_round_calls,
        "duplicate_public_symbols": duplicate_symbols,
        "all_checks_passed": (
            single_option_explicit
            and optional_defaults_absent
            and round_calls_absent
            and not duplicate_symbols
        ),
    }


def build(root: Path, order_path: Path, output_path: Path, manifest_path: Path) -> None:
    version = read_version(root)
    module_paths = read_order(root, order_path)
    parts: list[tuple[Path, str]] = []

    for path in module_paths:
        text = path.read_text(encoding="utf-8-sig", errors="strict")
        parts.append((path.relative_to(root), inject_version(text, version)))

    output_parts = [
        "Option Explicit",
        "",
        "' Generated file. Do not edit directly.",
        "' Source of truth: src/, MODULE_ORDER.txt and VERSION",
        f"' Version: {version}",
        "",
    ]

    for relative_path, text in parts:
        output_parts.extend(
            [
                "'" + "=" * 72,
                f"' MODULE: {relative_path.as_posix()}",
                "'" + "=" * 72,
                strip_option_explicit(text),
                "",
            ]
        )

    monolith = "\n".join(output_parts).rstrip() + "\n"
    checks = validate(parts, monolith)

    if not checks["all_checks_passed"]:
        raise RuntimeError(
            "Le build a échoué aux contrôles statiques:\n"
            + json.dumps(checks, indent=2, ensure_ascii=False)
        )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(monolith, encoding="utf-8")

    manifest = {
        "name": "CompareFramework",
        "version": version,
        "version_source": "VERSION",
        "output": output_path.relative_to(root).as_posix(),
        "sha256": hashlib.sha256(output_path.read_bytes()).hexdigest(),
        "modules": [p.as_posix() for p, _ in parts],
        "checks": checks,
    }
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Racine du dépôt.",
    )
    parser.add_argument(
        "--order",
        type=Path,
        default=None,
        help="Fichier d'ordre des modules.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=None,
        help="Monolithe généré.",
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        default=None,
        help="Manifeste de build.",
    )
    args = parser.parse_args()

    root = args.root.resolve()
    order = args.order or root / "MODULE_ORDER.txt"
    version = read_version(root)
    output = args.output or root / "dist" / f"CompareFramework-{version}.bas"
    manifest = args.manifest or root / "dist" / "BUILD_MANIFEST.json"

    build(root, order, output, manifest)
    print(output)
    print(manifest)


if __name__ == "__main__":
    main()
