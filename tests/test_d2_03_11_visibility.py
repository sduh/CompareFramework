import re
import unittest
from pathlib import Path

class D20311VisibilityTests(unittest.TestCase):
    def test_quality_visibility_after_guardrail_reconciliation(self):
        root = Path(__file__).resolve().parents[1]
        text = (root / "src" / "CompareFramework_Quality.bas").read_text(encoding="utf-8-sig")
        self.assertRegex(text, r"(?mi)^\s*Private\s+(?:Sub|Function)\s+CF_RunEndToEndScenario\b")
        self.assertRegex(text, r"(?mi)^\s*Private\s+(?:Sub|Function)\s+CF_ValidateExpectedReport\b")
        self.assertRegex(text, r"(?mi)^\s*Public\s+(?:Sub|Function)\s+CF_BuildQualityDashboard\b")

if __name__ == "__main__":
    unittest.main()
