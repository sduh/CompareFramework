import tempfile
import unittest
from pathlib import Path

from tools.architecture.callgraph import CallEdge, CallGraph
from tools.architecture.model import Module, Procedure, Repository
from tools.architecture.privatization import analyze_privatization


class D20319ContractGuardrailTests(unittest.TestCase):
    def proc(self, name):
        return Procedure(
            name=name,
            kind="Sub",
            visibility="Public",
            line=1,
            end_line=3,
            signature=f"Public Sub {name}()",
        )

    def test_keep_public_contract_excludes_local_only_candidate(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            inv = root / "docs" / "audit"
            inv.mkdir(parents=True)
            (inv / "PUBLIC_SYMBOL_INVENTORY.csv").write_text(
                "Module,Line,Symbol,Kind,Signature,Classification,Decision,Notes\n"
                "A.bas,1,Helper,Sub,(),Advanced API,Keep Public,\n",
                encoding="utf-8",
            )
            repo = Repository(
                version="x",
                modules=[Module(
                    "A", "A.bas", 10,
                    procedures=[self.proc("Caller"), self.proc("Helper")]
                )],
            )
            graph = CallGraph(
                nodes=[],
                edges=[CallEdge("A.Caller", "A", "A.Helper", "A", 1, [2], False)],
            )
            analysis = analyze_privatization(repo, graph, root)
            self.assertNotIn("Helper", {c.procedure for c in analysis.candidates})
            self.assertIn("Helper", {p.procedure for p in analysis.protected_public})

    def test_without_contract_local_only_remains_candidate(self):
        repo = Repository(
            version="x",
            modules=[Module(
                "A", "A.bas", 10,
                procedures=[self.proc("Caller"), self.proc("Helper")]
            )],
        )
        graph = CallGraph(
            nodes=[],
            edges=[CallEdge("A.Caller", "A", "A.Helper", "A", 1, [2], False)],
        )
        analysis = analyze_privatization(repo, graph)
        self.assertIn("Helper", {c.procedure for c in analysis.candidates})


if __name__ == "__main__":
    unittest.main()
