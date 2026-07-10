# CompareFramework V3.6.1 Stable

## Correction

`CF_RunPerformanceTests()` créait `Compare_Performance` mais pas la feuille
`CF_Test_Performance` attendue par `CF_Quality_Dashboard`.

La macro crée désormais explicitement `CF_Test_Performance` avec :

- test du chronométrage ;
- test de génération de `Compare_Performance` ;
- synthèse `OK` ou `A CONTROLER`.

## Validation

1. Compiler le module.
2. Exécuter `CF_RunPerformanceTests()`.
3. Vérifier la présence de `CF_Test_Performance`.
4. Exécuter `CF_BuildQualityDashboard()`.
5. Vérifier que l'indicateur Performance est `OK`.
6. Exécuter `CF_RunStableValidation()`.
