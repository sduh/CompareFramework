import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CI_BASIC = ROOT / "src" / "CompareFramework_CI.bas"
HARNESS = ROOT / "tools" / "ci" / "run_libreoffice_basic_smoke.py"
FIXTURE = ROOT / "tests" / "fixtures" / "ci" / "CompareFramework_CI.ods"
WORKFLOW = ROOT / ".github" / "workflows" / "d2-04-1-uno-basic-harness.yml"
API = ROOT / "src" / "CompareFramework_API.bas"


class D2041UnoHarnessContractTests(unittest.TestCase):
    def test_ci_basic_entrypoint_is_technical_and_not_user_api(self):
        ci_text = CI_BASIC.read_text(encoding="utf-8-sig")
        api_text = API.read_text(encoding="utf-8-sig")
        self.assertRegex(ci_text, r"(?mi)^\s*Public\s+Sub\s+CF_CI_RuntimeSmoke\b")
        self.assertNotIn("CF_CI_RuntimeSmoke", api_text)
        self.assertIn("COMPAREFRAMEWORK_CI_SMOKE_OK", ci_text)
        self.assertIn("CompareFramework_CI", ci_text)

    def test_ci_smoke_has_exact_noninteractive_result_contract(self):
        text = CI_BASIC.read_text(encoding="utf-8-sig")
        self.assertIn('getCellRangeByName("A1").String = "STATUS"', text)
        self.assertIn('getCellRangeByName("B1").String = "OK"', text)
        self.assertIn('getCellRangeByName("A2").String = "MARKER"', text)
        self.assertIn('getCellRangeByName("B2").String = "COMPAREFRAMEWORK_CI_SMOKE_OK"', text)
        for forbidden in ("MsgBox", "InputBox", "CF_RunReleaseValidation", "CF_RunStandardComparison"):
            self.assertNotIn(forbidden, text)

    def test_harness_uses_result_contract_without_loading_src_modules(self):
        text = HARNESS.read_text(encoding="utf-8")
        self.assertIn("CF_CI_RuntimeSmoke", text)
        self.assertIn("CompareFramework_CI", text)
        self.assertIn("COMPAREFRAMEWORK_CI_SMOKE_OK", text)
        self.assertNotRegex(text, r"src/.+\.bas")

    def test_harness_does_not_run_business_regression(self):
        text = HARNESS.read_text(encoding="utf-8")
        for forbidden in (
            "CF_RunReleaseValidation",
            "CF_RunStandardComparison",
            "CF_StartReferenceComparison",
            "T001",
            "T010",
        ):
            self.assertNotIn(forbidden, text)

    def test_fixture_is_valid_ods_container(self):
        self.assertTrue(FIXTURE.is_file())
        with zipfile.ZipFile(FIXTURE) as archive:
            names = set(archive.namelist())
            self.assertIn("mimetype", names)
            self.assertIn("content.xml", names)
            mimetype = archive.read("mimetype").decode("ascii")
            self.assertEqual("application/vnd.oasis.opendocument.spreadsheet", mimetype)
            content = archive.read("content.xml").decode("utf-8")
            self.assertIn('table:name="CompareFramework_CI"', content)
            self.assertNotIn("CF_CI_RuntimeSmoke", content)

    def test_workflow_uses_pinned_runtime_built_dist_artifact_and_harness(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("install_libreoffice_7_4_7_2.sh", workflow)
        self.assertIn("build_monolith.py", workflow)
        self.assertIn("find dist", workflow)
        self.assertIn("run_libreoffice_basic_smoke.py", workflow)
        self.assertIn("ubuntu-22.04", workflow)
        self.assertIn("--negative-missing-macro", workflow)
        self.assertIn("--negative-wrong-marker", workflow)


if __name__ == "__main__":
    unittest.main()
