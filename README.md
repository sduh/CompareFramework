# CompareFramework V2.8 - Execution Audit

Cette version ajoute un historique d'exécution persistant dans la feuille `Compare_Audit`.

## Nouveau module

- `CompareFramework_Audit.bas`

## Nouveau point d'entrée recommandé

- `CF_RunAudited()`

Ce point d'entrée :

1. démarre le contexte et l'audit ;
2. valide le framework ;
3. lance la comparaison ;
4. enregistre le statut, la durée et les erreurs ;
5. écrit une ligne dans `Compare_Audit`.

## API d'audit

- `CF_AuditBegin(runName)`
- `CF_AuditSet(metricName, value)`
- `CF_AuditFail(errorNumber, message)`
- `CF_AuditEnd(status)`
- `CF_AuditWriteCurrentRun()`
- `CF_AuditClearHistory()`
- `CF_AuditGetRunId()`
- `CF_AuditDurationSeconds()`

## Tests

- `CF_RunAuditTests()`

## Feuille créée

`Compare_Audit` contient :

- Run ID ;
- nom de l'exécution ;
- début / fin ;
- durée ;
- statut ;
- profil ;
- document ;
- erreur ;
- message ;
- métriques.

Généré le 2026-07-10 07:03:08.
