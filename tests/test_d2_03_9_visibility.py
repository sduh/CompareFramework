import re
import unittest
from pathlib import Path
TARGETS=['CF_RunTypedRegressionSuite', 'CF_BuildComparatorCoverageReport']
class D2039VisibilityTests(unittest.TestCase):
    def test_reliability_helpers_are_private(self):
        root=Path(__file__).resolve().parents[1]
        text=(root/"src"/"CompareFramework_Reliability.bas").read_text(encoding="utf-8-sig")
        for target in TARGETS:
            self.assertRegex(text,rf"(?mi)^\s*Private\s+(?:Sub|Function)\s+{re.escape(target)}\b")
            self.assertNotRegex(text,rf"(?mi)^\s*Public\s+(?:Sub|Function)\s+{re.escape(target)}\b")
if __name__=="__main__": unittest.main()
