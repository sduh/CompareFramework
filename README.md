# CompareFramework V3.1 — Jalon B : comparateurs typés et fiabilité

La V3.1 conserve le moteur en mémoire de la V3.0 et remplace la comparaison texte unique par des comparateurs spécialisés.

## Comparateurs

- `TEXT` : normalisation historique (casse/espaces selon configuration)
- `NUMBER` : comparaison numérique avec tolérance
- `DATE` : comparaison de dates par numéro de série
- `BOOLEAN` : équivalences Oui/Vrai/True/1 et Non/Faux/False/0
- `PERCENT` : équivalence entre `10%` et `0.1`
- `CURRENCY` : suppression des symboles et tolérance d'arrondi

Le type est choisi automatiquement d'après l'en-tête et les valeurs.

## Points d'entrée

- `CF_RunMilestoneB()` : comparaison mémoire avec audit
- `CF_RunTypedComparatorTests()` : six tests ciblés
- `CF_RunMilestoneBTests()` : comparateurs + moteur mémoire
- `ComparerToutesLesFeuilles_Legacy()` : retour arrière

## Limites connues

La détection automatique des dates dépend des formats reconnus par LibreOffice et de la locale. Les tolérances sont centralisées dans `CompareFramework_Comparators.bas` et seront rendues configurables lors du jalon suivant.
