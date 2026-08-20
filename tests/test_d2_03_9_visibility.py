import re
import unittest
from pathlib import Path

class D2039VisibilityTests(unittest.TestCase):
    def test_reliability_visibility_after_guardrail_reconciliation(self):
        root = Path(__file__).resolve().parents[1]
        text = (root / "src" / "CompareFramework_Reliability.bas").read_text(encoding="utf-8-sig")
        self.assertRegex(text, r"(?mi)^\s*Public\s+(?:Sub|Function)\s+CF_RunTypedRegressionSuite\b")
        self.assertRegex(text, r"(?mi)^\s*Private\s+(?:Sub|Function)\s+CF_BuildComparatorCoverageReport\b")

if __name__ == "__main__":
    unittest.main()
