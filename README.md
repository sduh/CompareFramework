# CompareFramework V2.3 - Refactorisation modulaire

Cette livraison remplace la V2.1 de structure par une V2.3 réellement découpée par responsabilités.

## Modules

- `CompareFramework_Main.bas` : macro publique `ComparerToutesLesFeuilles`, détection des paires, orchestration globale.
- `CompareFramework_Config.bas` : `Compare_Config`, alias ID, colonnes ignorées, normalisation, options booléennes.
- `CompareFramework_Index.bas` : lecture des en-têtes, construction d'index ID, recherche binaire, doublons.
- `CompareFramework_Rules.bas` : comparaison cellule par cellule et écriture des écarts de colonnes.
- `CompareFramework_Report.bas` : feuilles de rapport, synthèse, plan d'action, journal, formatage, export HTML.
- `CompareFramework_Utils.bas` : constantes globales, variables partagées et utilitaires communs.

## Installation LibreOffice

Importer les modules `.bas` dans la même bibliothèque Basic LibreOffice. Importer de préférence `CompareFramework_Utils.bas` en premier, puis les autres modules.

## Compatibilité

Le fichier `CompareFramework_V2_2_Monolith.bas` est fourni comme filet de sécurité si tu préfères encore importer un seul module.

## Macro principale

Lancer : `ComparerToutesLesFeuilles()`

Macro complémentaire : `ExporterRapportHTML()` après une comparaison.

## Changements V2.3

- Découpage réel des procédures existantes entre modules spécialisés.
- Constantes et variables globales centralisées dans `Utils`.
- Procédures rendues publiques pour permettre les appels inter-modules LibreOffice Basic.
- Conservation de l'API publique existante.
- Ajout d'un monolithe de compatibilité généré depuis les modules.


## V2.3 - Moteur de règles

La V2.3 ajoute la feuille `Compare_Rules`. Elle permet d'ignorer certaines différences sans modifier le code.

Colonnes de la feuille :

- `RuleId` : identifiant libre de la règle.
- `Enabled` : `TRUE` / `FALSE`.
- `Scope` : `GLOBAL` ou fragment du nom de paire.
- `Column` : nom de colonne ciblé ou `*`.
- `RuleType` : type de règle.
- `Param1`, `Param2` : paramètres de la règle.
- `Comment` : documentation libre.

Types de règles disponibles :

- `EQUIVALENT_VALUES` : toutes les valeurs listées dans `Param1` sont équivalentes. Exemple : `NULL;N/A;NA;`.
- `NUMERIC_TOLERANCE` : ignore un écart numérique inférieur ou égal à `Param1`. Exemple : `0.01`.
- `IGNORE_IF_ONE_EMPTY` : ignore l'écart si l'une des deux valeurs est vide.
- `IGNORE_EXACT_PAIR` : ignore uniquement le passage exact `Param1` -> `Param2`.
- `CONTAINS_BOTH` : ignore si les deux valeurs contiennent `Param1`.
