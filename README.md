# CompareFramework V3.7.0-D1 — Mode Référence

Premier livrable du Jalon D.

## Cas d'usage

Une feuille sert de référence et toutes les autres feuilles métier sont comparées à celle-ci.

Exemple :

- référence : `MODELE`
- identifiant : `ref_scat_abs`
- cibles : toutes les autres feuilles métier

## Installation modulaire

Ajouter `src/Modes/CF_ModeReference.bas` aux modules V3.6.3.

## Installation monolithique

Importer uniquement :

`dist/CompareFramework_3_7_0_D1_Monolith.bas`

## Macros

### Preset pour le classeur fourni

```basic
CF_RunAgainstReference_MODELE()
```

### Mode interactif

```basic
CF_RunReferenceMode()
```

### API

```basic
CF_RunAgainstReference "MODELE", "ref_scat_abs"
```

## Résultats

Le mode réutilise les rapports existants :

- `Rapport_Comparaison`
- `Stats_Comparaison`
- `Synthese_Comparaison`
- `Plan_Action_Comparaison`
- `Journal_Comparaison`

Il ajoute :

- `Compare_Reference_Plan`

Cette feuille indique les cibles planifiées, comparées ou ignorées.
