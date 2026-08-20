# D2-03.20 — Audit explicite des points d'entrée sans appelant résolu

## Statut
**VALIDATED**

## Principe
D2-03.20 ne change aucune visibilité Basic.

Les 22 procédures restantes sont croisées avec les deux inventaires d'API et
les références dans la documentation utilisateur.

## Résultats

### API officielle — conserver Public
- `CompareFramework_API.CF_ExportLastReportHTML` — docs: docs/API_REFERENCE.md, STEP4_INTERACTIVE_CHECKLIST.md
- `CompareFramework_API.CF_OpenSettings` — docs: docs/API_REFERENCE.md
- `CompareFramework_API.CF_RunDiagnostics` — docs: docs/API_REFERENCE.md
- `CompareFramework_API.CF_RunReleaseValidation` — docs: docs/API_REFERENCE.md
- `CompareFramework_API.CF_RunStandardComparison` — docs: docs/API_REFERENCE.md
- `CompareFramework_API.CF_StartReferenceComparison` — docs: docs/API_REFERENCE.md, STEP4_INTERACTIVE_CHECKLIST.md

### Conflit documentation / candidature à la privatisation
- `CompareFramework_Main.CF_RunAudited` — docs: README.md, docs/USER_GUIDE.md
- `CompareFramework_Main.ComparerToutesLesFeuilles_Legacy` — docs: README.md

### Points d'entrée maintenance/test à décider explicitement
- `CompareFramework_Main.CF_RunMilestoneB_ConfigTests`
- `CompareFramework_Tests.CF_RunMilestoneBTests`

### Candidats à Private après régression et contrôle macros externes
- `CF_ModeReference.CF_RunLauncherQuick`
- `CompareFramework_Audit.CF_AuditClearHistory`
- `CompareFramework_ComparatorConfig.CF_ReloadComparatorConfig`
- `CompareFramework_Context.CF_ContextCount`
- `CompareFramework_Main.CF_RunMilestoneA`
- `CompareFramework_Main.CF_RunMilestoneB`
- `CompareFramework_Main.CF_RunMilestoneB_Final`
- `CompareFramework_Main.CF_RunMilestoneC`
- `CompareFramework_Main.CF_RunMilestoneC_Final`
- `CompareFramework_Main.CF_RunPerformanceProfiled`
- `CompareFramework_Main.ComparerToutesLesFeuilles_Contextualisee`
- `CompareFramework_Profiles.CF_ListProfiles`

### Non classés
- Aucun

## Statistiques
```text
Total audité                    : 22
API officielle                  : 6
Conflits documentation          : 2
Maintenance/test                : 2
Private après régression        : 12
Non classés                     : 0

Public avant/après D2-03.20     : 134 / 134
Private avant/après D2-03.20    : 151 / 151
```

## Modèle canonique
Schema : **1.5.0**

Nouveaux exports :
- `build/architecture/entrypoint_audit.json`
- `build/architecture/entrypoint_audit.csv`

## Validation
- aucune modification de visibilité source : PASS;
- 22 procédures classifiées : PASS;
- tests D2-03.2 à D2-03.20 : PASS;
- monolithe reconstruit : PASS;
- 0 appel connu non résolu;
- 0 appel ambigu;
- déterminisme : PASS.
