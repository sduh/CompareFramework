# CompareFramework V3.5.8 — Hotfix tolérances décimales

## Problème

La tolérance `0.01` était déclarée non numérique sur une installation française.

Le parseur remplaçait les virgules par des points, puis appelait `CDbl()`.
Or `CDbl()` reste dépendant de la locale et peut attendre `0,01`.

## Correction

`CF_CC_TryParseDouble()` :

- accepte `0.01` et `0,01` ;
- supprime les espaces ordinaires et insécables ;
- valide les caractères numériques ;
- utilise `Val()` sur une représentation normalisée avec point ;
- ne dépend plus du séparateur décimal de LibreOffice.

## Validation

1. Compiler le module.
2. Exécuter `CF_ValidateComparatorRules()`.
3. Vérifier que la règle FINANCE / Montant / CURRENCY / 0.01 est `OK`.
4. Exécuter `CF_RunMilestoneB_FinalTests()`.
