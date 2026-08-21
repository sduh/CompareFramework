# D2-04.1 — Harness UNO pour LibreOffice Basic

## Statut

**VALIDATED**

## Contrat d’exécution

- Runtime : LibreOffice 7.4.7.2 uniquement
- Artefact Basic testé : monolithe produit par `tools/build_monolith.py`
- Fixture : `tests/fixtures/ci/CompareFramework_CI.ods`
- Orchestrateur : Python + UNO via `tools/ci/run_libreoffice_basic_smoke.py`
- Point d’entrée technique : `CF_CI_RuntimeSmoke`
- API utilisateur : les six procédures gelées D2-03.24 restent inchangées
- Feuille de résultat : `CompareFramework_CI`
- Résultat requis : `B1=OK`, `B2=COMPAREFRAMEWORK_CI_SMOKE_OK`

## Preuve de validation

Validation GitHub Actions réussie sur le commit `009f0b83c68072000ed614407836ba6b64b1f9d4` :

- workflow D2-04.1 : run `32470116909` / run #5 — **SUCCESS**
- runtime LibreOffice D2-04.0 : run `32470116913` / run #8 — **SUCCESS**
- validation cumulative D2-03.24 : run `32470116906` / run #11 — **SUCCESS**
- runner D2-04.1 : `ubuntu-22.04`
- version LibreOffice observée : `LibreOffice 7.4.7.2 723314e595e8007d3cf785c16538505a1c878ca5`
- génération du monolithe courant : **PASS**
- contrat statique D2-04.1 : **PASS** (6 tests)
- helpers purs du harness : **PASS** (5 tests)
- import PyUNO : **PASS**
- injection réelle du monolithe et exécution Basic : **PASS**
- résultat Basic observé : `STATUS=OK`
- marqueur Basic observé : `COMPAREFRAMEWORK_CI_SMOKE_OK`
- chemin négatif macro inexistante : **PASS** — le harness rejette correctement la procédure absente
- chemin négatif marqueur incorrect : **PASS** — la validation rejette correctement le marqueur volontairement erroné
- gel D2-03.24 des six API utilisateur : **PASS** après régénération de l’architecture canonique

## Notes d’implémentation

Le harness est versionné dans `tools/ci/run_libreoffice_basic_smoke.py`. Chaque exécution utilise un profil LibreOffice temporaire isolé et une copie temporaire du fixture.

Le point d’entrée technique se trouve dans `src/CompareFramework_CI.bas`. Il est intégré au monolithe généré par `MODULE_ORDER.txt` mais reste volontairement absent de `CompareFramework_API.bas`. L’audit d’architecture exclut explicitement ce point d’entrée CI technique de la revue de l’API utilisateur, tout en préservant les six API gelées.

## Périmètre

D2-04.1 ne lance aucun scénario métier T001–T010 et aucune comparaison fonctionnelle complète. Cette automatisation reste réservée à D2-04.2.

## Garde-fou final avant fusion

Le commit qui enregistre cette preuve doit lui-même recevoir des exécutions fraîches et réussies de D2-03.24, D2-04.0 et D2-04.1 avant toute fusion de la PR. Les succès du commit de preuve ci-dessus ne remplacent pas les checks du HEAD final de la PR.
