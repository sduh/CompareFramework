# CompareFramework V3.5 — Jalon C final : stabilisation

Cette version clôt fonctionnellement le **Jalon C** sous réserve de validation dans LibreOffice Calc.

## Nouveau module

- `CompareFramework_Scenarios.bas`

## Scénarios métier

- Finance
- RH
- ERP

Chaque scénario génère ses feuilles OLD/NEW, exécute le moteur puis vérifie les écarts attendus.

## Macros principales

- `CF_RunFinanceScenario()`
- `CF_RunHRScenario()`
- `CF_RunERPScenario()`
- `CF_RunAllBusinessScenarios()`
- `CF_BuildReleaseReadiness()`
- `CF_RunMilestoneC_Final()`

## Feuilles générées

- `CF_Scenario_Results`
- `CF_Release_Readiness`

## Décision de release

`CF_Release_Readiness` affiche :

- `RELEASE CANDIDATE` si tous les contrôles sont au vert ;
- `A CONTROLER` sinon.

## Ordre conseillé

1. `CF_RunGlobalRegression()`
2. `CF_RunAllBusinessScenarios()`
3. `CF_RunMilestoneC_Final()`

Le prochain jalon sera **Jalon D — ergonomie, documentation et distribution**.

Généré le 2026-07-10 07:44:22.
