# CompareFramework V3.5.7 — Hotfix validation Compare_Comparators

## Cause

La feuille utilise le schéma :

`Enabled | Profile | Column | Comparator | Tolerance | Comment`

Le validateur lisait à tort :

`Profile | Column | Comparator | Tolerance`

Il interprétait donc `TRUE` comme un profil, `GLOBAL` comme une colonne et `*` comme un type.

## Correction

- lecture des six colonnes dans le bon ordre ;
- validation explicite de `Enabled` ;
- utilisation du parseur numérique compatible avec la locale ;
- restitution du commentaire dans `CF_Comparator_Validation`.

## Validation

Exécuter :

1. `CF_ValidateComparatorRules()`
2. Vérifier que les quatre lignes sont `OK`.
3. `CF_RunMilestoneB_FinalTests()`
