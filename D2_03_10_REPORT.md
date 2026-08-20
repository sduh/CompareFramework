# D2-03.10 — Troisième vague multi-procédures de réduction de l'API publique

## Statut
**VALIDATED**

## Périmètre
Vague limitée à `src/CompareFramework_Validation.bas`.

Deux procédures `local-only` / confiance `high` passent de `Public` à `Private` :
- `CF_ValidateActiveProfile`
- `CF_PreflightComparison`

## Mesure cumulative
```text
Baseline D2-03.1 Public  : 204
Après D2-03.10           : 175
Baseline D2-03.1 Private : 81
Après D2-03.10           : 110
```
Réduction cumulée : **29 procédures publiques**.

## Validation
- 0 appel connu non résolu;
- 0 appel ambigu;
- monolithe reconstruit : PASS;
- tests de visibilité D2-03.2 à D2-03.10 : PASS;
- régressions analyseur : PASS;
- déterminisme : PASS.

Cette étape clôt les lots de deux procédures issus de l'analyse courante.
Aucune modification de `CompareFramework_API.bas`.
