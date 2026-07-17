# RC-05 — Release Readiness

**Projet :** CompareFramework  
**Version cible :** `3.8.0-RC1`  
**Date de revue :** 17 juillet 2026  
**Périmètre audité :** sources fournies dans `src.tar.gz`, livrables RC-03 et RC-04, ordre de modules révisé, documentation et anciens outils disponibles dans l’espace de travail.

## 1. Décision

# NO GO

CompareFramework n'est pas encore publiable sous le nom `3.8.0-RC1`.

Le code présente une base techniquement cohérente et le build statique simulé réussit, mais plusieurs décisions déjà validées ne sont pas encore intégrées dans un dépôt de release unique. Le blocage principal est l'incohérence de version entre les sources, le build et la version cible.

Le passage à **GO** ne nécessite pas de refactoring architectural. Il nécessite une intégration de release contrôlée, suivie d'une qualification LibreOffice réelle.

## 2. Synthèse des contrôles

| Domaine | État | Conclusion |
|---|---:|---|
| Architecture du dépôt | À intégrer | Structure cible validée, mais aucun dépôt complet assemblé n'a été fourni pour RC-05. |
| Sources modulaires | Conforme avec réserves | 19 modules sources présents, tous avec `Option Explicit`; structure syntaxique équilibrée. |
| Façade publique | À intégrer | `CompareFramework_API.bas` existe dans le livrable RC-04 mais n'est pas encore dans l'archive source auditée. |
| Ordre des modules | À intégrer | Ordre révisé cohérent, mais le fichier officiel `MODULE_ORDER.txt` n'est pas présent dans l'archive source. |
| Build statique | Réussi en simulation | Build de 20 modules réussi après intégration simulée de la façade et de l'ordre révisé. |
| Gestion de version | Bloquant | Sources `3.5.1`, build `3.7.3-D4`, documentation `3.8 RC1`; fichier racine `VERSION` absent. |
| Nommage de l'artefact | Bloquant | Le build génère encore `CompareFramework_3_7_3_D4_Monolith.bas`. |
| Manifestes | Bloquant | Le manifeste de build annonce encore `3.7.3-D4`; le manifeste de release cible n'a pas pu être vérifié. |
| Documentation | Partiellement conforme | Guides principaux présents; intégration finale dans `docs/` et cohérence de version à contrôler. |
| ADR | Partiellement conforme | ADR-0001 à ADR-0005 connus; ADR-0006 sur la version n'a pas été trouvé dans le périmètre audité. |
| Licence | Non vérifiable / bloquant | Aucun fichier racine `LICENSE` ou `LICENCE` dans le paquet source de RC-05. |
| Tests statiques | Conforme | Aucun doublon de procédure détecté; blocs `Sub`/`Function` équilibrés; aucun appel interdit `Round()` détecté. |
| Tests LibreOffice | Non exécutés | Une qualification réelle dans LibreOffice Calc reste obligatoire. |
| Mode Référence | À qualifier | Source présente, mais validation D1/D2/D3 et données réelles non rejouées dans cet audit. |
| Kit de publication | Incomplet | CHANGELOG, RELEASE_NOTES, manifestes et archive finale ne sont pas assemblés dans une release candidate unique. |

## 3. Résultats techniques vérifiés

### 3.1 Sources

L'archive contient **19 modules** pour **5 947 lignes** :

- 18 modules à la racine de `src/`;
- 1 module sous `src/Modes/`;
- tous les modules déclarent `Option Explicit`;
- les nombres de débuts et fins de `Sub` et `Function` sont équilibrés;
- aucun nom de procédure n'est dupliqué entre les modules audités.

Ces contrôles ne remplacent pas la compilation par LibreOffice Basic, mais ils ne révèlent pas d'anomalie structurelle immédiate.

### 3.2 Intégration simulée de RC-04

Une intégration temporaire a été construite avec :

- les 19 modules de `src.tar.gz`;
- `src/CompareFramework_API.bas`;
- le nouvel ordre de `MODULE_ORDER.txt`;
- le dernier script de build disponible provenant de D4.

Résultat :

- **20 modules assemblés**;
- un seul `Option Explicit` dans le monolithe;
- aucune syntaxe `Optional ... = ...` interdite;
- aucun appel direct interdit à `Round()`;
- aucun symbole public dupliqué;
- contrôle statique du build : **PASS**.

La façade RC-04 appelle six procédures existantes :

- `CF_OpenReferenceLauncher`;
- `CF_RunValidated`;
- `ExporterRapportHTML`;
- `CF_OpenComparatorConfig`;
- `DiagnosticFramework`;
- `CF_RunGlobalRegression`.

### 3.3 Incohérence de version constatée

L'intégration simulée produit simultanément trois identités différentes :

| Emplacement | Version constatée |
|---|---|
| `CompareFramework_Utils.bas` / `CF_VERSION` | `3.5.1` |
| Messages et en-têtes de nombreux modules | `3.5.1` |
| `BUILD_MANIFEST.json` généré | `3.7.3-D4` |
| Nom du monolithe généré | `CompareFramework_3_7_3_D4_Monolith.bas` |
| Documentation cible | `3.8 RC1` ou `3.8.0-RC1` |

Cette situation interdit de publier un artefact présenté comme `3.8.0-RC1` : le logiciel, son manifeste et son nom ne déclareraient pas la même version.

## 4. Bloquants avant GO

### B01 — Créer et utiliser la source unique `VERSION`

Créer à la racine :

```text
VERSION
```

avec exactement :

```text
3.8.0-RC1
```

Le build doit lire ce fichier et ne plus contenir de version codée en dur.

### B02 — Corriger la version exposée par le code

`CF_VERSION = "3.5.1"` et les titres de boîtes de dialogue codés en dur doivent être remplacés par une valeur cohérente issue du mécanisme de version retenu.

Attention : LibreOffice Basic ne peut pas nécessairement lire commodément le fichier `VERSION` à l'exécution dans tous les contextes. Le build peut donc injecter la version dans le monolithe ou générer un module de version. Le fichier `VERSION` reste la source de vérité.

### B03 — Mettre à jour le build

Le script doit :

- lire `VERSION`;
- générer `dist/CompareFramework-3.8.0-RC1.bas`;
- écrire cette même version dans `BUILD_MANIFEST.json`;
- inclure les 20 modules définis par `MODULE_ORDER.txt`;
- échouer si un module source est absent ou non listé;
- idéalement échouer lorsqu'une ancienne version active est détectée dans les sources générées.

### B04 — Intégrer RC-04 dans le dépôt

Installer effectivement :

```text
src/CompareFramework_API.bas
docs/API_REFERENCE.md
docs/audit/RC04_PUBLIC_API_REVIEW.md
docs/audit/PUBLIC_SYMBOL_INVENTORY.csv
```

et ajouter la façade en dernière position dans `MODULE_ORDER.txt`.

### B05 — Assembler les fichiers racine de release

Le dépôt candidat doit contenir au minimum :

```text
VERSION
MODULE_ORDER.txt
CHANGELOG.md
RELEASE_NOTES.md
RELEASE_MANIFEST.json
QUALITY.md
LICENSE
README.md
```

Le renommage `LICENCE` vers `LICENSE` reste recommandé pour suivre les conventions usuelles.

### B06 — Ajouter ADR-0006

Créer `docs/adr/ADR-0006-version-management.md` et mettre à jour `docs/DECISIONS.md` afin de formaliser `VERSION` comme source unique.

### B07 — Exécuter la qualification LibreOffice

Les contrôles suivants doivent être exécutés dans une installation LibreOffice Calc cible :

1. import du monolithe sans erreur;
2. compilation de toutes les macros;
3. visibilité et exécution des six macros de façade;
4. comparaison standard sur le jeu de test;
5. mode Référence et lanceur;
6. export HTML;
7. régression globale;
8. contrôle des rapports, statuts et feuilles générées;
9. qualification sur un jeu de données réel;
10. fermeture et réouverture du classeur sans perte de configuration.

### B08 — Générer et vérifier les manifestes finaux

Après le build final :

- calculer le SHA-256 de l'artefact;
- vérifier que les modules du manifeste correspondent exactement à `MODULE_ORDER.txt`;
- vérifier que `RELEASE_MANIFEST.json` référence le bon artefact et les bons documents;
- reconstruire une seconde fois et confirmer que le hash est identique si le build est conçu comme reproductible.

## 5. Réserves non bloquantes pour RC1

Les points suivants peuvent être reportés à la version 4, sous réserve d'être documentés :

- cycles `Config ↔ Rules` et `Comparators ↔ ComparatorConfig`;
- surface publique interne encore importante;
- découpage futur de `CompareFramework_Report.bas`;
- découpage futur de `CF_ModeReference.bas`;
- réduction progressive des procédures `Public` non nécessaires;
- séparation plus stricte entre runtime, validation et tests.

Ces sujets ne justifient pas de retarder RC1 une fois les huit blocages de release levés.

## 6. Checklist de passage à GO

| ID | Critère | Obligatoire | État actuel |
|---|---|---:|---:|
| G01 | `VERSION = 3.8.0-RC1` présent | Oui | KO |
| G02 | Build lit `VERSION` | Oui | KO |
| G03 | Code et messages n'exposent plus `3.5.1` | Oui | KO |
| G04 | Artefact nommé `CompareFramework-3.8.0-RC1.bas` | Oui | KO |
| G05 | Manifeste de build en `3.8.0-RC1` | Oui | KO |
| G06 | Façade API intégrée sous `src/` | Oui | KO dans l'archive auditée |
| G07 | `MODULE_ORDER.txt` officiel mis à jour | Oui | KO dans l'archive auditée |
| G08 | ADR-0006 et index des décisions mis à jour | Oui | KO / non trouvé |
| G09 | Licence racine présente sous `LICENSE` | Oui | KO / non trouvée |
| G10 | Build statique réussi | Oui | OK en simulation |
| G11 | Compilation LibreOffice réussie | Oui | Non exécutée |
| G12 | Régression globale réussie | Oui | Non exécutée |
| G13 | Mode Référence qualifié | Oui | Non exécuté |
| G14 | Qualification sur données réelles réussie | Oui | Non exécutée |
| G15 | CHANGELOG et RELEASE_NOTES finalisés | Oui | Non vérifiable dans un dépôt candidat unique |
| G16 | Manifestes et hash final vérifiés | Oui | Non exécuté |
| G17 | Archive RC1 reconstruite depuis une arborescence propre | Oui | Non exécutée |

Le verdict pourra passer à **GO** uniquement lorsque G01 à G17 seront tous démontrés.

## 7. Séquence recommandée

1. Assembler une branche ou copie propre du dépôt cible.
2. Intégrer RC-00 : `VERSION`, ADR-0006 et build versionné.
3. Intégrer RC-04 : façade, documentation API et inventaire.
4. Installer le `MODULE_ORDER.txt` révisé.
5. Harmoniser les documents et fichiers racine.
6. Générer le monolithe et les manifestes.
7. Exécuter la qualification LibreOffice complète.
8. Corriger uniquement les anomalies bloquantes.
9. Refaire le build depuis un répertoire propre.
10. Émettre la décision RC-05 finale : GO.

## 8. Conclusion

L'architecture et les sources ne présentent pas de motif de **NO GO architectural**. Le NO GO actuel est un **NO GO d'intégration et de traçabilité de release**.

La base est suffisamment stable pour poursuivre directement vers une candidate RC1, sans refactoring majeur. La priorité absolue est désormais de produire un dépôt candidat unique dans lequel la version, le build, les manifestes, la façade API, la documentation et l'artefact final sont effectivement synchronisés.
