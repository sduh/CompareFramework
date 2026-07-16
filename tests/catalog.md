# Catalogue des jeux de tests

Ce catalogue constitue la référence officielle des cas de non-régression de CompareFramework.

| ID | Dossier | Cas | Décision attendue | Résultat attendu |
|---|---|---|---|---|
| T001 | identical | Feuilles identiques | `OK` | Aucun écart |
| T002 | additions | Une ligne ajoutée dans la cible | `ECARTS` | 1 ajout |
| T003 | deletions | Une ligne absente de la cible | `ECARTS` | 1 suppression |
| T004 | modifications | Une valeur modifiée | `ECARTS` | 1 ligne et 1 cellule modifiées |
| T005 | combined_changes | Ajout, suppression et modification | `ECARTS` | 1 ajout, 1 suppression, 1 modification |
| T006 | duplicates | Clé dupliquée dans la cible | `A CONTROLER` | Doublon détecté |
| T007 | missing_key_column | Colonne identifiant absente | `A CONTROLER` | Cible ignorée ou incident structurel |
| T008 | extra_column | Colonne supplémentaire dans la cible | `A CONTROLER` | Alerte structurelle |
| T009 | reordered_columns | Colonnes dans un ordre différent | `OK` | Aucun écart métier |
| T010 | typed_values | Valeurs typées équivalentes | `OK` | Aucun écart |

## Convention des fichiers

Chaque dossier contient :

- `MODELE.csv` : feuille de référence ;
- `TARGET.csv` : feuille cible ;
- `expected.md` : résultat attendu ;
- `README.md` : objectif et mode d'emploi du test.

La clé utilisée dans tous les jeux est `ProductId`, sauf indication contraire.
