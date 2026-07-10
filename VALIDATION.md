# VALIDATION V3.6 STABLE

## Préparation

1. Utiliser un classeur Calc dédié.
2. Enregistrer le classeur au format `.ods`.
3. Importer `CompareFramework_Stable.bas`.
4. Compiler le module.

## Validation recommandée

Exécuter :

```basic
CF_RunStableValidation()
```

## Contrôles

Vérifier :

- `CF_Release_Readiness` : décision `RELEASE CANDIDATE`
- `CF_Scenario_Results` : FINANCE, RH et ERP en `OK`
- `CF_Quality_Dashboard` : statut global `OK`
- `CF_Typed_Regression` : 12/12
- `Compare_Validation` : synthèse `OK`
- `Compare_Audit` : dernière exécution `DONE`

## Export HTML

Après génération d'un rapport :

```basic
ExporterRapportHTML()
```

Le fichier `Rapport_Comparaison.html` doit être créé à côté du classeur.
