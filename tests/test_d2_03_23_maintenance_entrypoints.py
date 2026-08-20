import re
import unittest
from pathlib import Path

TARGETS = [('CompareFramework_Main.bas', 'CF_RunMilestoneB_ConfigTests'), ('CompareFramework_Tests.bas', 'CF_RunMilestoneBTests')]
EXTERNAL_SUFFIXES = {".xml", ".xba", ".xdl", ".xlb"}
USER_DOCS = {
    "README.md",
    "docs/USER_GUIDE.md",
    "docs/API_REFERENCE.md",
    "STEP4_INTERACTIVE_CHECKLIST.md",
}

class D20323MaintenanceEntrypointTests(unittest.TestCase):
    def test_maintenance_targets_are_private(self):
        root = Path(__file__).resolve().parents[1]
        for module_path, target in TARGETS:
            text = (root / "src" / module_path).read_text(encoding="utf-8-sig")
            self.assertRegex(
                text,
                rf"(?mi)^\s*Private\s+(?:Sub|Function)\s+{re.escape(target)}\b",
            )
            self.assertNotRegex(
                text,
                rf"(?mi)^\s*Public\s+(?:Sub|Function)\s+{re.escape(target)}\b",
            )

    def test_no_external_or_user_binding(self):
        root = Path(__file__).resolve().parents[1]
        for _, target in TARGETS:
            pattern = re.compile(rf"\b{re.escape(target)}\b", re.I)
            found = []
            for path in root.rglob("*"):
                if not path.is_file():
                    continue
                rel = path.relative_to(root).as_posix()
                if path.suffix.lower() not in EXTERNAL_SUFFIXES and rel not in USER_DOCS:
                    continue
                try:
                    text = path.read_text(encoding="utf-8-sig")
                except (UnicodeDecodeError, OSError):
                    continue
                if pattern.search(text):
                    found.append(rel)
            self.assertEqual([], found, f"external refs for {target}: {found}")

    def test_decision_is_documented(self):
        root = Path(__file__).resolve().parents[1]
        text = (
            root / "docs" / "audit" / "D2_03_23_MAINTENANCE_ENTRYPOINT_DECISION.md"
        ).read_text(encoding="utf-8")
        for _, target in TARGETS:
            self.assertIn(target, text)

if __name__ == "__main__":
    unittest.main()
