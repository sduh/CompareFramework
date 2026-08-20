import unittest
from tools.architecture.callgraph import CallEdge, CallGraph, ProcedureRef
from tools.architecture.model import Module, Procedure, Repository
from tools.architecture.privatization import analyze_privatization

class PrivatizationTests(unittest.TestCase):
    def proc(self, name, visibility="Public", line=1):
        return Procedure(name=name, kind="Sub", visibility=visibility, line=line, end_line=line+2, signature=f"Public Sub {name}()")

    def test_local_only_is_high_confidence_candidate(self):
        repo=Repository(version="x", modules=[
            Module("A","A.bas",10, procedures=[self.proc("Entry"), self.proc("Helper",line=4)])
        ])
        graph=CallGraph(nodes=[], edges=[
            CallEdge("A.Entry","A","A.Helper","A",1,[2],False)
        ])
        analysis=analyze_privatization(repo,graph)
        items={c.procedure:c for c in analysis.candidates}
        self.assertEqual("local-only",items["Helper"].classification)
        self.assertEqual("high",items["Helper"].confidence)

    def test_cross_module_usage_excludes_candidate(self):
        repo=Repository(version="x", modules=[
            Module("A","A.bas",10, procedures=[self.proc("Api")]),
            Module("B","B.bas",10, procedures=[self.proc("Caller")]),
        ])
        graph=CallGraph(nodes=[], edges=[
            CallEdge("B.Caller","B","A.Api","A",1,[2],False)
        ])
        analysis=analyze_privatization(repo,graph)
        self.assertNotIn("Api",{c.procedure for c in analysis.candidates})

    def test_zero_caller_requires_review(self):
        repo=Repository(version="x", modules=[
            Module("A","A.bas",10, procedures=[self.proc("Utility")])
        ])
        analysis=analyze_privatization(repo,CallGraph(nodes=[],edges=[]))
        self.assertEqual("zero-caller-review",analysis.candidates[0].classification)

    def test_entrypoint_like_is_low_confidence(self):
        repo=Repository(version="x", modules=[
            Module("A","A.bas",10, procedures=[self.proc("Main")])
        ])
        analysis=analyze_privatization(repo,CallGraph(nodes=[],edges=[]))
        self.assertEqual("entrypoint-review",analysis.candidates[0].classification)
        self.assertEqual("low",analysis.candidates[0].confidence)

if __name__=="__main__":
    unittest.main()
