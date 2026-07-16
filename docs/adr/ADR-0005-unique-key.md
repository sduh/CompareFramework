# ADR-0005 — Clé de comparaison unique

## Contexte
Des doublons rendent l'indexation ambiguë.

## Décision
La clé doit être unique dans chaque feuille.

## Conséquences
- En présence de doublons : décision `A CONTROLER`.
- Roadmap V4 : arrêt immédiat avant indexation (mode strict).
