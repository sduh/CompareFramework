# CHANGELOG

## V3.2 - Jalon B configurable comparators

### Ajouté
- Module `CompareFramework_ComparatorConfig.bas`.
- Feuille `Compare_Comparators`.
- Types et tolérances configurables par profil et colonne.
- Règles génériques via le joker `*`.
- Macros de rechargement, ouverture et tests.
- Point d'entrée `CF_RunMilestoneB_Configured()`.

### Modifié
- Le moteur mémoire charge la configuration des comparateurs au démarrage.
- `CF_TypedValuesEqual()` donne priorité aux règles explicites avant l'auto-détection.
- Version globale portée à 3.2.

### Compatibilité
- API historique conservée.
- Détection automatique V3.1 utilisée en repli.
