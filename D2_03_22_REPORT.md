# D2-03.22 — Résolution des conflits documentaires

## Statut
**VALIDATED**

## Décision
Les deux procédures encore documentées comme points d'entrée alors que les
inventaires les classaient `candidate-private-after-regression` sont retirées
des guides utilisateur au profit de la façade officielle `CompareFramework_API`.

Procédures concernées :
- `CompareFramework_Main.CF_RunAudited`
- `CompareFramework_Main.ComparerToutesLesFeuilles_Legacy`

Elles passent ensuite de `Public` à `Private`.

## Documentation
`README.md` et `docs/USER_GUIDE.md` présentent désormais comme points d'entrée
principaux :
- `CF_RunStandardComparison`
- `CF_StartReferenceComparison`

## État après D2-03.22
```text
Public                         : 120
Private                        : 165
Réduction cumulative Public    : 84

Entrypoints restant à revoir   : 8
API officielles Public         : 6
Maintenance/test               : 2
Conflits documentation         : 0
```

## Validation
- documentation réconciliée : PASS;
- 2 changements Public -> Private : PASS;
- audit résiduel cohérent : PASS;
- tests cumulatifs : PASS;
- monolithe reconstruit : PASS;
- 0 appel connu non résolu;
- 0 appel ambigu;
- déterminisme : PASS.
