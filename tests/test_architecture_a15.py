import tempfile
import unittest
from pathlib import Path

from tools.architecture.engine import build_architecture
from tools.architecture.validation import (
    ArchitectureValidationError,
    validate_architecture_document,
)

class ValidationTests(unittest.TestCase):
    def sample(self):
        return {
            "schema_version": "1.0.0",
            "repository": {"name": "repo", "version": "1.0", "root": "."},
            "languages": [],
            "modules": [
                {"name": "M", "path": "M.bas", "line_count": 1, "procedures": []}
            ],
            "statistics": {"module_count": 1, "procedure_count": 0},
        }

    def test_valid_document(self):
        validate_architecture_document(self.sample())

    def test_duplicate_module_path_rejected(self):
        doc = self.sample()
        doc["modules"].append(dict(doc["modules"][0]))
        doc["statistics"]["module_count"] = 2
        with self.assertRaises(ArchitectureValidationError):
            validate_architecture_document(doc)

    def test_missing_repository_fails_cleanly(self):
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(FileNotFoundError):
                build_architecture(Path(tmp))

if __name__ == "__main__":
    unittest.main()
