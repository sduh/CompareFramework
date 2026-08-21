# D2-04.1 — Harness UNO pour LibreOffice Basic

## Statut

**DESIGN APPROUVÉ — plan d’implémentation en attente**

## Contexte

D2-04.0 a établi et validé le socle runtime LibreOffice 7.4.7.2 dans GitHub Actions. D2-04.1 ajoute le premier pont d’exécution réel entre la CI et le code Basic de CompareFramework.

Le socle runtime reste exactement LibreOffice **7.4.7.2**. Les autres versions LibreOffice sont hors périmètre de ce livrable.

CompareFramework est livré aux utilisateurs sous forme d’un fichier monolithique `.bas` généré. D2-04.1 valide donc la chaîne de livraison réelle au lieu de contourner le packaging en chargeant directement les modules `src/*.bas`.

## Objectif

Prouver, sur un runner GitHub Actions vierge, que le monolithe généré par `tools/build_monolith.py` peut être chargé dans un véritable document `.ods` sous LibreOffice 7.4.7.2, invoqué comme code LibreOffice Basic et produire un résultat déterministe que le harness CI peut vérifier sans interaction utilisateur.

Le chemin d’exécution contractuel est :

`src/*.bas -> tools/build_monolith.py -> dist/*.bas -> fixture CI .ods -> injection UNO -> CF_CI_RuntimeSmoke -> feuille CompareFramework_CI -> lecture UNO du résultat -> PASS/FAIL`

## Hors périmètre

D2-04.1 ne doit pas :

- exécuter les scénarios de régression métier T001–T010 ;
- exécuter une comparaison complète ;
- invoquer `CF_RunReleaseValidation` ;
- modifier les six procédures API utilisateur supportées et gelées par D2-03.24 ;
- introduire la prise en charge d’une version LibreOffice autre que 7.4.7.2 ;
- remplacer le monolithe par le chargement direct de `src/*.bas` ;
- introduire Docker ou un autre format de packaging.

L’automatisation des scénarios métier appartient à D2-04.2.

## Architecture

### 1. Le monolithe comme artefact testé

Le harness doit d’abord exécuter `tools/build_monolith.py` puis utiliser l’artefact monolithique `.bas` obtenu dans `dist/`.

Le harness ne doit jamais reconstruire CompareFramework à partir des modules sources individuels. D2-04.1 valide ainsi la même frontière de packaging que celle utilisée par les utilisateurs réels :

- parsing et assemblage des sources ;
- génération du monolithe ;
- chargement par LibreOffice Basic ;
- invocation runtime.

Un test réussi sur du code Basic obsolète ou embarqué à l’avance ne constitue pas une preuve acceptable.

### 2. Fixture CI `.ods` versionné

Ajouter un fixture `.ods` minimal dans un répertoire dédié aux fixtures CI, avec le chemin attendu :

`tests/fixtures/ci/CompareFramework_CI.ods`

Le fixture est un véritable document LibreOffice Calc, mais il ne contient pas une copie figée du monolithe CompareFramework. Le harness injecte toujours le monolithe fraîchement généré au runtime.

Le fixture contient, ou permet la création, de la feuille technique de résultat nommée exactement :

`CompareFramework_CI`

Le fixture sert de conteneur réel stable pour l’exécution Basic et constitue la base des futurs scénarios D2-04.2.

### 3. Orchestrateur Python/UNO

Ajouter un harness Python appartenant au dépôt, avec le chemin attendu :

`tools/ci/run_libreoffice_basic_smoke.py`

Ses responsabilités sont limitées et explicites :

1. localiser le monolithe généré ;
2. copier le fixture versionné dans un répertoire de travail temporaire ;
3. démarrer ou rejoindre LibreOffice 7.4.7.2 en mode headless avec un profil utilisateur temporaire isolé ;
4. ouvrir le `.ods` temporaire via UNO ;
5. injecter le monolithe dans une bibliothèque/un module Basic du document ;
6. résoudre et invoquer `CF_CI_RuntimeSmoke` ;
7. lire le résultat déterministe dans la feuille `CompareFramework_CI` ;
8. valider le contrat de résultat ;
9. fermer proprement le document et LibreOffice ;
10. retourner un code de sortie non nul pour toute étape en échec.

Le harness ne doit dépendre ni du profil LibreOffice d’un utilisateur, ni d’un état graphique, ni d’une session desktop, ni d’une validation de sécurité interactive.

### 4. Point d’entrée technique Basic de smoke test

Ajouter une procédure technique nommée exactement :

`CF_CI_RuntimeSmoke`

Cette procédure appartient au contrat de test runtime mais **ne fait pas partie** des six API utilisateur supportées gelées par D2-03.24.

Elle doit être non interactive et déterministe. Elle ne doit ouvrir aucun dialogue, lancer aucune comparaison, invoquer aucune validation release ni dépendre de données métier propres à un classeur.

Son unique objectif est de prouver que le monolithe CompareFramework fraîchement généré a été chargé et que du code Basic exécutable peut modifier le document CI actif.

Le contrat de résultat est :

- feuille : `CompareFramework_CI`
- `A1 = STATUS`
- `B1 = OK`
- `A2 = MARKER`
- `B2 = COMPAREFRAMEWORK_CI_SMOKE_OK`

Le harness déclare la réussite uniquement si `B1` et `B2` correspondent exactement aux valeurs attendues.

### 5. Compatibilité avec le gel de l’API publique

`CF_CI_RuntimeSmoke` ne doit pas être ajouté à `CompareFramework_API.bas` et ne doit pas modifier le contrat canonique des six API utilisateur supportées.

La procédure peut rester `Public` si l’invocation runtime LibreOffice Basic l’exige, mais la logique d’architecture/audit doit la classer comme point d’entrée technique CI hors de l’API utilisateur supportée.

Les tests de régression D2-03.24 doivent rester verts.

## Flux runtime

Le job GitHub Actions exécute la séquence suivante :

1. récupérer le dépôt ;
2. établir LibreOffice 7.4.7.2 avec l’installateur D2-04.0 validé ;
3. construire le monolithe courant avec `tools/build_monolith.py` ;
4. exécuter les tests statiques du contrat D2-04.1 ;
5. démarrer LibreOffice headless avec un profil temporaire unique et un timeout borné ;
6. établir la connexion UNO ;
7. ouvrir une copie temporaire de `CompareFramework_CI.ods` ;
8. injecter le monolithe fraîchement construit ;
9. invoquer `CF_CI_RuntimeSmoke` ;
10. vérifier les cellules `STATUS` et `MARKER` via UNO ;
11. fermer le document et arrêter proprement le processus LibreOffice.

Un code de sortie LibreOffice réussi ne suffit jamais, à lui seul, à valider le test. Les cellules de résultat constituent la preuve obligatoire de l’exécution Basic.

## Gestion des erreurs

D2-04.1 utilise une stratégie fail-fast avec diagnostics spécifiques à chaque étape.

Les échecs bloquants comprennent :

- version LibreOffice inattendue ;
- échec de construction du monolithe ;
- monolithe généré absent ou vide ;
- fixture absent ou invalide ;
- timeout au démarrage de LibreOffice ;
- timeout de connexion UNO ;
- échec d’ouverture du document ;
- échec d’injection de la bibliothèque/du module Basic ;
- `CF_CI_RuntimeSmoke` absent ou non résolvable ;
- échec d’invocation de la macro ;
- feuille de résultat absente ;
- `STATUS` différent de `OK` ;
- marqueur différent de `COMPAREFRAMEWORK_CI_SMOKE_OK` ;
- échec irrécupérable de fermeture du document/processus.

Le harness doit distinguer, lorsque c’est possible, les erreurs d’infrastructure LibreOffice des erreurs d’exécution CompareFramework.

Le nettoyage est obligatoire via un contrôle de type `try/finally` ou équivalent. Le harness tente toujours de fermer le document, nettoyer UNO, arrêter le processus et supprimer les fichiers/profils temporaires, même après une erreur.

Un timeout global empêche qu’un dialogue invisible, une macro bloquée ou une connexion UNO défaillante ne monopolise indéfiniment le runner CI.

## Stratégie de tests

### 1. Tests statiques du contrat

Les tests du dépôt vérifient au minimum :

- l’existence du fixture D2-04.1 ;
- que le harness connaît le contrat de feuille `CompareFramework_CI` ;
- que le harness attend `STATUS=OK` ;
- que le harness attend `COMPAREFRAMEWORK_CI_SMOKE_OK` ;
- que le monolithe généré contient `CF_CI_RuntimeSmoke` ;
- que le harness consomme un artefact construit depuis `dist/` plutôt que `src/*.bas` directement ;
- que D2-04.1 n’invoque ni T001–T010, ni comparaison métier, ni `CF_RunReleaseValidation` ;
- que les six API utilisateur supportées restent inchangées.

Les tests statiques sont nécessaires mais insuffisants pour valider le livrable.

### 2. Test d’intégration réel

Le test runtime GitHub Actions dédié doit prouver sous LibreOffice 7.4.7.2 que :

- le monolithe courant se construit avec succès ;
- le fixture s’ouvre via UNO ;
- l’injection dynamique du Basic réussit ;
- `CF_CI_RuntimeSmoke` se résout et s’exécute ;
- `CompareFramework_CI!B1` vaut exactement `OK` ;
- `CompareFramework_CI!B2` vaut exactement `COMPAREFRAMEWORK_CI_SMOKE_OK` ;
- le document et le processus LibreOffice se terminent proprement.

### 3. Preuves des chemins négatifs

D2-04.1 comprend deux validations négatives volontairement limitées :

1. invoquer une procédure Basic volontairement inexistante doit échouer avec un diagnostic de résolution/invocation de macro et un statut de harness non nul ;
2. valider avec un marqueur attendu volontairement incorrect doit échouer à l’étape de validation du résultat.

Ces contrôles prouvent que le harness détecte réellement les erreurs d’exécution/résultat plutôt que de simplement constater que LibreOffice s’est terminé.

## Relation avec la CI existante

Le socle runtime D2-04.0 validé reste la source du mécanisme d’installation de LibreOffice 7.4.7.2.

Le workflow cumulatif d’architecture/régression D2-03.24 reste vert et conserve sa responsabilité existante.

D2-04.1 peut étendre ou introduire un workflow runtime dédié, mais doit préserver une attribution claire des pannes entre :

- régressions d’architecture/build ;
- établissement du runtime LibreOffice ;
- erreurs du harness UNO ;
- erreurs d’injection/invocation Basic ;
- erreurs du contrat de résultat.

## Sécurité et exécution des macros

L’environnement CI est éphémère et utilise un profil LibreOffice temporaire isolé.

Le harness ne charge que le fixture appartenant au dépôt et du contenu Basic généré à partir du dépôt checkouté. Il ne doit pas affaiblir globalement la sécurité des macros d’un profil utilisateur persistant.

Si la sécurité des macros LibreOffice empêche l’exécution programmatique, l’implémentation doit résoudre cela uniquement dans le profil CI isolé ou via le mécanisme d’invocation UNO ; aucune approbation manuelle ni configuration système persistante ne doit être requise.

## Livrables attendus

D2-04.1 doit produire :

- `tools/ci/run_libreoffice_basic_smoke.py` ;
- `tests/fixtures/ci/CompareFramework_CI.ods` ;
- une source Basic technique contenant `CF_CI_RuntimeSmoke` et incluse dans le monolithe généré ;
- des tests statiques du contrat D2-04.1 ;
- l’intégration CI du véritable smoke test UNO/Basic ;
- `D2_04_1_REPORT.md` contenant les preuves runtime finales.

Les noms exacts des fichiers de support peuvent être affinés dans le plan d’implémentation tout en préservant ces responsabilités et ces contrats.

## Critères de validation

D2-04.1 est terminé uniquement lorsque toutes les conditions suivantes sont vraies :

1. LibreOffice est exactement en version 7.4.7.2.
2. `tools/build_monolith.py` produit l’artefact réellement injecté dans le fixture.
3. Le fixture `.ods` versionné est ouvert dans un LibreOffice headless avec profil isolé.
4. Le monolithe est injecté dynamiquement via UNO.
5. `CF_CI_RuntimeSmoke` est trouvé et exécuté comme véritable code LibreOffice Basic.
6. `CompareFramework_CI!B1` vaut exactement `OK`.
7. `CompareFramework_CI!B2` vaut exactement `COMPAREFRAMEWORK_CI_SMOKE_OK`.
8. La fermeture du document et du processus s’achève sans blocage.
9. Les tests statiques du contrat passent.
10. Les deux tests négatifs échouent pour les raisons attendues.
11. La validation cumulative D2-03.24 reste verte.
12. Un run GitHub Actions frais sur le HEAD final de la PR se termine avec `success`.

`D2_04_1_REPORT.md` reste `IMPLEMENTED — verification pending` jusqu’à l’existence de cette preuve runtime finale et fraîche. Ce n’est qu’ensuite que son statut peut devenir **VALIDATED**.

## Suite

Après D2-04.1, D2-04.2 réutilisera ce harness UNO et cette stratégie de fixture pour exécuter le catalogue de régression fonctionnelle existant T001–T010. D2-04.1 s’arrête volontairement avant l’orchestration de comparaisons métier afin que la frontière chargement-runtime/invocation de macro soit validée indépendamment en premier.
