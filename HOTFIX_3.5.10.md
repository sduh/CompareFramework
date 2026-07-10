# CompareFramework V3.5.10 — Hotfix ordre de régression globale

## Problème

`CF_RunGlobalRegression()` exécutait `CF_RunValidationTests()` avant la création
des feuilles de test suffixées `_NEW`.

Le préflight retournait donc légitimement :

`ERROR | SOURCES | Aucune feuille suffixée _NEW.`

Les avertissements sur `Compare_Config` et `Compare_Rules` provenaient du même
problème d'initialisation.

## Correction

Ajout de `CF_PrepareRegressionEnvironment()` avant la suite globale. Cette macro :

1. initialise `Compare_Config` via `EnsureConfigSheet()` ;
2. initialise `Compare_Rules` via `EnsureRulesSheet()` ;
3. crée la paire `CF_Test_OLD` / `CF_Test_NEW` via `CF_CreateTestWorkbook()`.

La validation normale (`CF_ValidateFramework`, `CF_RunValidated`) reste stricte
et n'invente pas de sources dans un classeur métier.

## Validation

1. Compiler le module.
2. Exécuter `CF_RunGlobalRegression()`.
3. Vérifier `Compare_Validation` :
   - aucune erreur `SOURCES` ;
   - `Compare_Config` et `Compare_Rules` présentes ;
   - synthèse `OK`.
4. Vérifier ensuite `CF_Quality_Dashboard`.
