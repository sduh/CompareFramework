# CompareFramework V3.5.3 — Hotfix Performance Round

Correction des appels restants à `Round()` dans `CF_PerfWriteReport`.

Les deux expressions suivantes utilisent désormais `CF_RoundCompat()` :

- durée des phases ;
- durée des paires de feuilles.

## Validation recommandée

1. Compiler le module.
2. Exécuter `CF_RunPerformanceTests()`.
3. Vérifier l'absence d'erreur 35.
4. Vérifier les feuilles `CF_Test_Performance` et `Compare_Performance`.
5. Réexécuter `CF_RunAuditTests()` pour confirmer l'absence de régression.
