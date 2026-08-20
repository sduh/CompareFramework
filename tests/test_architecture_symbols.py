import csv
import json
from pathlib import Path

from tools.architecture.engine import run
from tools.architecture.repository import load_repository
from tools.architecture.symbols import build_symbol_table


def test_symbol_table_contains_supported_public_api():
    repository = load_repository()
    symbols = build_symbol_table(repository)
    procedure_names = {
        symbol.name
        for symbol in symbols
        if symbol.kind == "procedure" and symbol.module == "CompareFramework_API"
    }
    assert {
        "CF_StartReferenceComparison",
        "CF_RunStandardComparison",
        "CF_ExportLastReportHTML",
        "CF_OpenSettings",
        "CF_RunDiagnostics",
        "CF_RunReleaseValidation",
    }.issubset(procedure_names)


def test_engine_generates_all_a1_exports_consistently():
    data = run()
    root = Path(__file__).resolve().parents[1]
    build = root / "build" / "architecture"

    expected = {
        "architecture.json",
        "modules.csv",
        "procedures.csv",
        "symbol_index.csv",
        "statistics.json",
    }
    assert expected.issubset({path.name for path in build.iterdir()})

    architecture = json.loads((build / "architecture.json").read_text(encoding="utf-8"))
    statistics = json.loads((build / "statistics.json").read_text(encoding="utf-8"))
    assert architecture == data
    assert statistics == data["statistics"]
    assert architecture["schema_version"] == "1.0.0"
    assert architecture["languages"][0]["name"] == "LibreOffice Basic"

    with (build / "procedures.csv").open(encoding="utf-8", newline="") as handle:
        procedures = list(csv.DictReader(handle))
    with (build / "symbol_index.csv").open(encoding="utf-8", newline="") as handle:
        symbols = list(csv.DictReader(handle))

    assert len(procedures) == data["statistics"]["procedure_count"]
    assert len(symbols) == data["statistics"]["symbol_count"]
    assert any(row["qualified_name"] == "CompareFramework_API.CF_RunDiagnostics" for row in symbols)


def test_exports_are_deterministic_for_same_repository():
    root = Path(__file__).resolve().parents[1]
    build = root / "build" / "architecture"
    run()
    first = {path.name: path.read_bytes() for path in build.iterdir() if path.is_file()}
    run()
    second = {path.name: path.read_bytes() for path in build.iterdir() if path.is_file()}
    assert first == second
