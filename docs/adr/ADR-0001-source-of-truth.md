# ADR-0001 — `src/` est la source de vérité

## Contexte
Le projet est distribué sous forme d'un monolithe `.bas`, mais développé de façon modulaire.

## Décision
Tous les développements sont réalisés dans `src/`.
Le répertoire `dist/` est généré automatiquement.

## Conséquences
- Pas de divergence entre sources et distribution.
- Les revues de code portent uniquement sur `src/`.
