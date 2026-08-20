# D2-03.6 — Cinquième réduction contrôlée de l'API publique

## Statut
**VALIDATED**

## Périmètre
Vague limitée à `src/CompareFramework_Performance.bas`.

`CF_PerfRecordPair` passe de `Public` à `Private`.

## Mesure cumulative
```text
Baseline D2-03.1 Public  : 204
Après D2-03.6            : 182
Baseline D2-03.1 Private : 81
Après D2-03.6            : 103
```

Réduction cumulée : **22 procédures publiques**.

## Validation
- qualification : `local-only`, confiance `high`;
- 0 appel connu non résolu;
- 0 appel ambigu;
- monolithe reconstruit : PASS;
- tests de visibilité D2-03.2 à D2-03.6 : PASS;
- régressions analyseur : PASS;
- déterminisme : PASS.

Aucune modification de la façade `CompareFramework_API.bas`.
