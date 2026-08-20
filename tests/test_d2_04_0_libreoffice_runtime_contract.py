import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = ROOT / "tools" / "ci" / "install_libreoffice_7_4_7_2.sh"
WORKFLOW = ROOT / ".github" / "workflows" / "d2-04-0-libreoffice-7-4-7-2.yml"


class D2040LibreOfficeRuntimeContractTests(unittest.TestCase):
    def test_installer_pins_exact_version_and_official_archive(self):
        text = INSTALLER.read_text(encoding="utf-8")
        self.assertIn('LO_VERSION="7.4.7.2"', text)
        self.assertIn(
            "downloadarchive.documentfoundation.org/libreoffice/old/7.4.7.2",
            text,
        )
        self.assertNotRegex(text, r"apt(?:-get)?\s+install\s+.*\blibreoffice\b")

    def test_installer_is_fail_fast_and_checks_version(self):
        text = INSTALLER.read_text(encoding="utf-8")
        self.assertRegex(text, r"(?m)^set -euo pipefail$")
        self.assertIn("--version", text)
        self.assertIn("7.4.7.2", text)

    def test_workflow_uses_dedicated_installer_and_isolated_profile(self):
        text = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("tools/ci/install_libreoffice_7_4_7_2.sh", text)
        self.assertIn("mktemp -d", text)
        self.assertIn("-env:UserInstallation=file://", text)
        self.assertNotIn("apt install libreoffice", text)
        self.assertNotIn("apt-get install libreoffice", text)

    def test_d2_03_workflow_remains_separate(self):
        workflow = (ROOT / ".github" / "workflows" / "d2-03-24-validation.yml").read_text(
            encoding="utf-8"
        )
        self.assertNotIn("install_libreoffice_7_4_7_2.sh", workflow)
        self.assertNotIn("7.4.7.2", workflow)


if __name__ == "__main__":
    unittest.main()
