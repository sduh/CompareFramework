# Contribuer à CompareFramework

## Principes

- Les sources de référence sont placées dans `src/`.
- `dist/` contient uniquement des artefacts générés.
- La version courante est définie dans `VERSION`.
- Toute modification de l’ordre des modules doit être reportée dans `MODULE_ORDER.txt`.
- Une décision d’architecture durable doit être documentée par un ADR.

## Préparer une publication

1. Mettre à jour `VERSION`.
2. Vérifier `MODULE_ORDER.txt`.
3. Générer le monolithe avec `tools/build_monolith.py`.
4. Exécuter les validations LibreOffice et les tests ciblés.
5. Mettre à jour `CHANGELOG.md`, `RELEASE_NOTES.md` et le manifeste.
6. Mettre à jour le certificat de release après la décision GO.
7. Créer un tag Git correspondant, par exemple `v3.8.0-rc1`.

Ne pas modifier manuellement les artefacts générés dans `dist/`.
