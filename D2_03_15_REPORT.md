# D2-03.15 — Vague contrôlée sur CompareFramework_Main

## Statut
**VALIDATED**

## Revue renforcée des points d'entrée
L'analyse D2-03.1 proposait cinq candidats `local-only` / confiance `high` dans
`CompareFramework_Main`. La revue de l'inventaire public historique
`docs/audit/PUBLIC_SYMBOL_INVENTORY.csv` distingue toutefois `GetFrameworkVersion`
comme **Advanced API / Keep Public**.

La vague applique donc la privatisation à quatre procédures seulement :
- `CompareDetectedPairs`
- `CompareFallbackTwoSheets`
- `CompareSheetPair`
- `CF_RunMilestoneB_Configured`

`GetFrameworkVersion` reste explicitement **Public**.

## Mesure cumulative
```text
Baseline D2-03.1 Public  : 204
Après D2-03.15           : 156
Baseline D2-03.1 Private : 81
Après D2-03.15           : 129
```
Réduction cumulée : **48 procédures publiques**.

## Validation
- 0 appel connu non résolu;
- 0 appel ambigu;
- monolithe reconstruit : PASS;
- tests de visibilité D2-03.2 à D2-03.15 : PASS;
- régressions analyseur : PASS;
- déterminisme : PASS;
- `GetFrameworkVersion` vérifié Public dans source et monolithe : PASS.

## Décision
La qualification `local-only` n'écrase pas une décision explicite de contrat
public documentée. Cette règle doit être conservée pour les vagues suivantes.
