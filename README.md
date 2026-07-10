# CompareFramework V2.7 - Validation et préflight

Cette version ajoute une étape de validation avant comparaison.

## Nouveau module

- `CompareFramework_Validation.bas`

## Macros principales

- `CF_ValidateFramework()` : contrôle modules, feuilles, règles, profils et paires source.
- `CF_ValidateActiveProfile()` : vérifie que le profil actif existe.
- `CF_PreflightComparison()` : validation globale.
- `CF_RunValidated()` : lance la comparaison seulement si le préflight réussit.
- `CF_RunValidationTests()` : test rapide de la couche de validation.

## Sortie

Les résultats sont écrits dans la feuille `Compare_Validation` avec niveaux `OK`, `WARNING`, `ERROR` et une synthèse.

## Compatibilité

Les anciennes macros restent disponibles. Pour un usage sécurisé, utiliser `CF_RunValidated()`.
