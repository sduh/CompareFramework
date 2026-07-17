# Étape 1 — Harmonisation du dépôt

## Réalisé

- Sources installées sous `src/`.
- Façade publique ajoutée dans `src/CompareFramework_API.bas`.
- `MODULE_ORDER.txt` remplacé par l’ordre revu.
- `VERSION` créé avec `3.8.0-RC1`.
- Documentation organisée sous `docs/`, `docs/adr/`, `docs/audit/` et `docs/release/`.
- Audits RC-01 à RC-05 regroupés sous `docs/audit/`.
- Tests et jeux de données installés sous `tests/`.
- Scripts de build et de génération du certificat installés sous `tools/`.
- Répertoires `examples/` et `dist/` créés.
- `CONTRIBUTING.md` ajouté.
- ADR-0006 ajouté.

## Non réalisé volontairement

Le fichier `LICENSE` n’a pas été créé, car aucune licence juridique n’a été fournie et la documentation existante indique que ce choix reste à faire. Inventer une licence modifierait les droits du projet sans autorisation.

## Hors périmètre de cette étape

- Remplacement des anciennes versions dans le code et les scripts : étape 2.
- Génération du monolithe et des manifestes : étape 3.
- Compilation et validation sous LibreOffice : étape 4.
- Tag Git et publication : étape 5.
