# T010 — Valeurs typées équivalentes

Importer les fichiers CSV dans deux feuilles LibreOffice Calc :

- `MODELE.csv` dans une feuille nommée `MODELE` ;
- `TARGET.csv` dans une feuille nommée `TARGET`.

Le scénario charge aussi, uniquement dans son document de travail isolé :

- `setup/Compare_Config.csv` dans `Compare_Config`, pour activer `IGNORE_CASE=TRUE` ;
- `setup/Compare_Comparators.csv` dans `Compare_Comparators`, avec les règles
  explicites `CURRENCY`, `PERCENT`, `BOOLEAN` et `DATE` pour les colonnes
  typées.

Lancer ensuite une comparaison avec la colonne identifiant `ProductId`, sauf indication contraire dans `expected.md`.

Consulter `expected.md` pour les compteurs et la décision attendus.
