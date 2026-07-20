# Changelog

Toutes les évolutions notables de CompareFramework sont consignées dans ce fichier.

## [4.0.0-D1] - 2026-07-20

### Architecture

- Supported public façade frozen at six user-facing entry points.
- Complete public symbol inventory and Private-candidate classification generated.
- Reproducible module dependency map and cycle snapshot added.
- Split boundaries prepared for `CompareFramework_Report.bas` and `Modes/CF_ModeReference.bas`.
- No functional behavior or existing procedure visibility changed in D1.

## [3.8.0] - 2026-07-17

### Publication

- Promotion de `3.8.0-RC1` en version stable `3.8.0`.
- Aucun changement fonctionnel par rapport au code qualifié de la RC1.
- Artefacts, manifeste, certificat et sommes de contrôle régénérés pour la version finale.

### Qualification

- Compilation réelle réussie sous LibreOffice 25.2.3.2.
- Suite interne : 7/7 tests réussis.
- Promotion finale limitée à l’identifiant de version ; build `3.8.0` vérifié sans modification fonctionnelle.

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
