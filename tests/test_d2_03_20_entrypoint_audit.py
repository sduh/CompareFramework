import tempfile
import unittest
from pathlib import Path

from tools.architecture.entrypoints import build_entrypoint_audit
from tools.architecture.privatization import (
    PrivatizationAnalysis,
    PrivatizationCandidate,
)


class D20320EntrypointAuditTests(unittest.TestCase):
    def candidate(self, module, path, proc):
        return PrivatizationCandidate(
            module=module,
            module_path=path,
            procedure=proc,
            kind="Sub",
            line=1,
            local_incoming_edges=0,
            local_call_sites=0,
            classification="zero-caller-review",
            confidence="medium",
            reason="test",
        )

    def analysis(self, candidates):
        return PrivatizationAnalysis(
            candidates=candidates,
            protected_public=[],
            public_procedure_count=len(candidates),
            cross_module_used_count=0,
            zero_caller_public_count=len(candidates),
        )

    def test_official_api_contract_is_keep_public(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            inv = root / "docs" / "audit"
            inv.mkdir(parents=True)
            (inv / "D1_PUBLIC_API_INVENTORY.csv").write_text(
                "src/API.bas,1,2,Public,Sub,Run,official-api,keep-public,0,0\n",
                encoding="utf-8",
            )
            audit = build_entrypoint_audit(
                root, self.analysis([self.candidate("API", "API.bas", "Run")])
            )
            self.assertEqual("keep-public-api", audit.reviews[0].disposition)

    def test_document_reference_creates_conflict_review(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            inv = root / "docs" / "audit"
            inv.mkdir(parents=True)
            (inv / "D1_PUBLIC_API_INVENTORY.csv").write_text(
                "src/M.bas,1,2,Public,Sub,Legacy,module-internal-candidate,"
                "candidate-private-after-regression,0,0\n",
                encoding="utf-8",
            )
            (root / "README.md").write_text("Use Legacy() here.\n", encoding="utf-8")
            audit = build_entrypoint_audit(
                root, self.analysis([self.candidate("M", "M.bas", "Legacy")])
            )
            self.assertEqual(
                "documentation-conflict-review", audit.reviews[0].disposition
            )

    def test_private_after_regression_when_no_external_document_reference(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            inv = root / "docs" / "audit"
            inv.mkdir(parents=True)
            (inv / "D1_PUBLIC_API_INVENTORY.csv").write_text(
                "src/M.bas,1,2,Public,Sub,Helper,module-internal-candidate,"
                "candidate-private-after-regression,0,0\n",
                encoding="utf-8",
            )
            audit = build_entrypoint_audit(
                root, self.analysis([self.candidate("M", "M.bas", "Helper")])
            )
            self.assertEqual(
                "private-after-regression-review", audit.reviews[0].disposition
            )


if __name__ == "__main__":
    unittest.main()
