# CHANGELOG

## V3.1 — Jalon B

### Ajouté
- Module `CompareFramework_Comparators.bas`.
- Comparateurs texte, nombre, date, booléen, pourcentage et devise.
- Détection automatique du comparateur par colonne et valeur.
- Tolérances numériques centralisées.
- Tests `CF_RunTypedComparatorTests()` et `CF_RunMilestoneBTests()`.
- Point d'entrée `CF_RunMilestoneB()`.

### Modifié
- Le moteur mémoire utilise désormais les valeurs brutes de `getDataArray()`.
- Le rapport indique le comparateur utilisé et son diagnostic.
- Version portée à 3.1.
