# CompareFramework - Certificat de publication

| Champ | Valeur |
|---|---|
| Projet | CompareFramework |
| Version | 3.8.0-RC1 |
| Type de publication | Release Candidate |
| Date de qualification | À compléter lors de la publication |
| Décision de qualification | EN ATTENTE |

## Objet

Le présent certificat synthétise l’état de qualification de CompareFramework version **3.8.0-RC1**.

Il ne remplace pas les rapports d’audit détaillés. Il enregistre la décision finale de publication lorsque tous les points bloquants de la revue de préparation ont été levés et que la validation opérationnelle s’est terminée avec succès.

## Références

### Gouvernance

- `VERSION`
- `RELEASE_POLICY.md`
- `CHANGELOG.md`
- `RELEASE_NOTES.md`
- `RELEASE_MANIFEST.json`

### Architecture

- `docs/adr/`

### Preuves de qualification

- `docs/audit/AUDIT_STRUCTURE.md`
- `docs/audit/AUDIT_CODE.md`
- `docs/audit/AUDIT_DEPENDENCIES.md`
- `docs/audit/RC04_PUBLIC_API_REVIEW.md`
- `docs/audit/RC05_RELEASE_READINESS.md`
- `docs/audit/RC05_GO_CHECKLIST.csv`

## Étapes de qualification

| Étape | Objet | Statut |
|---|---|---|
| RC-00 | Harmonisation des versions | Terminée |
| RC-01 | Audit de la structure du dépôt | Terminé |
| RC-02 | Audit statique du code | Terminé |
| RC-03 | Audit des dépendances | Terminé avec réserves |
| RC-04 | Revue de l’API publique | Terminée ; intégration en attente |
| RC-05 | Préparation de la release | NO GO jusqu’à levée des blocages |

## Conformité architecturale

La release candidate qualifiée doit respecter les principes suivants :

- les modules sources sont maintenus sous `src/` ;
- l’artefact Basic monolithique est généré depuis les modules sources ;
- les artefacts générés sont stockés sous `dist/` ;
- la version de publication est lue depuis le fichier racine `VERSION` ;
- les décisions d’architecture sont enregistrées sous `docs/adr/` ;
- les preuves de qualification sont stockées sous `docs/audit/` ;
- la façade publique officielle est définie par `src/CompareFramework_API.bas` et documentée dans `docs/API_REFERENCE.md`.

## Artefacts de publication requis

Le paquet de publication doit inclure au minimum :

- `dist/CompareFramework-3.8.0-RC1.bas`;
- `dist/RELEASE_CERTIFICATE_3.8.0-RC1.pdf`;
- `RELEASE_NOTES.md`;
- `RELEASE_MANIFEST.json`;
- `CHANGELOG.md`.

## Exigences de validation finale

Avant de passer la décision à **GO**, les points suivants doivent tous être confirmés :

- le dépôt et les artefacts générés exposent la même version ;
- `CompareFramework_API.bas` est intégré dans `src/` et `MODULE_ORDER.txt` ;
- le monolithe est généré avec succès ;
- le projet compile dans LibreOffice ;
- la suite de validation de release se termine avec succès ;
- la validation du mode Référence se termine avec succès ;
- le manifeste et les sommes de contrôle correspondent aux artefacts publiés ;
- le tag Git est créé depuis le commit exactement qualifié.

## Décision

**Décision actuelle : EN ATTENTE / NO GO POUR PUBLICATION**

Le certificat ne peut être passé à **GO** qu’après la levée des blocages identifiés par RC-05 et l’enregistrement des preuves de validation opérationnelle.

## Approbation

| Champ | Valeur |
|---|---|
| Projet qualifié | CompareFramework |
| Version qualifiée | 3.8.0-RC1 |
| Tag Git | `v3.8.0-rc1` |
| Commit qualifié | À compléter |
| Approuvé par | À compléter |
| Date d’approbation | À compléter |
