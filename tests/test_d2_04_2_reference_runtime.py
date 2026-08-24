import os
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

from tools.ci.run_functional_scenarios import Scenario, run_scenario


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
        with TemporaryDirectory() as tmp:
            actual = self._run("Value\nAlpha\n", Path(tmp) / "artifacts")
        self.assertEqual("A CONTROLER", actual["decision"])
        self.assertEqual(1, actual["structure_alerts"])

    def test_no_target_keeps_one_generic_incident(self):
        with TemporaryDirectory() as tmp:
            actual = self._run(None, Path(tmp) / "artifacts")
        self.assertEqual("A CONTROLER", actual["decision"])
        self.assertEqual(1, actual["structure_alerts"])


if __name__ == "__main__":
    unittest.main()
