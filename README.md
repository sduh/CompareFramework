# CompareFramework V3.7.2-D3 — Assistant de lancement

D3 ajoute une feuille de configuration guidée pour le mode Référence.

## Utilisation

1. Exécuter `CF_OpenReferenceLauncher()`.
2. Ouvrir `Compare_Launcher`.
3. Renseigner :
   - `REFERENCE_SHEET`
   - `KEY_COLUMN`
   - `TARGET_MODE`
   - `SELECTED_TARGETS`
4. Exécuter `CF_RunFromLauncher()`.

## Modes de cibles

### Toutes les cibles

`TARGET_MODE = ALL`

### Cibles sélectionnées

`TARGET_MODE = SELECTED`

Exemple :

`3pmg_001;aedev_936`

## Macros

- `CF_OpenReferenceLauncher()`
- `CF_RunFromLauncher()`
- `CF_RunLauncherQuick()`
- `CF_RunAgainstReference_MODELE()`

D1 et D2 restent disponibles.
