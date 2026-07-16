# Bonnes pratiques

Ce document est la référence unique des recommandations de CompareFramework.

## Clé de comparaison
- Une clé unique par feuille est obligatoire.
- Les doublons entraînent `A CONTROLER`.
- Nettoyer les doublons avant toute analyse.

## Développement
- Modifier uniquement `src/`.
- Régénérer `dist/` avec `python3 tools/build_monolith.py`.
- Ne jamais modifier le monolithe.

## Validation
Toute évolution doit être accompagnée de tests, documentation et qualification.
