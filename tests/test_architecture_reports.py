import tempfile
import unittest
from pathlib import Path

from tools.architecture.engine import build_architecture
from tools.architecture.reports import (
    render_architecture_report,
    render_dependency_report,
)


class ReportTests(unittest.TestCase):
    def sample(self):
        return {
            "schema_version": "1.6.0",
            "repository": {"name": "repo", "version": "4.0-dev", "root": "."},
            "statistics": {
                "module_count": 2,
                "line_count": 20,
                "procedure_count": 2,
                "public_procedure_count": 2,
                "private_procedure_count": 0,
                "parse_warning_count": 0,
                "call_graph_edge_count": 1,
                "call_site_count": 2,
                "cross_module_edge_count": 1,
                "recursive_edge_count": 0,
                "module_dependency_count": 1,
                "dependency_cycle_count": 0,
                "cyclic_module_count": 0,
                "max_dependency_cycle_size": 0,
            },
            "dependency_analysis": {
                "module_metrics": [
                    {
                        "module": "A",
                        "incoming_modules": 0,
                        "outgoing_modules": 1,
                        "incoming_edges": 0,
                        "outgoing_edges": 1,
                        "incoming_call_sites": 0,
                        "outgoing_call_sites": 2,
                        "instability": 1.0,
                        "coupling_score": 1,
                    },
                    {
                        "module": "B",
                        "incoming_modules": 1,
                        "outgoing_modules": 0,
                        "incoming_edges": 1,
                        "outgoing_edges": 0,
                        "incoming_call_sites": 2,
                        "outgoing_call_sites": 0,
                        "instability": 0.0,
                        "coupling_score": 1,
                    },
                ],
                "dependencies": [{
                    "caller_module": "A",
                    "callee_module": "B",
                    "edge_count": 1,
                    "call_site_count": 2,
                }],
                "cycles": [],
            },
        }

    def test_architecture_report_contains_key_metrics(self):
        text = render_architecture_report(self.sample())
        self.assertIn("Resolved procedure edges: **1**", text)
        self.assertIn("Directed module dependencies: **1**", text)
        self.assertIn("Canonical schema: **1.6.0**", text)

    def test_dependency_report_contains_dependency(self):
        text = render_dependency_report(self.sample())
        self.assertIn("| A | B | 1 | 2 |", text)
        self.assertIn("Aucun cycle inter-module détecté.", text)

    def test_full_build_writes_reports(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "src").mkdir()
            (root / "VERSION").write_text("test\n", encoding="utf-8")
            (root / "src" / "A.bas").write_text(
                "Option Explicit\nPublic Sub Entry()\nEnd Sub\n",
                encoding="utf-8",
            )
            build_architecture(root)
            output = root / "build" / "architecture"
            self.assertTrue((output / "ARCHITECTURE_REPORT.md").is_file())
            self.assertTrue((output / "DEPENDENCY_REPORT.md").is_file())


if __name__ == "__main__":
    unittest.main()
