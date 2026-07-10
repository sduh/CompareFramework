# CompareFramework V2.5 - Execution Context

Cette version ajoute un **contexte d'exécution centralisé** pour préparer le remplacement progressif des variables globales.

## Nouveaux fichiers

- `CompareFramework_Context.bas`

## API contexte

- `CF_ContextReset()`
- `CF_ContextSet(key, value)`
- `CF_ContextGet(key, default)`
- `CF_ContextHas(key)`
- `CF_ContextCount()`
- `CF_ContextBeginRun(runName)`
- `CF_ContextEndRun(status)`
- `CF_ContextDumpToSheet()`

## Nouveaux wrappers

- `ComparerToutesLesFeuilles_Contextualisee()`
- `DiagnosticFramework_Contextualise()`

Ces wrappers n'imposent pas encore le contexte au moteur historique.
Ils permettent de commencer la migration sans casser l'API existante.

## Tests

- `CF_RunAllTests()` : tests de base V2.4.
- `CF_RunContextTests()` : tests du contexte V2.5.

## Ordre d'import recommandé

Voir `MODULE_ORDER.txt`.

Généré le 2026-07-09 15:13:50.
