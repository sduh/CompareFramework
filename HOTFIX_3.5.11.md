# CompareFramework V3.5.11 — Hotfix Release Readiness autonome

## Problème

`CF_BuildReleaseReadiness()` considérait les feuilles absentes comme un échec définitif :

- `CF_Quality_Dashboard`
- `CF_Typed_Regression`

La décision dépendait donc de l'historique du classeur, même lorsque les tests avaient déjà été exécutés avec succès.

## Correction

`CF_BuildReleaseReadiness()` est désormais autonome :

1. détecte les preuves techniques manquantes ;
2. relance `CF_RunGlobalRegression()` uniquement si nécessaire ;
3. reconstruit `CF_Quality_Dashboard` ;
4. recalcule les statuts ;
5. indique si les preuves ont été `PRESENTES` ou `RECONSTRUITES`.

## Validation

1. Exécuter `CF_RunAllBusinessScenarios()`.
2. Exécuter `CF_BuildReleaseReadiness()`.
3. Vérifier :
   - Scénarios métier = `OK`
   - Tableau de bord qualité = `OK`
   - Régression typée = `OK`
   - Décision = `RELEASE CANDIDATE`
