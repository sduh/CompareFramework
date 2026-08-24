import os
import csv
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory
from zipfile import ZipFile
from xml.etree import ElementTree as ET

from tools.ci.run_functional_scenarios import Scenario, discover_scenarios, run_scenario


ROOT = Path(__file__).resolve().parents[1]


class D2042TypedRuntimeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.soffice = os.environ["SOFFICE_BIN"]
        cls.monolith = Path(os.environ["CF_MONOLITH"])

    def test_t010_canonical_typed_values_are_equal_with_explicit_rules(self):
        """Locale-sensitive parsing must not turn T010's canonical values into changes."""
        scenario = next(
            item
            for item in discover_scenarios(ROOT / "tests" / "datasets")
            if item.scenario_id == "T010"
        )
        with TemporaryDirectory() as tmp:
            actual = run_scenario(
                scenario,
                self.soffice,
                self.monolith,
                Path(tmp) / "artifacts",
                60,
            )

        self.assertEqual(
            {
                "scenario_id": "T010",
                "decision": "OK",
                "added_rows": 0,
                "deleted_rows": 0,
                "modified_rows": 0,
                "modified_cells": 0,
                "duplicate_ids": 0,
                "structure_alerts": 0,
            },
            actual,
        )

    def test_native_typed_parser_uses_explicit_rules_and_rejects_malformed_canonical_values(self):
        """A permissive parser must not equate malformed separators or invalid dates."""
        headers = [
            "ProductId", "Amount", "Rate", "Enabled", "Date", "BadComma",
            "BadMixed", "BadMarker", "Legacy", "PrefixCurrency",
            "ScientificDecimal", "HugeScientific", "InvalidIso", "InvalidSlash",
        ]
        model_rows = [
            headers,
            [
                "P001", "-10.50 €", "10%", "TRUE", "2026-02-28", "12.3",
                "123.4", "0.1", "1000", "10.5", "1000", "0",
                "2026-02-28", "28/02/2026",
            ],
            [
                "P002", "11", "20%", "TRUE", "2026-07-01", "0", "0",
                "0", "1000", "0", "0", "0", "2026-01-01", "01/01/2026",
            ],
        ]
        target_rows = [
            headers,
            [
                "P001", "-10,50", "0.1", "Oui", "28/02/2026", "1,2,3",
                "1.2.3,4", "10%%", "1E3%", "$10.50", "1.0E3%",
                "0E999999999%", "2026-02-30", "31/02/2026",
            ],
            [
                "P002", "10", "0.1", "FALSE", "02/07/2026", "0", "0",
                "0", "1E3%", "0", "0", "0", "2026-01-01", "01/01/2026",
            ],
        ]
        rules = [
            ["Enabled", "Profile", "Column", "Comparator", "Tolerance", "Comment"],
            ["TRUE", "GLOBAL", "Amount", "CURRENCY", "0", "native test"],
            ["TRUE", "GLOBAL", "Rate", "PERCENT", "0", "native test"],
            ["TRUE", "GLOBAL", "Enabled", "BOOLEAN", "", "native test"],
            ["TRUE", "GLOBAL", "Date", "DATE", "0", "native test"],
            ["TRUE", "GLOBAL", "BadComma", "CURRENCY", "0", "native test"],
            ["TRUE", "GLOBAL", "BadMixed", "CURRENCY", "0", "native test"],
            ["TRUE", "GLOBAL", "BadMarker", "PERCENT", "0", "native test"],
            ["TRUE", "GLOBAL", "Legacy", "CURRENCY", "0", "native test"],
            ["TRUE", "GLOBAL", "PrefixCurrency", "CURRENCY", "0", "native test"],
            ["TRUE", "GLOBAL", "ScientificDecimal", "CURRENCY", "0", "native test"],
            ["TRUE", "GLOBAL", "HugeScientific", "CURRENCY", "0", "native test"],
            ["TRUE", "GLOBAL", "InvalidIso", "DATE", "0", "native test"],
            ["TRUE", "GLOBAL", "InvalidSlash", "DATE", "0", "native test"],
        ]

        with TemporaryDirectory() as tmp:
            directory = Path(tmp)
            setup = directory / "setup"
            setup.mkdir()
            self._write_csv(directory / "MODELE.csv", model_rows)
            self._write_csv(directory / "TARGET.csv", target_rows)
            (directory / "expected.json").write_text("{}\n", encoding="utf-8")
            self._write_csv(
                setup / "Compare_Config.csv",
                [
                    ["Parametre", "Valeur", "Description"],
                    ["IGNORE_CASE", "TRUE", "native test"],
                ],
            )
            self._write_csv(setup / "Compare_Comparators.csv", rules)
            scenario = Scenario(
                "TSYN",
                "typed-parser",
                directory,
                directory / "MODELE.csv",
                directory / "TARGET.csv",
                directory / "expected.json",
                tuple(sorted(setup.glob("*.csv"))),
            )
            artifacts = directory / "artifacts"
            actual = run_scenario(scenario, self.soffice, self.monolith, artifacts, 60)
            changes = self._native_report_changes(artifacts / "TSYN" / "scenario.ods")

        self.assertEqual("ECARTS", actual["decision"])
        self.assertEqual(2, actual["modified_rows"])
        self.assertEqual(10, actual["modified_cells"])
        self.assertNotIn(("P001", "Amount"), changes)
        self.assertNotIn(("P001", "Rate"), changes)
        self.assertNotIn(("P001", "Enabled"), changes)
        self.assertNotIn(("P001", "Date"), changes)
        self.assertNotIn(("P001", "Legacy"), changes)
        self.assertNotIn(("P001", "PrefixCurrency"), changes)
        self.assertNotIn(("P001", "ScientificDecimal"), changes)
        for column, comparator in (
            ("Amount", "CURRENCY [GLOBAL/AMOUNT]"),
            ("Rate", "PERCENT [GLOBAL/RATE]"),
            ("Enabled", "BOOLEAN [GLOBAL/ENABLED]"),
            ("Date", "DATE [GLOBAL/DATE]"),
        ):
            self.assertIn(("P002", column), changes)
            self.assertIn(comparator, changes[("P002", column)])
        for column, comparator in (
            ("BadComma", "CURRENCY [GLOBAL/BADCOMMA]"),
            ("BadMixed", "CURRENCY [GLOBAL/BADMIXED]"),
            ("BadMarker", "PERCENT [GLOBAL/BADMARKER]"),
            ("HugeScientific", "CURRENCY [GLOBAL/HUGESCIENTIFIC]"),
        ):
            self.assertIn(("P001", column), changes)
            self.assertIn(comparator, changes[("P001", column)])
            self.assertIn("parse impossible", changes[("P001", column)])
        for column, comparator in (
            ("InvalidIso", "DATE [GLOBAL/INVALIDISO]"),
            ("InvalidSlash", "DATE [GLOBAL/INVALIDSLASH]"),
        ):
            self.assertIn(("P001", column), changes)
            self.assertIn(comparator, changes[("P001", column)])
            self.assertIn("parse impossible", changes[("P001", column)])

    @staticmethod
    def _write_csv(path: Path, rows: list[list[str]]) -> None:
        with path.open("w", encoding="utf-8", newline="") as handle:
            csv.writer(handle).writerows(rows)

    @staticmethod
    def _native_report_changes(path: Path) -> dict[tuple[str, str], str]:
        namespaces = {"table": "urn:oasis:names:tc:opendocument:xmlns:table:1.0"}
        with ZipFile(path) as archive:
            root = ET.fromstring(archive.read("content.xml"))
        changes = {}
        for table in root.findall(".//table:table", namespaces):
            if table.get("{%s}name" % namespaces["table"]) != "Rapport_Comparaison":
                continue
            for row in table.findall("table:table-row", namespaces):
                values = []
                for cell in row.findall("table:table-cell", namespaces):
                    repeated = int(
                        cell.get("{%s}number-columns-repeated" % namespaces["table"], "1")
                    )
                    values.extend(["".join(cell.itertext()).strip()] * repeated)
                if len(values) >= 10 and values[0] != "Framework":
                    changes[(values[2], values[4])] = values[9]
        return changes


if __name__ == "__main__":
    unittest.main()
