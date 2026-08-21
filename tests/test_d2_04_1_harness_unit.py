import unittest

from tools.ci.run_libreoffice_basic_smoke import (
    ResultContractError,
    validate_result_values,
    validate_version_output,
)


class HarnessUnitTests(unittest.TestCase):
    def test_exact_result_contract_passes(self):
        validate_result_values("OK", "COMPAREFRAMEWORK_CI_SMOKE_OK")

    def test_wrong_status_fails(self):
        with self.assertRaises(ResultContractError):
            validate_result_values("KO", "COMPAREFRAMEWORK_CI_SMOKE_OK")

    def test_wrong_marker_fails(self):
        with self.assertRaises(ResultContractError):
            validate_result_values("OK", "WRONG")

    def test_exact_runtime_version_passes(self):
        validate_version_output("LibreOffice 7.4.7.2 build")

    def test_wrong_runtime_version_fails(self):
        with self.assertRaises(RuntimeError):
            validate_version_output("LibreOffice 7.5.0.0 build")


if __name__ == "__main__":
    unittest.main()
