# CompareFramework V3.2 - Jalon B configurable comparators

Cette version rend les comparateurs typés configurables par **profil** et par **colonne**.

## Nouvelle feuille

`Compare_Comparators` contient :

- `Enabled`
- `Profile`
- `Column`
- `Comparator`
- `Tolerance`
- `Comment`

## Priorité des règles

1. profil actif + colonne exacte ;
2. `GLOBAL` + colonne exacte ;
3. profil actif + `*` ;
4. `GLOBAL` + `*` ;
5. détection automatique V3.1.

## Types acceptés

- `AUTO`
- `TEXT`
- `NUMBER`
- `DATE`
- `BOOLEAN`
- `PERCENT`
- `CURRENCY`

## Macros

- `CF_OpenComparatorConfig()`
- `CF_ReloadComparatorConfig()`
- `CF_RunComparatorConfigTests()`
- `CF_RunMilestoneB_ConfigTests()`
- `CF_RunMilestoneB_Configured()`

L'ancien moteur reste disponible via `ComparerToutesLesFeuilles_Legacy()`.

Généré le 2026-07-10 07:31:09.
