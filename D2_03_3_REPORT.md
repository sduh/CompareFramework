# D2-03.3 — Deuxième réduction contrôlée de l'API publique

## Statut

**VALIDATED**

## Périmètre

Deuxième vague limitée à `src/CompareFramework_ComparatorConfig.bas`.

Deux procédures `local-only` / confiance `high` issues de D2-03.1 passent de
`Public` à `Private` :

- `CF_EnsureComparatorsSheet`
- `CF_WriteDefaultComparatorConfig`

## Mesure cumulative

```text
Baseline D2-03.1 Public : 204
Après D2-03.2          : 187
Après D2-03.3          : 185

Baseline D2-03.1 Private : 81
Après D2-03.2            : 98
Après D2-03.3            : 100
```

Réduction cumulée de la surface publique : **19 procédures**.

## Validation

- aucune dépendance inter-module entrante sur les 2 procédures avant modification ;
- 0 appel connu non résolu après modification ;
- 0 appel ambigu ;
- monolithe reconstruit : PASS ;
- tests D2-03.2 conservés : PASS ;
- tests D2-03.3 : PASS ;
- régressions analyseur A1.5/B/C/D/D2-03.1 : PASS ;
- sorties analyseur déterministes : PASS.

## Impact

Aucune modification de la façade publique officielle.
Aucun changement fonctionnel du moteur.

## Patch

`CompareFramework_D2-03.3.patch`
