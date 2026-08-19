#!/usr/bin/env python3
from __future__ import annotations
import csv, json, re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'src'
OUT = ROOT / 'docs' / 'audit'
OUT.mkdir(parents=True, exist_ok=True)

PROC_RE = re.compile(r'^\s*(Public|Private)?\s*(Sub|Function)\s+([A-Za-z_][A-Za-z0-9_]*)\b', re.I)
CALL_TOKEN_RE = re.compile(r'\b([A-Za-z_][A-Za-z0-9_]*)\b')
KEYWORDS = {x.lower() for x in '''If Then Else ElseIf End Sub Function For Each Next Do Loop While Wend Select Case Dim As ByRef ByVal Optional Public Private On Error GoTo Resume Exit Call Let Set And Or Not Mod True False Nothing String Long Integer Double Boolean Variant Object UCase LCase CStr CLng CDbl CInt Val Trim Left Right Mid Len IsNull IsEmpty Array LBound UBound MsgBox Chr RGB ThisComponent'''.split()}
OFFICIAL_API = {
    'CF_StartReferenceComparison','CF_RunStandardComparison','CF_ExportLastReportHTML',
    'CF_OpenSettings','CF_RunDiagnostics','CF_RunReleaseValidation'
}

files = sorted(SRC.rglob('*.bas'))
procedures = []
proc_by_name = {}
lines_by_file = {}
for path in files:
    rel = path.relative_to(ROOT).as_posix()
    lines = path.read_text(encoding='utf-8').splitlines()
    lines_by_file[rel] = lines
    current = None
    for idx, line in enumerate(lines, 1):
        m = PROC_RE.match(line)
        if m:
            visibility = (m.group(1) or 'Public').title()
            kind = m.group(2).title()
            name = m.group(3)
            current = {'name':name,'visibility':visibility,'kind':kind,'module':rel,'line':idx,'end_line':idx}
            procedures.append(current); proc_by_name[name.lower()] = current
        elif current:
            current['end_line'] = idx
            if re.match(r'^\s*End\s+(Sub|Function)\b', line, re.I):
                current = None

# references/calls, ignoring declaration line and comments
refs = defaultdict(list)
module_edges = defaultdict(set)
for rel, lines in lines_by_file.items():
    for idx, raw in enumerate(lines, 1):
        code = raw.split("'",1)[0]
        if PROC_RE.match(code):
            continue
        for tok in CALL_TOKEN_RE.findall(code):
            p = proc_by_name.get(tok.lower())
            if p and p['module'] != rel:
                refs[p['name']].append((rel, idx))
                module_edges[rel].add(p['module'])
            elif p:
                refs[p['name']].append((rel, idx))

# classify
for p in procedures:
    calls = refs.get(p['name'], [])
    ext_calls = [c for c in calls if c[0] != p['module']]
    p['reference_count'] = len(calls)
    p['external_reference_count'] = len(ext_calls)
    if p['visibility'] != 'Public':
        p['classification'] = 'private-existing'
        p['recommendation'] = 'keep-private'
    elif p['name'] in OFFICIAL_API:
        p['classification'] = 'official-api'
        p['recommendation'] = 'keep-public'
    elif p['module'].endswith('CompareFramework_Tests.bas') or p['module'].endswith('CompareFramework_Scenarios.bas') or p['name'].lower().startswith(('cf_test','cf_run')) and ('test' in p['name'].lower() or 'regression' in p['name'].lower()):
        p['classification'] = 'maintenance-test'
        p['recommendation'] = 'review-public-maintenance'
    elif not ext_calls:
        p['classification'] = 'module-internal-candidate'
        p['recommendation'] = 'candidate-private-after-regression'
    else:
        p['classification'] = 'cross-module-internal'
        p['recommendation'] = 'keep-public-until-service-boundary'

# CSV inventory
fields = ['module','line','end_line','visibility','kind','name','classification','recommendation','reference_count','external_reference_count']
with (OUT/'D1_PUBLIC_API_INVENTORY.csv').open('w', newline='', encoding='utf-8') as f:
    w=csv.DictWriter(f, fieldnames=fields); w.writeheader();
    for p in procedures: w.writerow({k:p[k] for k in fields})

# dependency CSV
with (OUT/'D1_DEPENDENCY_MAP.csv').open('w', newline='', encoding='utf-8') as f:
    w=csv.writer(f); w.writerow(['source_module','target_module'])
    for s in sorted(module_edges):
        for t in sorted(module_edges[s]): w.writerow([s,t])

# Tarjan SCC
nodes = sorted(lines_by_file)
index=0; stack=[]; on=set(); idxs={}; low={}; scc=[]
def strong(v):
    global index
    idxs[v]=low[v]=len(idxs); stack.append(v); on.add(v)
    for w in module_edges.get(v,set()):
        if w not in idxs: strong(w); low[v]=min(low[v],low[w])
        elif w in on: low[v]=min(low[v],idxs[w])
    if low[v]==idxs[v]:
        comp=[]
        while True:
            w=stack.pop(); on.remove(w); comp.append(w)
            if w==v: break
        scc.append(sorted(comp))
for n in nodes:
    if n not in idxs: strong(n)
cycles=[c for c in scc if len(c)>1]

# module metrics
metrics=[]
for rel, lines in lines_by_file.items():
    ps=[p for p in procedures if p['module']==rel]
    metrics.append({
        'module':rel,'loc':len(lines),'procedures':len(ps),
        'public':sum(p['visibility']=='Public' for p in ps),
        'private':sum(p['visibility']=='Private' for p in ps),
        'outgoing_dependencies':len(module_edges.get(rel,set())),
        'incoming_dependencies':sum(rel in ts for ts in module_edges.values())
    })
with (OUT/'D1_MODULE_METRICS.csv').open('w', newline='', encoding='utf-8') as f:
    w=csv.DictWriter(f, fieldnames=list(metrics[0])); w.writeheader(); w.writerows(metrics)

public=[p for p in procedures if p['visibility']=='Public']
private=[p for p in procedures if p['visibility']=='Private']
candidates=[p for p in public if p['recommendation']=='candidate-private-after-regression']
report = f'''# CompareFramework 4.0-D1 — Architectural Cleanup Report

## Scope

This milestone establishes architecture boundaries without changing functional behavior. No existing public procedure has been made `Private` in D1.

## Baseline

- Modules analyzed: **{len(files)}**
- Source lines: **{sum(len(v) for v in lines_by_file.values())}**
- Procedures: **{len(procedures)}**
- Public procedures: **{len(public)}**
- Private procedures: **{len(private)}**
- Official supported API entries: **{len(OFFICIAL_API)}**
- Safe-review candidates with no cross-module references: **{len(candidates)}**
- Module dependency edges: **{sum(len(v) for v in module_edges.values())}**
- Dependency cycles (SCC > 1): **{len(cycles)}**

## Supported public facade

The only supported user-facing API is defined in `src/CompareFramework_API.bas`:

'''+''.join(f'- `{name}`\n' for name in sorted(OFFICIAL_API))+f'''

All other `Public` procedures are compatibility or implementation symbols. Their visibility is unchanged in D1.

## Visibility strategy

1. D1 classifies symbols only.
2. A symbol can become `Private` only after its callers are migrated behind a service boundary.
3. Legacy user macros require wrappers or a documented breaking-change decision before removal.
4. Each visibility batch must pass the complete regression suite.

## Large-module preparation

### `CompareFramework_Report.bas`

Target split for a later milestone:

- report sheet writing and formatting;
- statistics and dashboard generation;
- action plan generation;
- HTML serialization and file output.

### `Modes/CF_ModeReference.bas`

Target split for a later milestone:

- launcher/UI sheet;
- target discovery and selection;
- reference comparison orchestration;
- summary generation and formatting.

D1 does not move any procedure, preventing accidental dependency or Basic visibility regressions.

## Dependency cycles

'''+('\n'.join('- '+ ' -> '.join(c) for c in cycles) if cycles else '- No multi-module cycle detected.')+f'''

## D1 decision

**PASS for architectural preparation.** The supported API is explicit, migration candidates are inventoried, large-module split boundaries are defined, and the dependency graph is reproducible.

## Generated evidence

- `D1_PUBLIC_API_INVENTORY.csv`
- `D1_DEPENDENCY_MAP.csv`
- `D1_MODULE_METRICS.csv`
- `D1_ARCHITECTURE_SNAPSHOT.json`
'''
(OUT/'D1_ARCHITECTURAL_CLEANUP.md').write_text(report, encoding='utf-8')

snapshot={
 'milestone':'4.0-D1','modules':len(files),'loc':sum(len(v) for v in lines_by_file.values()),
 'procedures':len(procedures),'public_procedures':len(public),'private_procedures':len(private),
 'official_api':sorted(OFFICIAL_API),'private_review_candidates':len(candidates),
 'dependency_edges':sum(len(v) for v in module_edges.values()),'cycles':cycles,
 'largest_modules':sorted(metrics,key=lambda x:x['loc'],reverse=True)[:5]
}
(OUT/'D1_ARCHITECTURE_SNAPSHOT.json').write_text(json.dumps(snapshot,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps(snapshot,indent=2,ensure_ascii=False))
