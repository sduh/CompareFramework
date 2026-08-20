# D2-03.12 — Deuxième lot de trois procédures

## Statut
**VALIDATED**

## Périmètre
Vague limitée à `src/CompareFramework_Scenarios.bas`.

Trois procédures `local-only` / confiance `high` passent de `Public` à `Private` :
- `CF_RunFinanceScenario`
- `CF_RunHRScenario`
- `CF_RunERPScenario`

## Mesure cumulative
```text
Baseline D2-03.1 Public  : 204
Après D2-03.12           : 169
Baseline D2-03.1 Private : 81
Après D2-03.12           : 116
```
Réduction cumulée : **35 procédures publiques**.

## Validation
- 0 appel connu non résolu;
- 0 appel ambigu;
- monolithe reconstruit : PASS;
- tests de visibilité D2-03.2 à D2-03.12 : PASS;
- régressions analyseur : PASS;
- déterminisme : PASS.

Cette étape clôt les lots de trois procédures issus de l'analyse courante.
Aucune modification de `CompareFramework_API.bas`.
