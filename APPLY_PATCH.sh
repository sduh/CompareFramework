#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
AUDIT="$ROOT/src/CompareFramework_Audit.bas"
PERF="$ROOT/src/CompareFramework_Performance.bas"
UTILS="$ROOT/src/CompareFramework_Utils.bas"

for f in "$AUDIT" "$PERF" "$UTILS"; do
  if [ ! -f "$f" ]; then
    echo "Fichier introuvable: $f" >&2
    exit 1
  fi
done

python3 - "$AUDIT" "$PERF" "$UTILS" <<'PY'
from pathlib import Path
import sys

audit = Path(sys.argv[1])
perf = Path(sys.argv[2])
utils = Path(sys.argv[3])

replacements = {
    audit: [
        (
            'CF_AuditDurationSeconds = Round((endValue - CF_AUDIT_STARTED_AT) * 86400, 3)',
            'CF_AuditDurationSeconds = CF_RoundCompat((endValue - CF_AUDIT_STARTED_AT) * 86400, 3)',
        )
    ],
    perf: [
        (
            'CF_PerfCell oSheet, 1, r, CStr(Round(CF_PERF_ELAPSED(i), 3))',
            'CF_PerfCell oSheet, 1, r, CStr(CF_RoundCompat(CF_PERF_ELAPSED(i), 3))',
        ),
        (
            'CF_PerfCell oSheet, 4, r, CStr(Round(CF_PERF_PAIR_SECONDS(i), 3))',
            'CF_PerfCell oSheet, 4, r, CStr(CF_RoundCompat(CF_PERF_PAIR_SECONDS(i), 3))',
        ),
    ],
}

for path, pairs in replacements.items():
    text = path.read_text(encoding='utf-8-sig')
    changed = False
    for old, new in pairs:
        if old in text:
            text = text.replace(old, new)
            changed = True
        elif new not in text:
            raise SystemExit(f'Expression attendue introuvable dans {path}: {old}')
    if changed:
        path.write_text(text, encoding='utf-8')

utils_text = utils.read_text(encoding='utf-8-sig')
if 'Function CF_RoundCompat(' not in utils_text:
    helper = '''\n\nPublic Function CF_RoundCompat(vValue As Double, iDecimals As Integer) As Double\n    Dim factor As Double\n    Dim scaled As Double\n\n    factor = 10 ^ iDecimals\n    scaled = vValue * factor\n\n    If scaled >= 0 Then\n        CF_RoundCompat = Int(scaled + 0.5) / factor\n    Else\n        CF_RoundCompat = -Int(-scaled + 0.5) / factor\n    End If\nEnd Function\n'''
    utils_text = utils_text.rstrip() + helper
    utils.write_text(utils_text, encoding='utf-8')

print('Correctif applique.')
PY

python3 "$ROOT/tools/build_monolith.py"
