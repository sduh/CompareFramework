# CompareFramework V2.2 - Refactorisation modulaire

Cette livraison remplace la V2.1 de structure par une V2.2 réellement découpée par responsabilités.

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

## Changements V2.2

- Découpage réel des procédures existantes entre modules spécialisés.
- Constantes et variables globales centralisées dans `Utils`.
- Procédures rendues publiques pour permettre les appels inter-modules LibreOffice Basic.
- Conservation de l'API publique existante.
- Ajout d'un monolithe de compatibilité généré depuis les modules.
