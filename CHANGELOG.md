# CHANGELOG

## V2.3

- Ajout de la feuille `Compare_Rules`.
- Ajout du chargement des règles au démarrage de la comparaison.
- Ajout des règles `EQUIVALENT_VALUES`, `NUMERIC_TOLERANCE`, `IGNORE_IF_ONE_EMPTY`, `IGNORE_EXACT_PAIR`, `CONTAINS_BOTH`.
- Exclusion de `Compare_Rules` des feuilles métier comparées automatiquement.
- Version portée à 2.3.

# CHANGELOG

## V2.3

- Refactorisation réelle en modules `Main`, `Config`, `Index`, `Rules`, `Report`, `Utils`.
- Centralisation des constantes et variables partagées.
- Préservation de `ComparerToutesLesFeuilles()` et `ExporterRapportHTML()`.
- Ajout d'un fichier monolithique de compatibilité.

## V2.1

- Introduction de la structure modulaire.
