# CompareFramework V3.5.4 — Hotfix moteur mémoire

Correction de l'erreur :

`Erreur 9 - Index hors de la plage définie`

## Cause

`FindIdColumn(headers)` pouvait retourner `-1` lorsque les alias ID n'étaient pas encore chargés.
Le moteur essayait alors de lire `rowData(-1)`.

## Corrections

- Repli explicite sur l'en-tête `ID` dans `CF_RunMemoryEngineTests()`.
- Validation des bornes avant tout accès au tableau.
- Sécurisation de `CF_BuildMemoryIdIndex()` contre une colonne ID invalide.
- Diagnostic détaillé si le test n'atteint pas 3/3.

## Validation

1. Compiler le module.
2. Exécuter `CF_RunMemoryEngineTests()`.
3. Résultat attendu : `Tests moteur memoire : 3/3`.
4. Réexécuter `CF_RunPerformanceTests()` et `CF_RunAuditTests()`.
