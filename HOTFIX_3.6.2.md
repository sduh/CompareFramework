# CompareFramework V3.6.2 Stable — Correction de l'audit final

## Problème observé

Après `CF_RunStableValidation()`, la dernière ligne de `Compare_Audit`
était nommée `ImplicitRun` au lieu de `CF_RunStableValidation`.

## Cause

Les suites de tests internes créaient et terminaient leurs propres audits.
Le run principal n'était donc plus actif quand les métriques finales étaient ajoutées.
`CF_AuditSet()` créait alors automatiquement un `ImplicitRun`.

## Correction

- ajout de `CF_AuditSuspend()` et `CF_AuditResume()` ;
- suspension de l'audit pendant les suites internes ;
- création d'un audit final propre après la validation complète ;
- dernière ligne attendue : `CF_RunStableValidation`, statut `DONE`.

## Validation

1. Importer et compiler `CompareFramework_Stable_3_6_2.bas`.
2. Exécuter `CF_RunStableValidation()`.
3. Vérifier la dernière ligne de `Compare_Audit` :
   - Exécution : `CF_RunStableValidation`
   - Statut : `DONE`
   - Métriques : `Release=3.6.2 Stable; Validation=COMPLETE`
