import tempfile
import unittest
from pathlib import Path

from tools.architecture.callgraph import build_call_graph
from tools.architecture.repository import load_repository


class CallGraphTests(unittest.TestCase):
    def make_repo(self, files):
        temp = tempfile.TemporaryDirectory()
        root = Path(temp.name)
        (root / "src").mkdir()
        (root / "VERSION").write_text("test\n", encoding="utf-8")
        for name, content in files.items():
            path = root / "src" / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8")
        return temp, root

    def test_local_and_cross_module_calls(self):
        temp, root = self.make_repo({
            "A.bas": """Option Explicit
Public Sub Entry()
    Helper
    SharedCall
End Sub
Private Sub Helper()
End Sub
""",
            "B.bas": """Option Explicit
Public Sub SharedCall()
End Sub
""",
        })
        self.addCleanup(temp.cleanup)
        repo = load_repository(root)
        graph = build_call_graph(root, repo)
        edges = {(e.caller, e.callee) for e in graph.edges}
        self.assertIn(("A.Entry", "A.Helper"), edges)
        self.assertIn(("A.Entry", "B.SharedCall"), edges)

    def test_function_result_assignment_is_not_recursion(self):
        temp, root = self.make_repo({
            "A.bas": """Option Explicit
Public Function Value() As Long
    Value = 42
End Function
""",
        })
        self.addCleanup(temp.cleanup)
        repo = load_repository(root)
        graph = build_call_graph(root, repo)
        self.assertEqual([], graph.edges)

    def test_explicit_module_qualification(self):
        temp, root = self.make_repo({
            "A.bas": """Option Explicit
Public Sub Entry()
    B.Target
End Sub
""",
            "B.bas": """Option Explicit
Public Sub Target()
End Sub
""",
        })
        self.addCleanup(temp.cleanup)
        repo = load_repository(root)
        graph = build_call_graph(root, repo)
        self.assertEqual(1, len(graph.edges))
        self.assertEqual("B.Target", graph.edges[0].callee)

    def test_object_member_is_not_framework_call(self):
        temp, root = self.make_repo({
            "A.bas": """Option Explicit
Public Sub Entry()
    oObject.Target()
End Sub
Public Sub Target()
End Sub
""",
        })
        self.addCleanup(temp.cleanup)
        repo = load_repository(root)
        graph = build_call_graph(root, repo)
        self.assertEqual([], graph.edges)


if __name__ == "__main__":
    unittest.main()
