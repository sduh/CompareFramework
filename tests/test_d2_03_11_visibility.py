import re
import unittest
from pathlib import Path
TARGETS=['CF_RunEndToEndScenario', 'CF_ValidateExpectedReport', 'CF_BuildQualityDashboard']
class D20311VisibilityTests(unittest.TestCase):
    def test_quality_helpers_are_private(self):
        root=Path(__file__).resolve().parents[1]
        text=(root/"src"/"CompareFramework_Quality.bas").read_text(encoding="utf-8-sig")
        for target in TARGETS:
            self.assertRegex(text,rf"(?mi)^\s*Private\s+(?:Sub|Function)\s+{re.escape(target)}\b")
            self.assertNotRegex(text,rf"(?mi)^\s*Public\s+(?:Sub|Function)\s+{re.escape(target)}\b")
if __name__=="__main__": unittest.main()
