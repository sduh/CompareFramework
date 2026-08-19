"""Repository discovery and Basic module parsing."""

from __future__ import annotations

from .config import SRC_DIR, VERSION_FILE
from .model import Repository
from .parser import parse_module_file


def load_repository() -> Repository:
    repo = Repository()
    if VERSION_FILE.exists():
        repo.version = VERSION_FILE.read_text(encoding="utf-8-sig").strip()
    for source_file in sorted(SRC_DIR.rglob("*.bas")):
        repo.modules.append(parse_module_file(source_file, SRC_DIR))
    return repo
