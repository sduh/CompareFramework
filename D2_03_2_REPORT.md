# D2-03.2 — Première réduction contrôlée de l'API publique

## Statut

**VALIDATED**

## Périmètre

La première vague est volontairement limitée à
`src/CompareFramework_Comparators.bas`.

Seules les procédures classées `local-only` avec confiance `high` par
D2-03.1 ont été modifiées.

## Modification

**17 procédures** passent de `Public` à `Private` :

- `CF_ComparatorTypeForHeader`
- `CF_TextEqual`
- `CF_NumberEqual`
- `CF_DateEqual`
- `CF_BooleanEqual`
- `CF_LooksNumeric`
- `CF_LooksDate`
- `CF_LooksBoolean`
- `CF_TryParseNumber`
- `CF_TryParseDateSerial`
- `CF_BooleanCode`
- `CF_PercentToNumber`
- `CF_CurrencyToNumber`
- `CF_GetNumericTolerance`
- `CF_GetPercentTolerance`
- `CF_GetCurrencyTolerance`
- `CF_GetDateToleranceDays`

## Mesure avant / après

```text
Public avant : 204
Public après : 187

Private avant : 81
Private après : 98

Réduction de surface Public : 17 procédures
```

## Validation d'impact

- aucun appel inter-module entrant vers les 17 procédures avant modification ;
- graphe d'appels après modification : 0 appel connu non résolu ;
- graphe d'appels après modification : 0 appel ambigu ;
- build du monolithe : PASS ;
- contrôles statiques du build : PASS ;
- tests A1.5/B/C/D/D2-03.1 : PASS ;
- test de visibilité D2-03.2 : PASS ;
- sorties de l'analyseur déterministes : PASS.

## Compatibilité

La façade officielle `CompareFramework_API.bas` n'est pas modifiée.

Aucune procédure de `CompareFramework_Main.bas`,
`CF_ModeReference.bas` ou de la façade API n'est concernée par cette première
vague.

## Artefact de changement

`CompareFramework_D2-03.2.patch`

## Décision

Cette première vague est suffisamment isolée pour servir de référence aux
vagues suivantes. Aucun autre candidat D2-03.1 n'est privatisé dans ce jalon.
