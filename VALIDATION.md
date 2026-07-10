# VALIDATION V3.5

Dans LibreOffice Calc :

1. Importer les modules dans l'ordre indiqué par `MODULE_ORDER.txt`.
2. Exécuter `CF_RunGlobalRegression()`.
3. Exécuter `CF_RunAllBusinessScenarios()`.
4. Ouvrir `CF_Release_Readiness`.
5. Vérifier que la décision est `RELEASE CANDIDATE`.
6. Exécuter `CF_RunMilestoneC_Final()` pour un run audité complet.

En cas d'échec :
- consulter `CF_Quality_Dashboard`,
- consulter `CF_Scenario_Results`,
- consulter `Compare_Audit`,
- comparer avec `ComparerToutesLesFeuilles_Legacy()`.
