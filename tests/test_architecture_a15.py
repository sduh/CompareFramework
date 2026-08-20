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
            "schema_version": "1.6.0",
            "repository": {"name": "repo", "version": "1.0", "root": "."},
            "languages": [],
            "modules": [
                {"name": "M", "path": "M.bas", "line_count": 1, "procedures": []}
            ],
            "call_graph": {
                "nodes": [],
                "edges": [],
                "statistics": {
                    "node_count": 0,
                    "edge_count": 0,
                    "call_site_count": 0,
                    "cross_module_edge_count": 0,
                    "recursive_edge_count": 0,
                    "unresolved_candidate_count": 0,
                    "ambiguous_candidate_count": 0,
                },
            },
            "dependency_analysis": {
                "dependencies": [],
                "module_metrics": [{
                    "module": "M",
                    "outgoing_modules": 0,
                    "incoming_modules": 0,
                    "outgoing_edges": 0,
                    "incoming_edges": 0,
                    "outgoing_call_sites": 0,
                    "incoming_call_sites": 0,
                    "instability": 0.0,
                    "coupling_score": 0,
                }],
                "cycles": [],
                "statistics": {
                    "module_dependency_count": 0,
                    "cycle_count": 0,
                    "cyclic_module_count": 0,
                    "max_cycle_size": 0,
                },
            },
            "privatization_analysis": {
                "policy": {},
                "candidates": [],
                "protected_public": [],
                "statistics": {
                    "public_procedure_count": 0,
                    "cross_module_used_public_count": 0,
                    "candidate_count": 0,
                    "protected_public_count": 0,
                    "zero_caller_public_count": 0,
                    "classification_counts": {},
                },
            },
            "entrypoint_audit": {
                "policy": {},
                "reviews": [],
                "statistics": {"review_count": 0, "disposition_counts": {}},
            },
            "public_api_contract": {
                "status": "not-applicable",
                "module": "CompareFramework_API",
                "procedure_count": 0,
                "procedures": [],
                "policy": "fixture",
            },
            "statistics": {
                "module_count": 1,
                "procedure_count": 0,
                "supported_public_api_count": 0,
            },
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
