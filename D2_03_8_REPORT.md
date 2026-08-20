# D2-03.8 — Première vague multi-procédures de réduction de l'API publique

## Statut
**VALIDATED**

## Périmètre
Vague limitée à `src/CompareFramework_Profiles.bas`.

Deux procédures `local-only` / confiance `high` passent de `Public` à `Private` :

- `CF_WriteDefaultProfiles`
- `CF_ApplyProfile`

## Mesure cumulative
```text
Baseline D2-03.1 Public  : 204
Après D2-03.8            : 179
Baseline D2-03.1 Private : 81
Après D2-03.8            : 106
```

Réduction cumulée : **25 procédures publiques**.

## Validation
- qualification D2-03.1 : `local-only`, confiance `high`;
- 0 appel connu non résolu;
- 0 appel ambigu;
- monolithe reconstruit : PASS;
- tests de visibilité D2-03.2 à D2-03.8 : PASS;
- régressions analyseur : PASS;
- déterminisme : PASS.

Aucune modification de la façade `CompareFramework_API.bas`.
