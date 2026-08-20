import re
import unittest
from pathlib import Path

TARGETS = ['CF_ComparatorTypeForHeader', 'CF_TextEqual', 'CF_NumberEqual', 'CF_DateEqual', 'CF_BooleanEqual', 'CF_LooksNumeric', 'CF_LooksDate', 'CF_LooksBoolean', 'CF_TryParseNumber', 'CF_TryParseDateSerial', 'CF_BooleanCode', 'CF_PercentToNumber', 'CF_CurrencyToNumber', 'CF_GetNumericTolerance', 'CF_GetPercentTolerance', 'CF_GetCurrencyTolerance', 'CF_GetDateToleranceDays']

class D2032VisibilityTests(unittest.TestCase):
    def test_first_wave_is_private(self):
        root = Path(__file__).resolve().parents[1]
        source = (root / "src" / "CompareFramework_Comparators.bas").read_text(
            encoding="utf-8-sig"
        )
        for name in TARGETS:
            self.assertRegex(
                source,
                rf"(?mi)^\s*Private\s+(?:Sub|Function)\s+{re.escape(name)}\b",
                name,
            )
            self.assertNotRegex(
                source,
                rf"(?mi)^\s*Public\s+(?:Sub|Function)\s+{re.escape(name)}\b",
                name,
            )

if __name__ == "__main__":
    unittest.main()
