from __future__ import annotations

import argparse
import csv
import json
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

from tools.ci.run_libreoffice_basic_smoke import (
    BasicInjectionError,
    MacroInvocationError,
    RuntimeContractError,
    UnoConnectionError,
    choose_local_port,
    connect_uno,
    file_url,
    inject_monolith,
    invoke_macro,
    validate_version_output,
)

SCENARIO_CATALOG = (
    ("T001", "identical"),
    ("T002", "additions"),
    ("T003", "deletions"),
    ("T004", "modifications"),
    ("T005", "combined_changes"),
    ("T006", "duplicates"),
    ("T007", "missing_key_column"),
    ("T008", "extra_column"),
    ("T009", "reordered_columns"),
    ("T010", "typed_values"),
)
RESULT_FIELDS = (
    "scenario_id",
    "decision",
    "added_rows",
    "deleted_rows",
    "modified_rows",
    "modified_cells",
    "duplicate_ids",
    "structure_alerts",
)
VALID_DECISIONS = {"OK", "ECARTS", "A CONTROLER"}
MACRO_NAME = "CF_CI_RunScenario"
STATS_SHEET = "Stats_Comparaison"
SUMMARY_SHEET = "Compare_Reference_Summary"
STATS_LABELS = {
    "Lignes ajoutees": "added_rows",
    "Lignes supprimees": "deleted_rows",
    "Lignes modifiees": "modified_rows",
    "Cellules modifiees": "modified_cells",
    "ID doublons": "duplicate_ids",
    "Alertes structure": "structure_alerts",
}


class ScenarioError(RuntimeError):
    category = "RUNTIME"


class ScenarioContractError(ScenarioError):
    category = "CONTRACT"


class ScenarioRuntimeError(ScenarioError):
    category = "RUNTIME"


class ScenarioUnoError(ScenarioError):
    category = "UNO"


class ScenarioInjectionError(ScenarioError):
    category = "INJECTION"


class ScenarioMacroError(ScenarioError):
    category = "MACRO"


class ScenarioExtractionError(ScenarioError):
    category = "EXTRACTION"


class ScenarioMismatchError(ScenarioContractError):
    category = "MISMATCH"


class ScenarioTimeoutError(ScenarioError):
    category = "TIMEOUT"


class ScenarioCleanupError(ScenarioError):
    category = "CLEANUP"


@dataclass(frozen=True)
class Scenario:
    scenario_id: str
    name: str
    directory: Path
    model_csv: Path
    target_csv: Path
    expected_json: Path


def discover_scenarios(datasets: Path) -> list[Scenario]:
    scenarios: list[Scenario] = []
    for scenario_id, name in SCENARIO_CATALOG:
        directory = datasets / name
        model_csv = directory / "MODELE.csv"
        target_csv = directory / "TARGET.csv"
        expected_json = directory / "expected.json"
        required = (directory, model_csv, target_csv, expected_json)
        missing = [str(path) for path in required if not path.exists()]
        if missing:
            raise ScenarioContractError(
                f"{scenario_id}: required scenario input missing: {', '.join(missing)}"
            )
        scenarios.append(
            Scenario(
                scenario_id=scenario_id,
                name=name,
                directory=directory,
                model_csv=model_csv,
                target_csv=target_csv,
                expected_json=expected_json,
            )
        )
    return scenarios


def validate_contract(payload: object, scenario_id: str) -> dict[str, object]:
    if not isinstance(payload, dict):
        raise ScenarioContractError(f"{scenario_id}: contract must be a JSON object")
    fields = set(payload)
    expected_fields = set(RESULT_FIELDS)
    if fields != expected_fields:
        missing = sorted(expected_fields - fields)
        extra = sorted(fields - expected_fields)
        raise ScenarioContractError(
            f"{scenario_id}: invalid contract fields; missing={missing}, extra={extra}"
        )
    if payload["scenario_id"] != scenario_id:
        raise ScenarioContractError(
            f"{scenario_id}: scenario_id mismatch: {payload['scenario_id']!r}"
        )
    if payload["decision"] not in VALID_DECISIONS:
        raise ScenarioContractError(
            f"{scenario_id}: invalid decision: {payload['decision']!r}"
        )
    for field in RESULT_FIELDS[2:]:
        value = payload[field]
        if isinstance(value, bool) or not isinstance(value, int) or value < 0:
            raise ScenarioContractError(
                f"{scenario_id}: {field} must be a non-negative integer, got {value!r}"
            )
    return {field: payload[field] for field in RESULT_FIELDS}


def load_expected(scenario: Scenario) -> dict[str, object]:
    try:
        payload = json.loads(scenario.expected_json.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ScenarioContractError(
            f"{scenario.scenario_id}: cannot load expected.json: {exc}"
        ) from exc
    return validate_contract(payload, scenario.scenario_id)


def compare_contracts(expected: dict[str, object], actual: dict[str, object]) -> None:
    scenario_id = str(expected.get("scenario_id", actual.get("scenario_id", "UNKNOWN")))
    validate_contract(expected, scenario_id)
    validate_contract(actual, scenario_id)
    differences = [
        field
        for field in RESULT_FIELDS
        if expected.get(field) != actual.get(field)
    ]
    if differences:
        details = ", ".join(
            f"{field}: expected={expected[field]!r} actual={actual[field]!r}"
            for field in differences
        )
        raise ScenarioMismatchError(f"{scenario_id}: contract mismatch: {details}")


def write_json(path: Path, payload: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def _cell_string(sheet, column: int, row: int) -> str:
    return str(sheet.getCellByPosition(column, row).String).strip()


def find_label_value(sheet, label: str, max_rows: int = 512) -> str:
    for row in range(max_rows):
        if _cell_string(sheet, 0, row) == label:
            return _cell_string(sheet, 1, row)
    raise ScenarioExtractionError(f"native stats label missing: {label}")


def extract_decision(summary_sheet, max_rows: int = 512) -> str:
    for row in range(max_rows):
        if _cell_string(summary_sheet, 0, row) == "TOTAL":
            decision = _cell_string(summary_sheet, 7, row)
            if decision not in VALID_DECISIONS:
                raise ScenarioExtractionError(
                    f"invalid native TOTAL decision: {decision!r}"
                )
            return decision
    raise ScenarioExtractionError("native summary TOTAL row missing")


def _parse_native_count(label: str, value: str) -> int:
    try:
        parsed = int(value)
    except ValueError as exc:
        raise ScenarioExtractionError(
            f"native count for {label!r} is not an integer: {value!r}"
        ) from exc
    if parsed < 0:
        raise ScenarioExtractionError(
            f"native count for {label!r} is negative: {parsed}"
        )
    return parsed


def extract_actual(document, scenario_id: str) -> dict[str, object]:
    try:
        sheets = document.Sheets
        if not sheets.hasByName(STATS_SHEET):
            raise ScenarioExtractionError(f"native output sheet missing: {STATS_SHEET}")
        if not sheets.hasByName(SUMMARY_SHEET):
            raise ScenarioExtractionError(f"native output sheet missing: {SUMMARY_SHEET}")
        stats = sheets.getByName(STATS_SHEET)
        summary = sheets.getByName(SUMMARY_SHEET)
    except ScenarioExtractionError:
        raise
    except Exception as exc:
        raise ScenarioExtractionError(f"native sheet access failed: {exc}") from exc

    actual: dict[str, object] = {
        "scenario_id": scenario_id,
        "decision": extract_decision(summary),
    }
    for label, field in STATS_LABELS.items():
        actual[field] = _parse_native_count(label, find_label_value(stats, label))
    return validate_contract(actual, scenario_id)


def read_csv_tokens(path: Path) -> list[list[str]]:
    try:
        with path.open("r", encoding="utf-8-sig", newline="") as handle:
            return [list(row) for row in csv.reader(handle)]
    except (OSError, csv.Error) as exc:
        raise ScenarioContractError(f"cannot read CSV {path}: {exc}") from exc


def write_tokens_to_sheet(sheet, rows: list[list[str]]) -> None:
    for row_index, row in enumerate(rows):
        for column_index, value in enumerate(row):
            sheet.getCellByPosition(column_index, row_index).String = value


def create_calc_document(remote_ctx):
    try:
        desktop = remote_ctx.ServiceManager.createInstanceWithContext(
            "com.sun.star.frame.Desktop", remote_ctx
        )
        document = desktop.loadComponentFromURL("private:factory/scalc", "_blank", 0, ())
    except Exception as exc:
        raise ScenarioUnoError(f"Calc document creation failed: {exc}") from exc
    if document is None:
        raise ScenarioUnoError("Calc document creation returned no document")
    return desktop, document


def prepare_document(document, scenario: Scenario) -> None:
    try:
        sheets = document.Sheets
        names = sheets.getElementNames()
        if not names:
            raise ScenarioUnoError("new Calc document contains no sheet")
        first = sheets.getByName(names[0])
        first.Name = "MODELE"
        if sheets.hasByName("TARGET"):
            sheets.removeByName("TARGET")
        sheets.insertNewByName("TARGET", sheets.getCount())
        target = sheets.getByName("TARGET")
        write_tokens_to_sheet(first, read_csv_tokens(scenario.model_csv))
        write_tokens_to_sheet(target, read_csv_tokens(scenario.target_csv))
    except ScenarioError:
        raise
    except Exception as exc:
        raise ScenarioUnoError(f"scenario document preparation failed: {exc}") from exc


def save_document(document, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        import uno

        prop = uno.createUnoStruct("com.sun.star.beans.PropertyValue")
        prop.Name = "FilterName"
        prop.Value = "calc8"
        url = file_url(destination)
        try:
            document.storeAsURL(url, (prop,))
        except Exception:
            document.storeToURL(url, (prop,))
    except Exception as exc:
        raise ScenarioUnoError(f"cannot persist scenario document {destination}: {exc}") from exc


def _start_libreoffice(soffice: str, profile: Path, port: int):
    accept = (
        f"--accept=socket,host=127.0.0.1,port={port};urp;"
        "StarOffice.ServiceManager"
    )
    command = [
        soffice,
        "--headless",
        "--nologo",
        "--nodefault",
        "--nofirststartwizard",
        f"-env:UserInstallation={file_url(profile)}",
        accept,
    ]
    try:
        return subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    except OSError as exc:
        raise ScenarioRuntimeError(f"LibreOffice startup failed: {exc}") from exc


def _cleanup_runtime(document, desktop, process) -> list[str]:
    errors: list[str] = []
    if document is not None:
        try:
            document.close(True)
        except Exception:
            try:
                document.dispose()
            except Exception as exc:
                errors.append(f"document cleanup: {exc}")
    if desktop is not None:
        try:
            desktop.terminate()
        except Exception as exc:
            errors.append(f"desktop cleanup: {exc}")
    if process is not None:
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired as exc:
                    errors.append(f"process cleanup: {exc}")
    return errors


def run_scenario(
    scenario: Scenario,
    soffice: str,
    monolith: Path,
    artifacts: Path,
    timeout: int,
) -> dict[str, object]:
    scenario_artifacts = artifacts / scenario.scenario_id
    scenario_artifacts.mkdir(parents=True, exist_ok=True)
    shutil.copy2(scenario.expected_json, scenario_artifacts / "expected.json")
    document_path = scenario_artifacts / "scenario.ods"
    port = choose_local_port()
    process = None
    document = None
    desktop = None
    pending_error: Exception | None = None

    try:
        with tempfile.TemporaryDirectory(prefix=f"compareframework-{scenario.scenario_id.lower()}-") as tmp:
            profile = Path(tmp) / "profile"
            profile.mkdir()
            process = _start_libreoffice(soffice, profile, port)
            try:
                remote_ctx = connect_uno(port, timeout)
            except UnoConnectionError as exc:
                raise ScenarioUnoError(str(exc)) from exc
            desktop, document = create_calc_document(remote_ctx)
            prepare_document(document, scenario)
            save_document(document, document_path)
            try:
                inject_monolith(document, monolith)
            except BasicInjectionError as exc:
                raise ScenarioInjectionError(str(exc)) from exc
            try:
                invoke_macro(document, MACRO_NAME)
            except MacroInvocationError as exc:
                raise ScenarioMacroError(str(exc)) from exc
            actual = extract_actual(document, scenario.scenario_id)
            write_json(scenario_artifacts / "actual.json", actual)
            save_document(document, document_path)
            return actual
    except subprocess.TimeoutExpired as exc:
        pending_error = ScenarioTimeoutError(str(exc))
        raise pending_error from exc
    except ScenarioError as exc:
        pending_error = exc
        raise
    except Exception as exc:
        pending_error = ScenarioRuntimeError(str(exc))
        raise pending_error from exc
    finally:
        cleanup_errors = _cleanup_runtime(document, desktop, process)
        if cleanup_errors:
            message = "; ".join(cleanup_errors)
            if pending_error is None:
                raise ScenarioCleanupError(message)
            diagnostic = scenario_artifacts / "cleanup.txt"
            diagnostic.write_text(message + "\n", encoding="utf-8")


def format_suite_summary(results: list[tuple[str, bool, str]]) -> tuple[list[str], int]:
    lines: list[str] = []
    passed = 0
    for scenario_id, success, detail in results:
        if success:
            passed += 1
            lines.append(f"{scenario_id} PASS")
        else:
            lines.append(f"{scenario_id} FAIL: {detail}")
    lines.append(f"{passed}/{len(results)} PASS")
    return lines, passed


def classify_error(exc: BaseException) -> str:
    if isinstance(exc, ScenarioError):
        return exc.category
    if isinstance(exc, RuntimeContractError):
        return "RUNTIME"
    if isinstance(exc, subprocess.TimeoutExpired):
        return "TIMEOUT"
    return "RUNTIME"


def validate_runtime(soffice: str) -> str:
    try:
        completed = subprocess.run(
            [soffice, "--version"],
            check=True,
            capture_output=True,
            text=True,
            timeout=15,
        )
        validate_version_output(completed.stdout)
        return completed.stdout.strip()
    except RuntimeContractError:
        raise
    except (OSError, subprocess.SubprocessError) as exc:
        raise ScenarioRuntimeError(f"LibreOffice version check failed: {exc}") from exc


def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="Run CompareFramework T001-T010 functional scenarios through UNO"
    )
    parser.add_argument("--soffice", required=True)
    parser.add_argument("--monolith", type=Path, required=True)
    parser.add_argument("--datasets", type=Path, default=Path("tests/datasets"))
    parser.add_argument("--artifacts", type=Path, default=Path("build/d2-04-2"))
    parser.add_argument("--timeout", type=int, default=60)
    return parser.parse_args(argv)


def main(argv=None) -> int:
    args = parse_args(argv)
    try:
        if not args.monolith.is_file() or args.monolith.stat().st_size == 0:
            raise ScenarioContractError(f"monolith missing or empty: {args.monolith}")
        source = args.monolith.read_text(encoding="utf-8-sig")
        if MACRO_NAME not in source:
            raise ScenarioContractError(
                f"technical macro {MACRO_NAME!r} not present in {args.monolith}"
            )
        scenarios = discover_scenarios(args.datasets)
        version = validate_runtime(args.soffice)
        print(f"[runtime] {version}")
    except Exception as exc:
        print(f"D2-04.2 FAIL: {classify_error(exc)}: {exc}", file=sys.stderr)
        return 2

    args.artifacts.mkdir(parents=True, exist_ok=True)
    results: list[tuple[str, bool, str]] = []
    for scenario in scenarios:
        try:
            expected = load_expected(scenario)
            actual = run_scenario(
                scenario=scenario,
                soffice=args.soffice,
                monolith=args.monolith,
                artifacts=args.artifacts,
                timeout=args.timeout,
            )
            compare_contracts(expected, actual)
            results.append((scenario.scenario_id, True, ""))
        except Exception as exc:
            category = classify_error(exc)
            detail = f"{category}: {exc}"
            scenario_artifacts = args.artifacts / scenario.scenario_id
            scenario_artifacts.mkdir(parents=True, exist_ok=True)
            (scenario_artifacts / "diagnostic.txt").write_text(
                detail + "\n", encoding="utf-8"
            )
            results.append((scenario.scenario_id, False, detail))

    lines, passed = format_suite_summary(results)
    for line in lines:
        print(line)
    return 0 if passed == len(scenarios) == 10 else 1


if __name__ == "__main__":
    raise SystemExit(main())
