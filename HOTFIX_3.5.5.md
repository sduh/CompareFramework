# CompareFramework V3.5.5 — Hotfix API comparateurs

Correction de l'erreur :

`Erreur 35 - CF_CompareTypedValues non définie`

## Cause

La suite de régression V3.3 appelait l'ancienne API
`CF_CompareTypedValues()`, alors que le moteur V3.1 exposait uniquement
`CF_TypedValuesEqual()`.

## Correction

Ajout d'un adaptateur public `CF_CompareTypedValues()` qui route vers :

- `CF_TextEqual`
- `CF_NumberEqual`
- `CF_DateEqual`
- `CF_BooleanEqual`
- les conversions pourcentage et devise

## Validation

1. Compiler le module.
2. Exécuter `CF_RunTypedRegressionSuite()`.
3. Résultat attendu : `Régression typée OK : 12/12`.
4. Exécuter ensuite `CF_RunMilestoneB_FinalTests()`.
