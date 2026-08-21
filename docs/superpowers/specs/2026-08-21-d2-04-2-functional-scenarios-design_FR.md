# D2-04.2 — Conception de l'automatisation des scénarios fonctionnels

**Statut :** CONCEPTION APPROUVÉE — implémentation en attente

## Objectif

Automatiser le catalogue officiel de non-régression fonctionnelle T001–T010 de CompareFramework via le véritable harness UNO LibreOffice 7.4.7.2 introduit par D2-04.1.

## Périmètre et invariants

- L'artefact Basic testé est le monolithe produit par `tools/build_monolith.py` ; les modules `src/*.bas` ne sont jamais injectés directement.
- LibreOffice est strictement fixé à la version 7.4.7.2, en réutilisant le contrat runtime D2-04.0.
- Chaque scénario T001–T010 s'exécute dans un nouveau processus LibreOffice, avec un nouveau profil utilisateur temporaire et un nouveau document de travail.
- Les six API publiques utilisateur gelées restent inchangées.
- `CF_CI_RuntimeSmoke` reste le point d'entrée technique de smoke test de D2-04.1.
- D2-04.2 introduit `CF_CI_RunScenario` comme point d'entrée CI technique et non interactif, hors des API utilisateur gelées.
- Python orchestre ; LibreOffice Basic exécute la véritable comparaison métier CompareFramework.
- Python ne doit pas réimplémenter la logique de comparaison des lignes ou cellules.

## Catalogue officiel des scénarios

Le catalogue existant `tests/catalog.md` et les données `tests/datasets/` restent la référence humaine pour T001–T010 :

- T001 identical → `OK`, aucun écart.
- T002 additions → `ECARTS`, un ajout.
- T003 deletions → `ECARTS`, une suppression.
- T004 modifications → `ECARTS`, une ligne modifiée et une cellule modifiée.
- T005 combined_changes → `ECARTS`, un ajout, une suppression et une modification.
- T006 duplicates → `A CONTROLER`, doublon détecté.
- T007 missing_key_column → `A CONTROLER`, cible ignorée ou incident structurel.
- T008 extra_column → `A CONTROLER`, alerte structurelle.
- T009 reordered_columns → `OK`, aucun écart métier.
- T010 typed_values → `OK`, aucun écart pour des valeurs typées équivalentes.

La clé de comparaison est `ProductId`, sauf indication explicite contraire d'un scénario.

## Contrat machine des résultats attendus

Chaque dossier `tests/datasets/<scenario>/` reçoit un fichier `expected.json`. Il devient la référence canonique lisible par machine. Le fichier `expected.md` existant reste la documentation humaine correspondante et doit rester sémantiquement synchronisé.

Le contrat normalisé est :

```json
{
  "scenario_id": "T005",
  "decision": "ECARTS",
  "added_rows": 1,
  "deleted_rows": 1,
  "modified_rows": 1,
  "modified_cells": 1,
  "duplicate_ids": 0,
  "structure_alerts": 0
}
```

Les huit champs sont obligatoires. Les compteurs non applicables valent `0` et ne sont pas omis. `scenario_id` doit correspondre à l'identifiant du catalogue et `decision` utilise le vocabulaire natif de décision du framework.

## Architecture d'exécution d'un scénario

Pour chaque scénario, de manière indépendante, le runner exécute la chaîne suivante :

`MODELE.csv + TARGET.csv → document ODS de travail isolé → injection du monolithe → CF_CI_RunScenario → feuilles de sortie natives CompareFramework → extraction UNO → actual.json → comparaison stricte avec expected.json`

Le runner crée un document contenant les feuilles `MODELE` et `TARGET` à partir des CSV du scénario. Le scénario est configuré pour une comparaison de référence `MODELE` → `TARGET` avec la clé `ProductId`, sauf surcharge explicite du contrat du jeu de données.

Un nouveau processus LibreOffice 7.4.7.2 et un profil temporaire isolé sont créés pour chaque scénario. Aucune bibliothèque Basic, feuille, configuration, rapport, cache, contexte ou état de processus n'est réutilisé entre deux scénarios.

## Point d'entrée technique Basic

`CF_CI_RunScenario` est ajouté au monolithe comme procédure CI technique. Il est non interactif et n'est pas ajouté aux six API utilisateur gelées.

Sa responsabilité est volontairement limitée :

1. consommer le document de scénario préparé par Python ;
2. établir la configuration CompareFramework minimale nécessaire à la comparaison `MODELE` → `TARGET` ;
3. invoquer le véritable chemin de comparaison CompareFramework ;
4. rendre la main après production des feuilles de sortie normales du framework.

Il ne doit contenir aucune implémentation CI spécifique des règles de comparaison, de comptage ou de décision.

## Extraction des résultats natifs

D2-04.2 n'utilise pas `CompareFramework_CI` comme second canal de résultats métier. Cette feuille reste le canal de résultat technique du smoke test D2-04.1.

Après le retour de `CF_CI_RunScenario`, Python lit via UNO les sorties métier normales du framework, principalement :

- `Compare_Reference_Summary` ;
- `Stats_Comparaison` ;
- `Rapport_Comparaison` lorsqu'un détail requis n'est pas exposé dans les feuilles de synthèse ou statistiques.

Un mapping d'extraction unique et centralisé convertit les valeurs des feuilles natives vers les champs du résultat normalisé. Python peut normaliser leur représentation, mais ne doit pas déduire les ajouts, suppressions, modifications, doublons, alertes structurelles ou la décision à partir des CSV sources.

Le résultat observé normalisé est enregistré dans `actual.json` avec le même schéma à huit champs que `expected.json`.

## Contrat PASS/FAIL

Un scénario passe uniquement lorsque son `actual.json` normalisé est strictement égal à son `expected.json` canonique pour chacun des champs.

Une suite réussie affiche donc individuellement les dix scénarios et un résultat global `10/10 PASS`. L'échec d'un scénario ne modifie pas le contrat des scénarios suivants ; grâce à l'isolation, le runner doit conserver suffisamment de diagnostics par scénario pour identifier chaque cas en échec.

Les erreurs sont classées explicitement, notamment :

- jeu de données ou contrat attendu absent/invalide ;
- erreur de runtime/version LibreOffice ;
- erreur de connexion UNO ou d'ouverture du document ;
- erreur d'injection du monolithe ;
- erreur de résolution/invocation de `CF_CI_RunScenario` ;
- erreur d'extraction des feuilles/résultats natifs ;
- différence entre `actual.json` et `expected.json` ;
- timeout ou arrêt incorrect du runtime.

## Diagnostics et artefacts CI

Le workflow GitHub Actions exécute la suite complète T001–T010 après construction du monolithe et installation du runtime LibreOffice épinglé.

Pour chaque scénario en échec, les diagnostics conservent au minimum :

- `expected.json` ;
- `actual.json` généré lorsque l'extraction a réussi ;
- le document `.ods` de travail en échec lorsqu'il est disponible ;
- un diagnostic texte du runner identifiant la classe d'erreur.

Le workflow expose un résumé concis par scénario, par exemple `T001 PASS` … `T010 PASS`, suivi du résultat global.

## Tests

### Contrat statique/unitaire

Les tests Python automatisés couvrent :

- la découverte d'exactement T001–T010 ;
- la présence et la validation du schéma de chaque `expected.json` ;
- la cohérence entre catalogue et identifiant de scénario ;
- la comparaison stricte attendu/observé ;
- la normalisation centralisée des sorties natives ;
- la présence de `CF_CI_RunScenario` dans le monolithe construit ;
- le maintien inchangé des six API utilisateur gelées ;
- la configuration d'isolation et le contrat LibreOffice 7.4.7.2.

### Contrat d'intégration réel

GitHub Actions doit exécuter les dix scénarios via le véritable LibreOffice Basic et UNO. Les tests statiques seuls ne peuvent pas valider D2-04.2.

Le run d'intégration final doit prouver que :

- le monolithe construit depuis le HEAD final est l'artefact injecté dans chaque scénario ;
- les dix scénarios utilisent LibreOffice 7.4.7.2 ;
- chaque scénario possède un processus, un profil et un document distincts ;
- `CF_CI_RunScenario` invoque le véritable chemin du framework ;
- les résultats observés proviennent uniquement des feuilles de sortie natives de CompareFramework ;
- les dix contrats `actual.json` correspondent à leurs `expected.json`.

## Garde-fous de régression

D2-04.2 ne doit pas faire régresser les jalons déjà validés. Avant validation finale, une CI fraîche sur le HEAD final doit maintenir au vert la validation cumulative pertinente, la validation runtime D2-04.0 et le harness UNO Basic D2-04.1, en plus du nouveau workflow D2-04.2.

## Règle de statut de validation

La documentation et le rapport peuvent indiquer `IMPLEMENTED — verification pending` après achèvement du code, mais D2-04.2 ne doit pas être marqué `VALIDATED` avant qu'un run GitHub Actions frais sur le HEAD final soit `completed / success` et prouve le contrat réel complet T001–T010.

## Hors périmètre

D2-04.2 ne :

- crée ni ne modifie d'API publique utilisateur ;
- prend en charge aucune version de LibreOffice autre que 7.4.7.2 ;
- remplace les sorties natives CompareFramework par une logique métier propre à la CI ;
- redessine le moteur de comparaison ;
- étend le catalogue fonctionnel au-delà de T001–T010.
