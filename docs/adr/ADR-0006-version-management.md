# ADR-0006 — Gestion centralisée de la version

## Statut

Accepté.

## Contexte

Plusieurs numéros de version coexistaient dans le code, les scripts de build, les manifestes et les noms d’artefacts. Cette situation rendait la publication difficile à reproduire et créait un risque d’incohérence.

## Décision

Le fichier `VERSION`, situé à la racine du dépôt, constitue l’unique source de vérité de la version courante.

Les scripts de construction, les manifestes, les noms d’artefacts et les documents de publication doivent lire ou reprendre cette valeur. Les documents historiques conservent les versions auxquelles ils se rapportent.

## Conséquences

- La version n’est modifiée qu’à un seul endroit.
- Le monolithe et les artefacts sont nommés à partir de `VERSION`.
- Les divergences de version deviennent détectables automatiquement.
- Les constantes historiques encore présentes dans le code doivent être supprimées ou générées lors de l’étape d’harmonisation des versions.
