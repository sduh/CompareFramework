# ADR-0003 — Moteur mémoire

## Contexte
Les accès cellule par cellule sont coûteux.

## Décision
Les données sont lues, indexées puis comparées en mémoire.

## Conséquences
- Meilleures performances.
- Base commune pour tous les modes de comparaison.
