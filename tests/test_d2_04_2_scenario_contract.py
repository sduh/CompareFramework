import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATASETS = ROOT / "tests" / "datasets"
REFERENCE_MODE = ROOT / "src" / "Modes" / "CF_ModeReference.bas"
API = ROOT / "src" / "CompareFramework_API.bas"
WORKFLOW = ROOT / ".github" / "workflows" / "d2-04-2-functional-scenarios.yml"
SCENARIOS = (
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
FIELDS = {
    "scenario_id", "decision", "added_rows", "deleted_rows",
    "modified_rows", "modified_cells", "duplicate_ids", "structure_alerts",
}


class D2042ScenarioContractTests(unittest.TestCase):
    def test_exactly_t001_to_t010_have_machine_contracts(self):
        self.assertEqual(10, len(SCENARIOS))
        for scenario_id, folder in SCENARIOS:
            path = DATASETS / folder / "expected.json"
            self.assertTrue(path.is_file(), path)
            payload = json.loads(path.read_text(encoding="utf-8"))
            self.assertEqual(FIELDS, set(payload))
            self.assertEqual(scenario_id, payload["scenario_id"])
            self.assertIn(payload["decision"], {"OK", "ECARTS", "A CONTROLER"})
            for field in FIELDS - {"scenario_id", "decision"}:
                self.assertIsInstance(payload[field], int)
                self.assertGreaterEqual(payload[field], 0)

    def test_ci_scenario_entrypoint_is_technical_and_noninteractive(self):
        text = REFERENCE_MODE.read_text(encoding="utf-8-sig")
        api = API.read_text(encoding="utf-8-sig")
        self.assertIn("Public Sub CF_CI_RunScenario()", text)
        self.assertIn('CF_REFERENCE_SELECTED_TARGETS = "TARGET"', text)
        self.assertIn('CF_RunAgainstReference "MODELE", "ProductId"', text)
        self.assertIn("Public CF_REFERENCE_SILENT As Boolean", text)
        self.assertNotIn("CF_CI_RunScenario", api)

    def test_workflow_pins_runtime_and_uploads_diagnostics(self):
        self.assertTrue(WORKFLOW.is_file(), WORKFLOW)
        text = WORKFLOW.read_text(encoding="utf-8")
        for token in (
            "ubuntu-22.04",
            "install_libreoffice_7_4_7_2.sh",
            "build_monolith.py",
            "tools.ci.run_functional_scenarios",
            "actions/upload-artifact@v4",
            "build/d2-04-2",
        ):
            self.assertIn(token, text)


if __name__ == "__main__":
    unittest.main()
