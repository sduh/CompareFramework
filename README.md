# CompareFramework V2.9 — Performance & Metrics

## Nouveau module

`CompareFramework_Performance.bas`

## Nouveau point d’entrée recommandé

`CF_RunPerformanceProfiled()`

Il exécute le préflight, la comparaison et génère `Compare_Performance` avec les durées des phases.

## Lecture en mémoire

`CF_ReadSheetDataArray(sheet)` utilise `getDataArray()` afin de charger une plage Calc en une opération UNO. Cette API prépare la migration du moteur V3.0 vers une comparaison entièrement en mémoire.

## Outils

- `CF_RunPerformanceBenchmark()` : mesure la lecture en mémoire de chaque feuille.
- `CF_RunPerformanceTests()` : vérifie la lecture par tableau.
- `CF_PerfStart/CF_PerfStop` : chronométrage nommé.
- `CF_PerfRecordPair` : métriques par paire.
- `CF_PerfWriteReport` : feuille `Compare_Performance`.

## Corrections

- constante `CF_VERSION` alignée sur `2.9` ;
- manifeste complété avec Audit, Validation et Performance ;
- feuilles techniques exclues de la détection des paires.

La V2.9 est un jalon de mesure. La V3.0 utilisera ces primitives pour remplacer les accès cellule par cellule dans le cœur du moteur.

Généré le 2026-07-10 07:09:09.
