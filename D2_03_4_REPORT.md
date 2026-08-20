# D2-03.4 — Troisième réduction contrôlée de l'API publique

## Statut

**VALIDATED**

## Périmètre

Cette vague est limitée à `src/CompareFramework_Audit.bas`.

Une seule procédure `local-only` / confiance `high` passe de `Public` à
`Private` :

- `CF_AuditWriteCurrentRun`

## Mesure cumulative

```text
Baseline D2-03.1 Public : 204
Après D2-03.2          : 187
Après D2-03.3          : 185
Après D2-03.4          : 184

Baseline D2-03.1 Private : 81
Après D2-03.2            : 98
Après D2-03.3            : 100
Après D2-03.4            : 101
```

Réduction cumulée de la surface publique : **20 procédures**.

## Validation

- aucun appel inter-module entrant avant modification ;
- 0 appel connu non résolu après modification ;
- 0 appel ambigu ;
- monolithe reconstruit : PASS ;
- tests D2-03.2 et D2-03.3 : PASS ;
- test D2-03.4 : PASS ;
- régressions analyseur A1.5/B/C/D/D2-03.1 : PASS ;
- sorties analyseur déterministes : PASS.

## Impact

Aucune modification de `CompareFramework_API.bas`.
Aucun changement fonctionnel du moteur.

## Patch

`CompareFramework_D2-03.4.patch`
