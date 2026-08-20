# D2-03.9 — Deuxième vague multi-procédures de réduction de l'API publique

## Statut
**VALIDATED**

## Périmètre
Vague limitée à `src/CompareFramework_Reliability.bas`.

Deux procédures `local-only` / confiance `high` passent de `Public` à `Private` :
- `CF_RunTypedRegressionSuite`
- `CF_BuildComparatorCoverageReport`

## Mesure cumulative
```text
Baseline D2-03.1 Public  : 204
Après D2-03.9            : 177
Baseline D2-03.1 Private : 81
Après D2-03.9            : 108
```
Réduction cumulée : **27 procédures publiques**.

## Validation
- 0 appel connu non résolu;
- 0 appel ambigu;
- monolithe reconstruit : PASS;
- tests de visibilité D2-03.2 à D2-03.9 : PASS;
- régressions analyseur : PASS;
- déterminisme : PASS.

Aucune modification de `CompareFramework_API.bas`.
