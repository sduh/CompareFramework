import csv
import re
import unittest
from pathlib import Path

MODULE_PATH = 'CompareFramework_EngineMemory.bas'
PRIVATE_TARGETS = ['CF_CompareDetectedPairsMemory', 'CF_CompareFallbackMemory', 'CF_BuildMemoryIdIndex', 'CF_CompareMemoryRows', 'CF_MemoryFullRow', 'CF_ReportMemoryDuplicates', 'CF_MemoryValueText']

class D20317VisibilityTests(unittest.TestCase):
    def test_engine_memory_helpers_are_private(self):
        root = Path(__file__).resolve().parents[1]
        text = (root / "src" / MODULE_PATH).read_text(encoding="utf-8-sig")
        for target in PRIVATE_TARGETS:
            self.assertRegex(
                text,
                rf"(?mi)^\s*Private\s+(?:Sub|Function)\s+{re.escape(target)}\b",
            )
            self.assertNotRegex(
                text,
                rf"(?mi)^\s*Public\s+(?:Sub|Function)\s+{re.escape(target)}\b",
            )

    def test_all_documented_keep_public_symbols_remain_public(self):
        root = Path(__file__).resolve().parents[1]
        inventory = root / "docs" / "audit" / "PUBLIC_SYMBOL_INVENTORY.csv"
        checked = 0
        with inventory.open(encoding="utf-8-sig", newline="") as handle:
            for row in csv.reader(handle):
                if len(row) < 7 or "keep public" not in row[6].casefold():
                    continue
                source = root / "src" / row[0]
                if not source.exists():
                    continue
                text = source.read_text(encoding="utf-8-sig")
                self.assertRegex(
                    text,
                    rf"(?mi)^\s*Public\s+(?:Sub|Function)\s+{re.escape(row[2])}\b",
                    f"{row[0]}:{row[2]}",
                )
                checked += 1
        self.assertGreater(checked, 0)

if __name__ == "__main__":
    unittest.main()
