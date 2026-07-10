# Procédure de test D3

1. Importer le monolithe D3 ou le module `CF_ModeReference.bas`.
2. Compiler.
3. Exécuter `CF_OpenReferenceLauncher()`.
4. Vérifier la feuille `Compare_Launcher`.
5. Tester `TARGET_MODE = ALL`.
6. Exécuter `CF_RunFromLauncher()`.
7. Vérifier que toutes les feuilles cibles sont comparées.
8. Revenir dans `Compare_Launcher`.
9. Mettre `TARGET_MODE = SELECTED`.
10. Mettre `SELECTED_TARGETS = 3pmg_001;aedev_936`.
11. Relancer `CF_RunFromLauncher()`.
12. Vérifier que seules ces deux feuilles apparaissent dans `Compare_Reference_Plan` et `Compare_Reference_Summary`.
