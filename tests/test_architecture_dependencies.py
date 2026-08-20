import unittest

from tools.architecture.callgraph import CallEdge, CallGraph, ProcedureRef
from tools.architecture.dependencies import analyze_dependencies
from tools.architecture.model import Module, Repository


class DependencyTests(unittest.TestCase):
    def graph(self, edges):
        nodes = [
            ProcedureRef("A", "A.bas", "P", "Public", "Sub", 1),
            ProcedureRef("B", "B.bas", "P", "Public", "Sub", 1),
            ProcedureRef("C", "C.bas", "P", "Public", "Sub", 1),
        ]
        return CallGraph(nodes=nodes, edges=edges)

    def repo(self):
        return Repository(version="test", modules=[
            Module("A", "A.bas", 1),
            Module("B", "B.bas", 1),
            Module("C", "C.bas", 1),
        ])

    def edge(self, caller, callee, count=1):
        return CallEdge(
            caller=f"{caller}.P",
            caller_module=caller,
            callee=f"{callee}.P",
            callee_module=callee,
            call_count=count,
            lines=[1],
        )

    def test_acyclic_graph(self):
        analysis = analyze_dependencies(
            self.repo(),
            self.graph([self.edge("A", "B"), self.edge("B", "C")]),
        )
        self.assertEqual([], analysis.cycles)

    def test_cycle_detected_as_strong_component(self):
        analysis = analyze_dependencies(
            self.repo(),
            self.graph([
                self.edge("A", "B"),
                self.edge("B", "C"),
                self.edge("C", "A"),
            ]),
        )
        self.assertEqual(1, len(analysis.cycles))
        self.assertEqual(("A", "B", "C"), analysis.cycles[0].modules)

    def test_metrics_fan_in_and_fan_out(self):
        analysis = analyze_dependencies(
            self.repo(),
            self.graph([self.edge("A", "B", 3), self.edge("C", "B", 2)]),
        )
        metrics = {item.module: item for item in analysis.metrics}
        self.assertEqual(1, metrics["A"].outgoing_modules)
        self.assertEqual(2, metrics["B"].incoming_modules)
        self.assertEqual(5, metrics["B"].incoming_call_sites)

if __name__ == "__main__":
    unittest.main()
