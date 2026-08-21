import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATASETS = ROOT / "tests" / "datasets"
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


if __name__ == "__main__":
    unittest.main()
