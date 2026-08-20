from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path

SCHEMA_VERSION = "1.1.0"
REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SRC_DIR = REPOSITORY_ROOT / "src"
VERSION_FILE = REPOSITORY_ROOT / "VERSION"
DEFAULT_OUTPUT_DIR = REPOSITORY_ROOT / "build" / "architecture"

@dataclass(frozen=True)
class AnalyzerConfig:
    repository_root: Path
    output_dir: Path

    @classmethod
    def from_repository_root(cls, repository_root: Path) -> "AnalyzerConfig":
        root = repository_root.resolve()
        return cls(root, root / "build" / "architecture")
