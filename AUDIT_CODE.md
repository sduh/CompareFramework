# AUDIT_CODE — CompareFramework 3.8.0 RC1

## Synthèse

Le code est globalement bien découpé. Aucun refactoring n'est bloquant avant la RC1.

Deux modules sont à surveiller :

- `src/Modes/CF_ModeReference.bas` — 670 lignes
- `src/CompareFramework_Report.bas` — 616 lignes

Ils restent acceptables pour la RC1, mais seront les premiers candidats à un découpage en V4.

## Évaluation

| Module | Lignes | Évaluation |
|---|---:|---|
| Index | 133 | Très cohérent |
| Rules | 185 | Cohérent |
| Report | 616 | À surveiller |
| Utils | 251 | Acceptable |
| Validation | 260 | Acceptable |
| Quality | 347 | Acceptable |
| Config | 220 | Cohérent |
| Reliability | 260 | Acceptable |
| Main | 466 | Important mais acceptable |
| Scenarios | 343 | Acceptable |
| Context | 177 | Cohérent |
| Tests | 485 | Important mais cohérent |
| ComparatorConfig | 214 | Cohérent |
| Performance | 189 | Cohérent |
| Comparators | 244 | Cohérent |
| Audit | 313 | Acceptable |
| ModeReference | 670 | À surveiller |
| EngineMemory | 372 | Important mais cohérent |
| Profiles | 202 | Cohérent |

## Modules à conserver avant RC1

Aucun découpage n'est recommandé avant publication pour :

- `Index`
- `Rules`
- `Config`
- `Context`
- `Profiles`
- `ComparatorConfig`
- `Comparators`
- `Performance`
- `EngineMemory`

Le moteur mémoire ayant été qualifié sur des données réelles, il ne doit pas être refactoré pendant la phase RC sauf défaut bloquant.

## Modules à surveiller

### `CompareFramework_Report.bas`

Découpage possible en V4 :

```text
Reports/
├── CF_ReportCore.bas
├── CF_ReportFormatting.bas
├── CF_ReportSummary.bas
├── CF_ReportActionPlan.bas
└── CF_ReportHtml.bas
```

Décision RC1 : conserver en l'état.

### `Modes/CF_ModeReference.bas`

Le module regroupe probablement :

- assistant de lancement ;
- sélection des cibles ;
- construction du plan ;
- orchestration ;
- synthèse consolidée ;
- formatage.

Découpage recommandé en V4 :

```text
Modes/Reference/
├── CF_ReferenceLauncher.bas
├── CF_ReferencePlan.bas
├── CF_ReferenceRunner.bas
├── CF_ReferenceSummary.bas
└── CF_ReferenceValidation.bas
```

Décision RC1 : conserver en l'état, car ce mode a été qualifié sur des données réelles.

## Autres observations

### `CompareFramework_Main.bas`

À 466 lignes, il reste acceptable s'il contient principalement les points d'entrée publics et l'orchestration.

### `CompareFramework_Tests.bas`

À 485 lignes, il est cohérent pour un module de tests. Un découpage par familles pourra être étudié en V4.

### `CompareFramework_Utils.bas`

À 251 lignes, il reste acceptable. Éviter toutefois d'y ajouter des fonctions spécifiques à un domaine.

## Décision RC-02

**État : favorable.**

Le code est suffisamment modulaire et maintenable pour une Release Candidate.

Aucun refactoring structurel n'est requis avant RC1.

À reporter en V4 :

1. découpage du Mode Référence ;
2. découpage éventuel du moteur de rapports ;
3. séparation des tests par familles ;
4. cartographie des dépendances entre modules.

## Conclusion

La taille des modules ne révèle aucune dette bloquante. Avant RC1, la meilleure décision est de préserver le code qualifié et d'éviter un refactoring risqué.
