import re
import unittest
from pathlib import Path

TARGETS = ["CF_RunAudited", "ComparerToutesLesFeuilles_Legacy"]

class D20322DocumentationConflictTests(unittest.TestCase):
    def test_targets_are_private(self):
        root = Path(__file__).resolve().parents[1]
        text = (root / "src" / "CompareFramework_Main.bas").read_text(encoding="utf-8-sig")
        for target in TARGETS:
            self.assertRegex(
                text,
                rf"(?mi)^\s*Private\s+(?:Sub|Function)\s+{re.escape(target)}\b",
            )
            self.assertNotRegex(
                text,
                rf"(?mi)^\s*Public\s+(?:Sub|Function)\s+{re.escape(target)}\b",
            )

    def test_user_docs_use_official_api_and_not_legacy_targets(self):
        root = Path(__file__).resolve().parents[1]
        for rel in ("README.md", "docs/USER_GUIDE.md"):
            text = (root / rel).read_text(encoding="utf-8-sig")
            self.assertIn("CF_RunStandardComparison", text)
            self.assertIn("CF_StartReferenceComparison", text)
            for target in TARGETS:
                self.assertNotRegex(text, rf"\b{re.escape(target)}\b")

if __name__ == "__main__":
    unittest.main()
