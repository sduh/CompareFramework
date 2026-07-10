# CompareFramework V3.4 — Jalon C : qualité globale

Cette version ouvre le **Jalon C** avec une suite de non-régression de bout en bout.

## Nouveau module

- `CompareFramework_Quality.bas`

## Nouveaux scénarios

- génération automatique de `QC_OLD` et `QC_NEW` ;
- génération des résultats attendus dans `CF_Expected` ;
- exécution du moteur ;
- contrôle automatique de `Rapport_Comparaison` ;
- tableau de bord qualité.

## Macros

- `CF_RunEndToEndScenario()`
- `CF_ValidateExpectedReport()`
- `CF_RunGlobalRegression()`
- `CF_BuildQualityDashboard()`
- `CF_RunMilestoneC()`

## Feuilles générées

- `QC_OLD`
- `QC_NEW`
- `CF_Expected`
- `CF_Quality_Results`
- `CF_Quality_Dashboard`

## Ordre conseillé

1. `CF_RunEndToEndScenario()`
2. `CF_RunGlobalRegression()`
3. `CF_RunMilestoneC()`

Le Jalon C sera considéré comme terminé après validation de plusieurs scénarios métier et d'un corpus plus large.

Généré le 2026-07-10 07:38:18.
