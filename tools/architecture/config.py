from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path

SCHEMA_VERSION = "1.6.0"
REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SRC_DIR = REPOSITORY_ROOT / "src"
VERSION_FILE = REPOSITORY_ROOT / "VERSION"
DEFAULT_OUTPUT_DIR = REPOSITORY_ROOT / "build" / "architecture"

PUBLIC_API_MODULE = "CompareFramework_API"
PUBLIC_API_PROCEDURES = (
    "CF_StartReferenceComparison",
    "CF_RunStandardComparison",
    "CF_ExportLastReportHTML",
    "CF_OpenSettings",
    "CF_RunDiagnostics",
    "CF_RunReleaseValidation",
)

@dataclass(frozen=True)
class AnalyzerConfig:
    repository_root: Path
    output_dir: Path

    @classmethod
    def from_repository_root(cls, repository_root: Path) -> "AnalyzerConfig":
        root = repository_root.resolve()
        return cls(root, root / "build" / "architecture")
