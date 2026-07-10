# CompareFramework V3.6 Stable

Première version consolidée et validée sous LibreOffice Calc.

## Fichier principal

- `CompareFramework_Stable.bas`

Importer ce fichier dans un module Basic d'un classeur de test ou de production.

## Validation finale

Exécuter :

```basic
CF_RunStableValidation()
```

Cette macro lance :

1. la régression globale ;
2. les scénarios métier Finance, RH et ERP ;
3. la construction de `CF_Release_Readiness` ;
4. l'audit final.

## Résultat attendu

Dans `CF_Release_Readiness` :

- Scénarios métier : `OK`
- Tableau de bord qualité : `OK`
- Régression typée : `OK`
- Décision : `RELEASE CANDIDATE`

Dans `Compare_Audit`, la dernière exécution doit avoir le statut `DONE`.

## Version

- Version API : `3.6`
- Canal : `Stable`
- SHA-256 du monolithe : `b178b9faf5d6eadc19ad09f928bec47cda345640ef57cf72da4420951f822347`

Cette release consolide les correctifs 3.5.2 à 3.5.11.
