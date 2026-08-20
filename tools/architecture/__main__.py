from __future__ import annotations
import argparse
import json
import sys
from pathlib import Path

from .engine import build_architecture
from .validation import ArchitectureValidationError

EXIT_OK = 0
EXIT_ANALYSIS_ERROR = 3

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="python -m tools.architecture",
        description="Analyze CompareFramework LibreOffice Basic sources.",
    )
    parser.add_argument("--root", type=Path, default=Path.cwd(),
                        help="Repository root (default: current directory).")
    parser.add_argument("--summary", action="store_true",
                        help="Print statistics JSON instead of the output path.")
    return parser

def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        document = build_architecture(args.root)
    except (OSError, ValueError, ArchitectureValidationError) as exc:
        print(f"architecture analysis failed: {exc}", file=sys.stderr)
        return EXIT_ANALYSIS_ERROR

    if args.summary:
        print(json.dumps(document["statistics"], indent=2, ensure_ascii=False))
    else:
        print(args.root.resolve() / "build" / "architecture" / "architecture.json")
    return EXIT_OK

if __name__ == "__main__":
    raise SystemExit(main())
