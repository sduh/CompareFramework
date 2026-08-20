import re
import unittest
from pathlib import Path
PRIVATE_TARGETS=['CompareDetectedPairs', 'CompareFallbackTwoSheets', 'CompareSheetPair', 'CF_RunMilestoneB_Configured']
PUBLIC_TARGET='GetFrameworkVersion'
class D20315VisibilityTests(unittest.TestCase):
    def test_main_visibility_decision(self):
        root=Path(__file__).resolve().parents[1]
        text=(root/"src"/"CompareFramework_Main.bas").read_text(encoding="utf-8-sig")
        for target in PRIVATE_TARGETS:
            self.assertRegex(text,rf"(?mi)^\s*Private\s+(?:Sub|Function)\s+{re.escape(target)}\b")
            self.assertNotRegex(text,rf"(?mi)^\s*Public\s+(?:Sub|Function)\s+{re.escape(target)}\b")
        self.assertRegex(text,rf"(?mi)^\s*Public\s+Function\s+{re.escape(PUBLIC_TARGET)}\b")
if __name__=="__main__": unittest.main()
