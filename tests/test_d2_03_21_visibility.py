import re
import unittest
from pathlib import Path

TARGETS = [('Modes/CF_ModeReference.bas', 'CF_RunLauncherQuick'), ('CompareFramework_Audit.bas', 'CF_AuditClearHistory'), ('CompareFramework_ComparatorConfig.bas', 'CF_ReloadComparatorConfig'), ('CompareFramework_Context.bas', 'CF_ContextCount'), ('CompareFramework_Main.bas', 'CF_RunMilestoneA'), ('CompareFramework_Main.bas', 'CF_RunMilestoneB'), ('CompareFramework_Main.bas', 'CF_RunMilestoneB_Final'), ('CompareFramework_Main.bas', 'CF_RunMilestoneC'), ('CompareFramework_Main.bas', 'CF_RunMilestoneC_Final'), ('CompareFramework_Main.bas', 'CF_RunPerformanceProfiled'), ('CompareFramework_Main.bas', 'ComparerToutesLesFeuilles_Contextualisee'), ('CompareFramework_Profiles.bas', 'CF_ListProfiles')]
EXTERNAL_SUFFIXES = {".xml", ".xba", ".xdl", ".xlb"}
USER_DOCS = {
    "README.md", "docs/USER_GUIDE.md", "docs/API_REFERENCE.md",
    "STEP4_INTERACTIVE_CHECKLIST.md",
}

class D20321VisibilityTests(unittest.TestCase):
    def test_reviewed_candidates_are_private(self):
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

    def test_no_external_macro_ui_or_user_doc_binding(self):
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
                except UnicodeDecodeError:
                    continue
                if pattern.search(text):
                    found.append(rel)
            self.assertEqual([], found, f"external references for {target}: {found}")

if __name__ == "__main__":
    unittest.main()
