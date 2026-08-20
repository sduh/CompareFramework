import json
import re
import unittest
from pathlib import Path

OFFICIAL_API = {
    "CF_StartReferenceComparison",
    "CF_RunStandardComparison",
    "CF_ExportLastReportHTML",
    "CF_OpenSettings",
    "CF_RunDiagnostics",
    "CF_RunReleaseValidation",
}


class D20324PublicApiFreezeTests(unittest.TestCase):
    def test_api_facade_is_exactly_the_frozen_contract(self):
        root = Path(__file__).resolve().parents[1]
        text = (root / "src" / "CompareFramework_API.bas").read_text(encoding="utf-8-sig")
        public_procedures = set(
            re.findall(
                r"(?mi)^\s*Public\s+(?:Sub|Function)\s+([A-Za-z_][A-Za-z0-9_]*)\b",
                text,
            )
        )
        self.assertEqual(OFFICIAL_API, public_procedures)

    def test_frozen_contract_is_exported_by_architecture_analyzer(self):
        root = Path(__file__).resolve().parents[1]
        architecture = json.loads(
            (root / "build" / "architecture" / "architecture.json").read_text(encoding="utf-8")
        )
        freeze = architecture["public_api_contract"]
        self.assertEqual("frozen", freeze["status"])
        self.assertEqual(sorted(OFFICIAL_API), sorted(freeze["procedures"]))
        self.assertEqual(6, freeze["procedure_count"])

    def test_entrypoint_audit_contains_only_frozen_api(self):
        root = Path(__file__).resolve().parents[1]
        audit = json.loads(
            (root / "build" / "architecture" / "entrypoint_audit.json").read_text(encoding="utf-8")
        )
        self.assertEqual(6, audit["statistics"]["review_count"])
        self.assertEqual({"keep-public-api": 6}, audit["statistics"]["disposition_counts"])
        self.assertEqual(
            OFFICIAL_API,
            {row["procedure"] for row in audit["reviews"]},
        )


if __name__ == "__main__":
    unittest.main()
