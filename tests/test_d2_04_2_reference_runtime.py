import os
import traceback
import unittest
from contextlib import contextmanager
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch

from tools.ci.run_functional_scenarios import Scenario, run_scenario


class D2042ReferenceRuntimeDiagnosticsUnitTests(unittest.TestCase):
    def test_configured_artifact_root_keeps_a_named_workspace(self):
        with TemporaryDirectory() as tmp:
            root = Path(tmp) / "diagnostics"
            with patch.dict(
                os.environ,
                {"CF_D2042_ARTIFACT_ROOT": str(root)},
                clear=False,
            ):
                with reference_runtime_workspace("missing-key") as workspace:
                    (workspace / "marker.txt").write_text("kept\n", encoding="utf-8")

            self.assertEqual("kept\n", (root / "missing-key" / "marker.txt").read_text())

    def test_configured_workspace_records_failure_without_replacing_it(self):
        with TemporaryDirectory() as tmp:
            root = Path(tmp) / "diagnostics"
            with patch.dict(
                os.environ,
                {"CF_D2042_ARTIFACT_ROOT": str(root)},
                clear=False,
            ):
                with self.assertRaisesRegex(RuntimeError, "original failure"):
                    with reference_runtime_workspace("no-target"):
                        raise RuntimeError("original failure")

            failure = (root / "no-target" / "failure.txt").read_text(encoding="utf-8")
            self.assertIn("RuntimeError: original failure", failure)

    def test_diagnostic_formatting_failure_preserves_original_failure(self):
        with TemporaryDirectory() as tmp:
            root = Path(tmp) / "diagnostics"
            with patch.dict(
                os.environ,
                {"CF_D2042_ARTIFACT_ROOT": str(root)},
                clear=False,
            ), patch.object(traceback, "format_exc", side_effect=ValueError("formatting failed")):
                with self.assertRaisesRegex(RuntimeError, "original failure"):
                    with reference_runtime_workspace("formatting-failure"):
                        raise RuntimeError("original failure")


@contextmanager
def reference_runtime_workspace(case_name: str):
    """Yield a temporary workspace unless CI requests retained diagnostics."""
    configured_root = os.environ.get("CF_D2042_ARTIFACT_ROOT")
    if configured_root:
        workspace = Path(configured_root) / case_name
        workspace.mkdir(parents=True, exist_ok=True)
        try:
            yield workspace
        except BaseException:
            try:
                (workspace / "failure.txt").write_text(
                    traceback.format_exc(), encoding="utf-8"
                )
            except Exception:
                pass
            raise
        return

    with TemporaryDirectory(prefix=f"compareframework-reference-{case_name}-") as tmp:
        yield Path(tmp)


class D2042ReferenceRuntimeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.soffice = os.environ["SOFFICE_BIN"]
        cls.monolith = Path(os.environ["CF_MONOLITH"])

    def _run(self, target_text: str | None, artifacts: Path):
        directory = artifacts.parent
        model = directory / "MODELE.csv"
        model.write_text("ProductId,Value\nP001,Alpha\n", encoding="utf-8")
        target = None
        if target_text is not None:
            target = directory / "TARGET.csv"
            target.write_text(target_text, encoding="utf-8")
        expected = directory / "expected.json"
        expected.write_text("{}\n", encoding="utf-8")
        scenario = Scenario("TSYN", "synthetic", directory, model, target, expected)
        return run_scenario(scenario, self.soffice, self.monolith, artifacts, 60)

    def test_missing_key_is_one_precise_incident(self):
        with reference_runtime_workspace("missing-key") as workspace:
            actual = self._run("Value\nAlpha\n", workspace / "artifacts")
            self.assertEqual("A CONTROLER", actual["decision"])
            self.assertEqual(1, actual["structure_alerts"])

    def test_no_target_keeps_one_generic_incident(self):
        with reference_runtime_workspace("no-target") as workspace:
            actual = self._run(None, workspace / "artifacts")
            self.assertEqual("A CONTROLER", actual["decision"])
            self.assertEqual(1, actual["structure_alerts"])


if __name__ == "__main__":
    unittest.main()
