# ADR-0002 — Génération automatique du monolithe

## Contexte
LibreOffice importe plus facilement un fichier `.bas` unique.

## Décision
Le monolithe est généré par `tools/build_monolith.py` à partir de `MODULE_ORDER.txt`.

## Conséquences
- Build reproductible.
- Contrôles statiques centralisés.
- Le monolithe n'est jamais modifié manuellement.
