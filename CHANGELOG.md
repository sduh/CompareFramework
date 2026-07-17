# Changelog

Toutes les évolutions notables de CompareFramework sont consignées dans ce fichier.

## [3.8.0-RC1] - 2026-07-17

### Ajouté

- Façade publique `CompareFramework_API.bas` pour simplifier les points d’entrée utilisateur.
- Mode Référence consolidé et documentation de validation associée.
- Gestion centralisée de la version par le fichier racine `VERSION`.
- Génération automatique du certificat de release au format PDF.
- Audits de structure, de code, de dépendances et d’API publique.

### Modifié

- Réorganisation du dépôt autour de `src/`, `docs/`, `tests/`, `tools/`, `examples/` et `dist/`.
- Révision de `MODULE_ORDER.txt` selon les dépendances réelles.
- Nommage du monolithe sous la forme `CompareFramework-<version>.bas`.
- Harmonisation des références actives de version vers `3.8.0-RC1`.

### Qualification

- Build statique des 20 modules réussi.
- Aucun doublon de symbole public détecté dans le monolithe.
- Aucun appel interdit à `Round` ni syntaxe `Optional ... =` détecté.
- Validation opérationnelle LibreOffice encore requise avant publication.

## Historique antérieur

Les évolutions détaillées des versions antérieures sont conservées dans `docs/PROJECT_HISTORY.md` et dans les archives historiques du projet.
