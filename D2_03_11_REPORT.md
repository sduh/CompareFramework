# D2-03.11 — Premier lot de trois procédures

## Statut
**VALIDATED**

## Périmètre
Vague limitée à `src/CompareFramework_Quality.bas`.

Trois procédures `local-only` / confiance `high` passent de `Public` à `Private` :
- `CF_RunEndToEndScenario`
- `CF_ValidateExpectedReport`
- `CF_BuildQualityDashboard`

## Mesure cumulative
```text
Baseline D2-03.1 Public  : 204
Après D2-03.11           : 172
Baseline D2-03.1 Private : 81
Après D2-03.11           : 113
```
Réduction cumulée : **32 procédures publiques**.

## Validation
- 0 appel connu non résolu;
- 0 appel ambigu;
- monolithe reconstruit : PASS;
- tests de visibilité D2-03.2 à D2-03.11 : PASS;
- régressions analyseur : PASS;
- déterminisme : PASS.

Aucune modification de `CompareFramework_API.bas`.
