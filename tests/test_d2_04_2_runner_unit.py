import json
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

from tools.ci.run_functional_scenarios import (
    RESULT_FIELDS,
    Scenario,
    ScenarioContractError,
    ScenarioMismatchError,
    compare_contracts,
    discover_scenarios,
    extract_actual,
    format_suite_summary,
    load_expected,
    write_json,
)

ROOT = Path(__file__).resolve().parents[1]


class FakeCell:
    def __init__(self, value=""):
        self.String = value


class FakeSheet:
    def __init__(self, rows):
        self.rows = rows

    def getCellByPosition(self, column, row):
        try:
            value = self.rows[row][column]
        except (IndexError, TypeError):
            value = ""
        return FakeCell(value)


class FakeSheets:
    def __init__(self, mapping):
        self.mapping = mapping

    def hasByName(self, name):
        return name in self.mapping

    def getByName(self, name):
        return self.mapping[name]


class FakeDocument:
    def __init__(self, mapping):
        self.Sheets = FakeSheets(mapping)


class D2042RunnerUnitTests(unittest.TestCase):
    def test_discovery_returns_exact_t001_to_t010(self):
        scenarios = discover_scenarios(ROOT / "tests" / "datasets")
        self.assertEqual(
            [f"T{i:03d}" for i in range(1, 11)],
            [scenario.scenario_id for scenario in scenarios],
        )

    def test_strict_contract_detects_any_field_difference(self):
        expected = {
            "scenario_id": "T001",
            "decision": "OK",
            "added_rows": 0,
            "deleted_rows": 0,
            "modified_rows": 0,
            "modified_cells": 0,
            "duplicate_ids": 0,
            "structure_alerts": 0,
        }
        actual = dict(expected, added_rows=1)
        with self.assertRaises(ScenarioMismatchError) as ctx:
            compare_contracts(expected, actual)
        self.assertIn("added_rows", str(ctx.exception))

    def test_load_expected_rejects_malformed_json(self):
        with TemporaryDirectory() as tmp:
            directory = Path(tmp)
            expected = directory / "expected.json"
            expected.write_text("{bad json", encoding="utf-8")
            scenario = Scenario(
                "T001",
                "broken",
                directory,
                directory / "MODELE.csv",
                directory / "TARGET.csv",
                expected,
            )
            with self.assertRaises(ScenarioContractError):
                load_expected(scenario)

    def test_load_expected_rejects_missing_field(self):
        with TemporaryDirectory() as tmp:
            directory = Path(tmp)
            expected = directory / "expected.json"
            payload = {
                "scenario_id": "T001",
                "decision": "OK",
                "added_rows": 0,
                "deleted_rows": 0,
                "modified_rows": 0,
                "modified_cells": 0,
                "duplicate_ids": 0,
            }
            expected.write_text(json.dumps(payload), encoding="utf-8")
            scenario = Scenario(
                "T001",
                "broken",
                directory,
                directory / "MODELE.csv",
                directory / "TARGET.csv",
                expected,
            )
            with self.assertRaises(ScenarioContractError):
                load_expected(scenario)

    def test_write_json_is_stable_and_complete(self):
        payload = {field: 0 for field in RESULT_FIELDS}
        payload["scenario_id"] = "T001"
        payload["decision"] = "OK"
        with TemporaryDirectory() as tmp:
            path = Path(tmp) / "result.json"
            write_json(path, payload)
            text = path.read_text(encoding="utf-8")
            self.assertTrue(text.endswith("\n"))
            self.assertEqual(payload, json.loads(text))

    def test_native_outputs_normalize_to_contract(self):
        stats_rows = [
            ["Resume global", "Valeur"],
            ["Lignes ajoutees", "1"],
            ["Lignes supprimees", "2"],
            ["Lignes modifiees", "3"],
            ["Cellules modifiees", "4"],
            ["ID doublons", "5"],
            ["Alertes structure", "6"],
        ]
        summary_rows = [
            ["Feuille cible", "", "", "", "", "", "", "Decision"],
            ["TOTAL", "1", "2", "3", "4", "5", "6", "A CONTROLER"],
        ]
        document = FakeDocument(
            {
                "Stats_Comparaison": FakeSheet(stats_rows),
                "Compare_Reference_Summary": FakeSheet(summary_rows),
            }
        )
        self.assertEqual(
            {
                "scenario_id": "T999",
                "decision": "A CONTROLER",
                "added_rows": 1,
                "deleted_rows": 2,
                "modified_rows": 3,
                "modified_cells": 4,
                "duplicate_ids": 5,
                "structure_alerts": 6,
            },
            extract_actual(document, "T999"),
        )

    def test_summary_reports_all_failures_without_fail_fast(self):
        lines, passed = format_suite_summary(
            [
                ("T001", True, ""),
                ("T002", False, "MISMATCH: x"),
                ("T003", False, "EXTRACTION: y"),
            ]
        )
        self.assertEqual(1, passed)
        self.assertEqual("T001 PASS", lines[0])
        self.assertIn("T002 FAIL", lines[1])
        self.assertIn("T003 FAIL", lines[2])
        self.assertEqual("1/3 PASS", lines[-1])


if __name__ == "__main__":
    unittest.main()
