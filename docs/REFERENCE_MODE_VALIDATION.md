# Validation du Mode Référence

**Version :** 3.8 RC1

---

# 1. Objet

Ce document décrit la stratégie de validation du **Mode Référence** de CompareFramework.

Il remplace les anciens documents :

- TEST_D1.md
- TEST_D2.md
- TEST_D3.md

qui retraçaient les différentes étapes du développement du Mode Référence.

Ce document constitue désormais la référence unique pour la qualification fonctionnelle de cette fonctionnalité.

---

# 2. Principe

Le Mode Référence permet de comparer une feuille de référence avec une ou plusieurs feuilles cibles.

Exemple :

```
MODELE
    │
    ├── CLIENT_A
    ├── CLIENT_B
    ├── CLIENT_C
    └── CLIENT_D
```

Chaque feuille est comparée indépendamment à la feuille de référence.

Les résultats sont ensuite consolidés dans :

- Compare_Reference_Summary
- Rapport_Comparaison
- Compare_Audit

---

# 3. Évolution du Mode Référence

## D1

Première implémentation.

Fonctionnalités :

- comparaison MODELE → cible
- génération du rapport
- synthèse

---

## D2

Consolidation.

Ajouts :

- amélioration des rapports
- synthèse consolidée
- audit

---

## D3

Qualification.

Ajouts :

- optimisation
- validation
- amélioration des performances
- qualification sur données réelles

---

## RC1

Le Mode Référence est considéré comme stable.

La validation repose désormais sur :

- tests automatisés
- jeux de données CSV
- qualification sur données métier

---

# 4. Jeux de validation

Les jeux de données de référence sont disponibles dans :

```
tests/
└── datasets/
```

Ils couvrent les cas suivants :

| Cas | Répertoire |
|------|------------|
| Identique | identical |
| Ajout | additions |
| Suppression | deletions |
| Modification | modifications |
| Changements combinés | combined_changes |
| Doublons | duplicates |
| Colonne identifiant absente | missing_key_column |
| Colonne supplémentaire | extra_column |
| Colonnes réordonnées | reordered_columns |
| Valeurs typées | typed_values |

---

# 5. Résultats attendus

| Cas | Décision attendue |
|------|-------------------|
| Identique | OK |
| Ajout | ECARTS |
| Suppression | ECARTS |
| Modification | ECARTS |
| Changements combinés | ECARTS |
| Doublons | A CONTROLER |
| Colonne identifiant absente | A CONTROLER |
| Colonne supplémentaire | A CONTROLER |
| Colonnes réordonnées | OK |
| Valeurs typées | OK |

---

# 6. Qualification sur données réelles

Le Mode Référence a été validé sur un jeu de données métier représentatif.

Les essais ont couvert :

- feuilles identiques ;
- ajouts ;
- suppressions ;
- modifications ;
- changements combinés ;
- doublons.

Les résultats obtenus sont conformes aux attentes.

Cette qualification complète les jeux de tests automatisés.

---

# 7. Critères d'acceptation

Avant chaque publication :

- Build reproductible
- Compilation LibreOffice
- CF_RunStableValidation
- CF_RunGlobalRegression
- Validation des jeux CSV
- Qualification sur données réelles

Tous les critères doivent être satisfaits.

---

# 8. Régression

La régression du Mode Référence comprend :

## Validation technique

- génération du monolithe
- compilation
- validation automatique

## Validation fonctionnelle

- exécution des jeux CSV

## Validation métier

- comparaison d'un classeur réel

---

# 9. Limitations connues

Le Mode Référence suppose :

- une clé de comparaison unique ;
- des feuilles compatibles ;
- une comparaison dans un même classeur.

Les doublons produisent actuellement la décision :

```
A CONTROLER
```

Le mode strict (arrêt sur doublon) est prévu pour CompareFramework 4.

---

# 10. Historique

| Version | Évolution |
|----------|-----------|
| D1 | Première implémentation |
| D2 | Consolidation |
| D3 | Qualification |
| 3.8 RC1 | Document de référence unifié |

---

# Conclusion

Le Mode Référence est qualifié pour CompareFramework 3.8 RC1.

La stratégie de validation repose sur trois niveaux complémentaires :

- validation automatisée ;
- jeux de tests de référence ;
- qualification sur données réelles.

Cette approche garantit une validation reproductible tout en assurant la conformité aux cas d'usage métier.