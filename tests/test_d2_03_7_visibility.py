import re
import unittest
from pathlib import Path
TARGET = 'EndsWith'
class D2037VisibilityTests(unittest.TestCase):
    def test_utils_helper_is_private(self):
        root = Path(__file__).resolve().parents[1]
        text = (root / "src" / "CompareFramework_Utils.bas").read_text(encoding="utf-8-sig")
        self.assertRegex(text, rf"(?mi)^\s*Private\s+(?:Sub|Function)\s+{re.escape(TARGET)}\b")
        self.assertNotRegex(text, rf"(?mi)^\s*Public\s+(?:Sub|Function)\s+{re.escape(TARGET)}\b")
if __name__ == "__main__":
    unittest.main()
