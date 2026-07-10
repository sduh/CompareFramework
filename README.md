# CompareFramework V2.6 - Profils réutilisables

Cette version ajoute une couche de profils au-dessus de la configuration et du contexte d'exécution.

## Nouveau module

- `CompareFramework_Profiles.bas`

## Profils fournis

- `STANDARD`
- `FINANCE`
- `RH`
- `ERP`
- `CRM`

## Macros principales

- `CF_ListProfiles()` : ouvre la feuille `Compare_Profiles`.
- `CF_ApplyProfile("FINANCE")` : applique un profil à `Compare_Config`.
- `CF_SaveCurrentConfigAsProfile("MON_PROFIL")` : enregistre la configuration actuelle.
- `CF_RunWithProfile("ERP")` : applique le profil puis lance la comparaison.
- `CF_RunProfileTests()` : vérifie la création des profils intégrés.

## Compatibilité

Les macros historiques restent disponibles. La V2.6 ajoute une couche optionnelle et n'impose pas la migration immédiate.
