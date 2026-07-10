# CompareFramework V3.0 - Jalon A : moteur en memoire

V3.0 est le premier jalon fonctionnel du nouveau cycle.

## Changement majeur

`ComparerToutesLesFeuilles()` utilise maintenant le moteur en memoire :

1. lecture de chaque plage avec `getDataArray()` ;
2. construction des index ID en memoire ;
3. comparaison des lignes sans relire les cellules une par une ;
4. ecriture du rapport final.

L'ancien moteur reste disponible avec :

- `ComparerToutesLesFeuilles_Legacy()`

## Points d'entree

- `ComparerToutesLesFeuilles()` : moteur V3 en memoire.
- `CF_RunMilestoneA()` : lancement contextualise et audite.
- `CF_RunMemoryEngineTests()` : test technique du chargement et de l'indexation.
- `ComparerToutesLesFeuilles_Legacy()` : solution de repli.

## Limite connue

`getDataArray()` renvoie les valeurs brutes. Les dates et formats d'affichage seront traites par les comparateurs specialises du jalon suivant. Pour valider V3.0, comparer d'abord les resultats du moteur V3 et du moteur Legacy sur les memes jeux de donnees.

## Ordre d'import

Voir `MODULE_ORDER.txt`.
