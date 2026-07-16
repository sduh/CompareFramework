# Release Process

## Cycle

1. Développement
2. Build (`python3 tools/build_monolith.py`)
3. Compilation LibreOffice
4. Tests automatiques
5. Qualification sur jeu de données réel
6. Relecture documentation
7. Mise à jour CHANGELOG
8. Création du tag Git
9. Publication de la Release

Aucune Release n'est publiée si une étape échoue.
