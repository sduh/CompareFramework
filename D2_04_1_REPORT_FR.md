# D2-04.1 — Harness UNO pour LibreOffice Basic

## Statut

**IMPLEMENTED — vérification en attente**

## Contrat d’exécution

- Runtime : LibreOffice 7.4.7.2 uniquement
- Artefact Basic testé : monolithe produit par `tools/build_monolith.py`
- Fixture : `tests/fixtures/ci/CompareFramework_CI.ods`
- Orchestrateur : `tools/ci/run_libreoffice_basic_smoke.py`
- Point d’entrée technique : `CF_CI_RuntimeSmoke`
- Résultat attendu : `CompareFramework_CI!B1 = OK`
- Marqueur attendu : `CompareFramework_CI!B2 = COMPAREFRAMEWORK_CI_SMOKE_OK`
- API utilisateur : les six procédures gelées D2-03.24 restent inchangées

## Validation requise

Le livrable devient **VALIDATED** uniquement après un run GitHub Actions frais sur le HEAD final prouvant :

1. installation de LibreOffice 7.4.7.2 depuis le mécanisme validé D2-04.0 ;
2. génération réussie du monolithe courant ;
3. ouverture réelle du fixture `.ods` via UNO ;
4. injection dynamique du monolithe dans la bibliothèque Basic du document ;
5. résolution et exécution de `CF_CI_RuntimeSmoke` ;
6. lecture exacte de `STATUS=OK` et `COMPAREFRAMEWORK_CI_SMOKE_OK` ;
7. échec contrôlé du scénario macro inexistante ;
8. échec contrôlé du scénario marqueur incorrect ;
9. maintien au vert de la validation cumulative D2-03.24.

## Périmètre

D2-04.1 ne lance aucun scénario métier T001–T010 et aucune comparaison fonctionnelle complète. Cette automatisation reste réservée à D2-04.2.
