import re
import unittest
from pathlib import Path

TARGETS = ['CF_EnsureComparatorsSheet', 'CF_WriteDefaultComparatorConfig']

class D2033VisibilityTests(unittest.TestCase):
    def test_second_wave_is_private(self):
        root = Path(__file__).resolve().parents[1]
        text = (root / "src" / "CompareFramework_ComparatorConfig.bas").read_text(
            encoding="utf-8-sig"
        )
        for name in TARGETS:
            self.assertRegex(
                text,
                rf"(?mi)^\s*Private\s+(?:Sub|Function)\s+{re.escape(name)}\b",
            )
            self.assertNotRegex(
                text,
                rf"(?mi)^\s*Public\s+(?:Sub|Function)\s+{re.escape(name)}\b",
            )

if __name__ == "__main__":
    unittest.main()
