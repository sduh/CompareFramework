# CompareFramework V2.4 - Test Suite

Cette version ajoute un socle de tests intégrés directement utilisable dans LibreOffice Calc.

## Modules

Importer de préférence dans cet ordre :

1. `CompareFramework_Utils.bas`
2. `CompareFramework_Config.bas`
3. `CompareFramework_Index.bas`
4. `CompareFramework_Rules.bas`
5. `CompareFramework_Report.bas`
6. `CompareFramework_Tests.bas`
7. `CompareFramework_Main.bas`

## Macros principales

- `ComparerToutesLesFeuilles()` : lance la comparaison.
- `ExporterRapportHTML()` : génère le rapport HTML.
- `CF_CreateTestWorkbook()` : crée les feuilles de test `CF_Test_OLD` et `CF_Test_NEW`.
- `CF_RunAllTests()` : exécute les tests intégrés et crée `CF_Test_Resultats`.

## Objectif V2.4

La V2.4 ne cherche pas seulement à ajouter une fonctionnalité visible.
Elle ajoute une base de validation pour éviter les régressions avant les futures versions.

## Résultat attendu des tests

`CF_RunAllTests()` doit produire :

- création correcte des feuilles OLD/NEW ;
- vérification des en-têtes ;
- présence d'une ligne ajoutée ;
- présence d'une ligne supprimée ;
- présence d'une ligne modifiée ;
- stabilité d'une ligne inchangée.

Généré le 2026-07-09 15:09:44.
