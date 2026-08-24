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
    discover_setup_sheets,
    discover_scenarios,
    extract_actual,
    format_suite_summary,
    load_expected,
    parse_args,
    prepare_document,
    select_scenarios,
    write_json,
)

ROOT = Path(__file__).resolve().parents[1]


class FakeCell:
    def __init__(self, sheet, column, row):
        self.sheet = sheet
        self.column = column
        self.row = row

    @property
    def String(self):
        try:
            return self.sheet.rows[self.row][self.column]
        except IndexError:
            return ""

    @String.setter
    def String(self, value):
        while len(self.sheet.rows) <= self.row:
            self.sheet.rows.append([])
        while len(self.sheet.rows[self.row]) <= self.column:
            self.sheet.rows[self.row].append("")
        self.sheet.rows[self.row][self.column] = value


class FakeSheet:
    def __init__(self, rows, name=""):
        self.rows = rows
        self._name = name
        self._sheets = None

    @property
    def Name(self):
        return self._name

    @Name.setter
    def Name(self, value):
        if self._sheets is not None:
            del self._sheets.mapping[self._name]
            self._sheets.mapping[value] = self
        self._name = value

    def getCellByPosition(self, column, row):
        return FakeCell(self, column, row)


class FakeSheets:
    def __init__(self, mapping):
        self.mapping = mapping
        for name, sheet in mapping.items():
            sheet._name = name
            sheet._sheets = self

    def hasByName(self, name):
        return name in self.mapping

    def getByName(self, name):
        return self.mapping[name]

    def getElementNames(self):
        return tuple(self.mapping)

    def getCount(self):
        return len(self.mapping)

    def insertNewByName(self, name, _index):
        sheet = FakeSheet([], name)
        sheet._sheets = self
        self.mapping[name] = sheet

    def removeByName(self, name):
        del self.mapping[name]


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

    def test_scenario_filter_preserves_catalogue_order_and_is_generic(self):
        scenarios = discover_scenarios(ROOT / "tests" / "datasets")
        selected = select_scenarios(scenarios, ["T010", "T006", "T007"])
        self.assertEqual(
            ["T006", "T007", "T010"],
            [item.scenario_id for item in selected],
        )

    def test_scenario_filter_rejects_unknown_ids(self):
        scenarios = discover_scenarios(ROOT / "tests" / "datasets")
        with self.assertRaises(ScenarioContractError) as ctx:
            select_scenarios(scenarios, ["T999"])
        self.assertIn("T999", str(ctx.exception))

    def test_parse_args_accepts_repeatable_scenario_filter(self):
        args = parse_args(
            [
                "--soffice", "/opt/libreoffice7.4/program/soffice",
                "--monolith", "dist/current.bas",
                "--scenario", "T006",
                "--scenario", "T010",
            ]
        )
        self.assertEqual(["T006", "T010"], args.scenario)

    def test_setup_discovery_is_generic_and_sorted(self):
        with TemporaryDirectory() as tmp:
            directory = Path(tmp)
            setup = directory / "setup"
            setup.mkdir()
            second = setup / "Zeta.csv"
            first = setup / "Alpha.csv"
            second.write_text("Key,Value\nB,2\n", encoding="utf-8")
            first.write_text("Key,Value\nA,1\n", encoding="utf-8")
            self.assertEqual((first, second), discover_setup_sheets(directory))

    def test_prepare_document_materializes_arbitrary_setup_sheets(self):
        with TemporaryDirectory() as tmp:
            directory = Path(tmp)
            model = directory / "MODELE.csv"
            target = directory / "TARGET.csv"
            setup = directory / "setup"
            setup.mkdir()
            alpha = setup / "Alpha_Config.csv"
            model.write_text("ProductId,Value\nP001,model\n", encoding="utf-8")
            target.write_text("ProductId,Value\nP001,target\n", encoding="utf-8")
            alpha.write_text("Key,Value\nA,1\n", encoding="utf-8")
            scenario = Scenario(
                "T000", "setup", directory, model, target, directory / "expected.json",
                (alpha,),
            )
            document = FakeDocument({"Sheet1": FakeSheet([])})

            prepare_document(document, scenario)

            self.assertEqual(
                ("MODELE", "TARGET", "Alpha_Config"),
                document.Sheets.getElementNames(),
            )
            alpha_sheet = document.Sheets.getByName("Alpha_Config")
            self.assertEqual("Key", alpha_sheet.getCellByPosition(0, 0).String)
            self.assertEqual("1", alpha_sheet.getCellByPosition(1, 1).String)

    def test_prepare_document_rejects_reserved_setup_sheet_names(self):
        with TemporaryDirectory() as tmp:
            directory = Path(tmp)
            model = directory / "MODELE.csv"
            target = directory / "TARGET.csv"
            setup = directory / "setup"
            setup.mkdir()
            model.write_text("ProductId\nP001\n", encoding="utf-8")
            target.write_text("ProductId\nP001\n", encoding="utf-8")
            for reserved_name in ("MODELE", "target"):
                reserved = setup / f"{reserved_name}.csv"
                reserved.write_text("ProductId\nP999\n", encoding="utf-8")
                scenario = Scenario(
                    "T000", "reserved", directory, model, target,
                    directory / "expected.json", (reserved,),
                )
                document = FakeDocument({"Sheet1": FakeSheet([])})

                with self.assertRaises(ScenarioContractError):
                    prepare_document(document, scenario)

                self.assertEqual(("Sheet1",), document.Sheets.getElementNames())

    def test_t010_setup_fixtures_materialize_exact_document_local_sheets(self):
        """Omitting T010's setup CSVs must not silently use default comparators."""
        scenario = next(
            item
            for item in discover_scenarios(ROOT / "tests" / "datasets")
            if item.scenario_id == "T010"
        )
        self.assertEqual(
            ("Compare_Comparators", "Compare_Config"),
            tuple(path.stem for path in scenario.setup_sheets),
        )

        document = FakeDocument({"Sheet1": FakeSheet([])})
        prepare_document(document, scenario)

        self.assertEqual(
            ("MODELE", "TARGET", "Compare_Comparators", "Compare_Config"),
            document.Sheets.getElementNames(),
        )
        self.assertEqual(
            [
                ["Enabled", "Profile", "Column", "Comparator", "Tolerance", "Comment"],
                ["TRUE", "GLOBAL", "Amount", "CURRENCY", "0", "Exact currency equivalence"],
                ["TRUE", "GLOBAL", "Rate", "PERCENT", "0", "Exact percent equivalence"],
                ["TRUE", "GLOBAL", "Enabled", "BOOLEAN", "", "Boolean vocabulary equivalence"],
                ["TRUE", "GLOBAL", "Date", "DATE", "0", "Exact date equivalence"],
            ],
            document.Sheets.getByName("Compare_Comparators").rows,
        )
        self.assertEqual(
            [
                ["Parametre", "Valeur", "Description"],
                ["IGNORE_CASE", "TRUE", "Ignore case for typed equivalence scenario"],
            ],
            document.Sheets.getByName("Compare_Config").rows,
        )

        unrelated_document = FakeDocument({"Sheet1": FakeSheet([])})
        prepare_document(
            unrelated_document,
            Scenario(
                "T000",
                "no-setup",
                scenario.directory,
                scenario.model_csv,
                scenario.target_csv,
                scenario.expected_json,
            ),
        )
        self.assertEqual(
            ("MODELE", "TARGET"),
            unrelated_document.Sheets.getElementNames(),
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
