# Procédure de release D4

1. Vérifier que le dépôt est propre.
2. Exécuter `python3 tools/build_monolith.py`.
3. Importer le monolithe généré dans un classeur Calc de test.
4. Exécuter la validation stable.
5. Tester `CF_OpenReferenceLauncher()` et `CF_RunFromLauncher()`.
6. Vérifier `Compare_Reference_Plan` et `Compare_Reference_Summary`.
7. Committer ensemble les changements de `src/` et le contenu régénéré de `dist/`.
8. Créer le tag de release uniquement après validation Calc.
