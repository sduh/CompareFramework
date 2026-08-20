"""Repository discovery and Basic module parsing."""

from __future__ import annotations
from pathlib import Path

from .model import Repository
from .parser import parse_module_file

def load_repository(repository_root: Path | None = None) -> Repository:
    root = (repository_root or Path(__file__).resolve().parents[2]).resolve()
    src_dir = root / "src"
    version_file = root / "VERSION"

    if not src_dir.is_dir():
        raise FileNotFoundError(f"Basic source directory not found: {src_dir}")
    if not version_file.is_file():
        raise FileNotFoundError(f"VERSION file not found: {version_file}")

    repo = Repository(version=version_file.read_text(encoding="utf-8-sig").strip())
    for source_file in sorted(src_dir.rglob("*.bas")):
        repo.modules.append(parse_module_file(source_file, src_dir))
    return repo
