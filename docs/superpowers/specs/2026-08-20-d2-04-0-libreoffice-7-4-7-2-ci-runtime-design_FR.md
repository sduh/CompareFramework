# D2-04.0 — Socle d’exécution CI LibreOffice 7.4.7.2

## Statut

**DESIGN APPROUVÉ — plan d’implémentation en attente**

## Contexte

D2-03 a établi et validé l’analyseur d’architecture, le gel de l’API publique et un workflow de régression GitHub Actions. D2-04 ouvre la phase qualité suivante : exécuter CompareFramework sur un véritable runtime LibreOffice dans la CI.

LibreOffice **7.4.7.2** est le socle contractuel de cette phase. Les autres versions de LibreOffice sont explicitement hors périmètre de D2-04.0.

Le dépôt contient déjà un catalogue officiel de régression fonctionnelle (`tests/catalog.md`) avec les scénarios T001–T010. D2-04.0 n’exécute pas encore ces scénarios métier ; il établit le socle runtime déterministe nécessaire aux livrables D2-04 suivants.

## Objectif

Un runner Ubuntu GitHub Actions vierge doit pouvoir installer et démarrer exactement LibreOffice **7.4.7.2** en mode headless avec un profil utilisateur CI isolé.

Le workflow doit échouer si :

- LibreOffice ne peut pas être téléchargé depuis l’archive officielle LibreOffice ;
- l’installation est incomplète ;
- le runtime installé annonce une version différente de 7.4.7.2 ;
- le démarrage headless échoue ;
- le smoke test ne se termine pas proprement.

## Hors périmètre

D2-04.0 ne doit pas :

- exécuter une macro Basic CompareFramework ;
- charger les jeux de données fonctionnels T001–T010 ;
- valider les résultats de comparaison ;
- prendre en charge une matrice de versions LibreOffice ;
- introduire une image Docker ;
- optimiser le temps de téléchargement ou d’installation par cache.

Ces capacités appartiennent aux livrables D2-04 ultérieurs.

## Architecture

### 1. Installateur versionné

Ajouter un script shell appartenant au dépôt :

`tools/ci/install_libreoffice_7_4_7_2.sh`

Le script a une seule responsabilité : établir le runtime LibreOffice 7.4.7.2 exact requis par la CI.

Il doit :

1. définir la version attendue comme constante immuable ;
2. construire ou utiliser une URL explicite vers l’archive officielle LibreOffice pour les paquets Debian Linux x86_64 ;
3. télécharger l’archive avec propagation des erreurs ;
4. extraire les paquets dans un répertoire de travail temporaire ;
5. installer les paquets `.deb` requis sur le runner Ubuntu ;
6. localiser l’exécutable `soffice`/`libreoffice` installé ;
7. exécuter `--version` et exiger une correspondance exacte avec 7.4.7.2 ;
8. retourner un code de sortie non nul pour toute condition d’échec.

La logique d’installation reste hors du YAML du workflow afin d’être versionnée, lisible et testable indépendamment.

### 2. Smoke test du runtime CI

Ajouter un workflow GitHub Actions D2-04.0 dédié au lieu de surcharger le workflow d’architecture D2-03.24.

Le workflow D2-04.0 doit :

1. récupérer le dépôt ;
2. lancer l’installateur LibreOffice versionné ;
3. revérifier la version exacte au niveau du workflow ;
4. créer un profil utilisateur LibreOffice temporaire et unique ;
5. démarrer LibreOffice en mode headless avec ce profil ;
6. exécuter une opération de smoke test minimale et non interactive ;
7. vérifier la réussite et nettoyer le profil temporaire.

L’isolation du profil est obligatoire. La CI ne doit ni dépendre du profil LibreOffice par défaut du runner ni le modifier.

### 3. Relation avec la CI D2-03

Le workflow de validation cumulative D2-03.24 existant reste intact et conserve sa responsabilité actuelle : validation Python de l’architecture/régression et construction du monolithe.

D2-04.0 introduit une responsabilité distincte de validation du runtime. La séparation permet d’attribuer clairement les échecs :

- échec D2-03 => problème analyseur/architecture/régression ;
- échec D2-04.0 => problème du socle runtime LibreOffice.

Un livrable D2-04 ultérieur pourra consolider la politique des contrôles obligatoires, mais D2-04.0 évite de coupler prématurément des couches de validation différentes.

## Provenance du runtime

LibreOffice 7.4.7.2 doit provenir de l’archive officielle LibreOffice. La CI ne doit jamais substituer silencieusement :

- le paquet LibreOffice courant d’Ubuntu via `apt` ;
- une version LibreOffice amont plus récente ;
- un miroir tiers ;
- une image Docker préconstruite.

L’URL source doit être explicite dans l’installateur et donc auditable dans l’historique du dépôt.

## Gestion des erreurs

L’installateur et le workflow utilisent une stratégie fail-fast.

Les échecs bloquants attendus comprennent :

- erreur HTTP/téléchargement ;
- format d’archive inattendu ;
- erreur d’installation de paquet ;
- exécutable absent après installation ;
- chaîne de version inattendue ;
- échec de création du profil ;
- code de sortie non nul du smoke test headless.

Les diagnostics doivent indiquer la phase en échec et, lorsqu’elle est disponible, la version LibreOffice observée, tout en évitant autant que possible le bruit sans rapport du gestionnaire de paquets.

## Stratégie de tests

D2-04.0 exige deux niveaux de preuve.

### Tests statiques du contrat/script

Les tests du dépôt vérifient que l’installateur et le workflow préservent les propriétés contractuelles :

- version attendue = 7.4.7.2 ;
- URL de l’archive officielle épinglée ;
- vérification de version obligatoire ;
- usage d’un profil utilisateur isolé ;
- absence de fallback vers un LibreOffice système non épinglé.

### Exécution GitHub Actions réelle

Le livrable n’est pas `VALIDATED` tant qu’un run GitHub Actions frais n’a pas prouvé, sur un runner Ubuntu propre, que :

- l’archive officielle est téléchargeable ;
- LibreOffice 7.4.7.2 s’installe ;
- `--version` annonce 7.4.7.2 ;
- le démarrage/opération headless réussit ;
- le job se termine avec succès.

Les tests statiques seuls ne suffisent pas à clôturer le livrable.

## Sécurité et reproductibilité

L’installateur télécharge uniquement depuis l’archive officielle LibreOffice en HTTPS.

Le plan d’implémentation doit vérifier si un checksum amont stable est disponible et raisonnablement épinglable. Si oui, la vérification du checksum doit être intégrée. Sinon, le design ne doit ni inventer ni figer un digest non vérifié.

Aucun secret ni téléchargement authentifié n’est nécessaire.

Aucun état persistant du runner n’est supposé.

## Livrables

D2-04.0 doit produire :

- `tools/ci/install_libreoffice_7_4_7_2.sh` ;
- un workflow GitHub Actions dédié au socle runtime LibreOffice ;
- des tests statiques du contrat installateur/workflow ;
- `D2_04_0_REPORT.md` enregistrant les preuves runtime et le statut final.

Les noms exacts du workflow et des tests peuvent être affinés dans le plan d’implémentation, mais leurs responsabilités sont fixées par ce design.

## Critères de sortie

D2-04.0 est terminé uniquement lorsque toutes les conditions suivantes sont vraies :

1. LibreOffice 7.4.7.2 est installé depuis l’archive officielle sur un runner GitHub Actions vierge.
2. Le runtime annonce exactement 7.4.7.2.
3. LibreOffice démarre en mode headless avec un profil temporaire isolé.
4. L’opération smoke se termine avec succès et proprement.
5. La validation D2-03 existante reste inchangée.
6. Les tests statiques du contrat passent.
7. Un run CI réel et frais réussit.

Ce n’est qu’alors que `D2_04_0_REPORT.md` peut être marqué `VALIDATED`.

## Séquence suivante

Après D2-04.0 :

- **D2-04.1** — harness capable de charger CompareFramework et d’invoquer une macro LibreOffice Basic ;
- **D2-04.2** — exécution automatisée des scénarios fonctionnels T001–T010 ;
- **D2-04.3** — intégration de la politique CI/contrôles obligatoires pour protéger la régression runtime.
