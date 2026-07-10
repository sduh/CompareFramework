# CompareFramework V3.5.6 — Hotfix régression texte

## Problème

`CF_RunTypedRegressionSuite()` attendait que `Alpha` et `alpha` soient équivalents,
mais le résultat dépendait de la configuration globale `IGNORE_CASE`.

## Correction

La suite de régression :

1. mémorise la valeur courante de `gIgnoreCase` ;
2. active temporairement `gIgnoreCase = True` ;
3. exécute les 12 cas ;
4. restaure systématiquement la valeur initiale, même en cas d'erreur.

Le comportement métier normal du framework n'est donc pas modifié.

## Validation

Exécuter :

`CF_RunTypedRegressionSuite()`

Résultat attendu :

`Régression typée OK : 12/12`
