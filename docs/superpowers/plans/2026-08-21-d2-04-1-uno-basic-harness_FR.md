# D2-04.1 Plan d’implémentation du harness UNO pour LibreOffice Basic

> **Pour les agents d’implémentation :** SOUS-SKILL REQUIS : utiliser superpowers:subagent-driven-development (recommandé) ou superpowers:executing-plans pour exécuter ce plan tâche par tâche. Les étapes utilisent la syntaxe de cases à cocher (`- [ ]`) pour le suivi.

**Objectif :** Mettre en place un harness réel dans GitHub Actions qui construit le monolithe CompareFramework courant, l’injecte dans un fixture `.ods` versionné sous LibreOffice 7.4.7.2 via UNO, exécute `CF_CI_RuntimeSmoke` et valide un résultat déterministe lu dans la feuille `CompareFramework_CI`.

**Architecture :** Conserver D2-04.0 comme fournisseur du runtime et D2-03.24 comme garde-fou cumulatif d’architecture/régression. Ajouter un point d’entrée Basic technique hors des six API utilisateur, un fixture Calc minimal versionné, un orchestrateur Python/UNO focalisé, des tests de contrat statiques, des contrôles négatifs et un workflow GitHub Actions dédié à l’exécution réelle.

**Pile technique :** LibreOffice 7.4.7.2, LibreOffice Basic, Python 3, bridge PyUNO/UNO provenant de l’installation LibreOffice épinglée, GitHub Actions sur `ubuntu-22.04`, Python `unittest`.

**Spec :** `docs/superpowers/specs/2026-08-21-d2-04-1-uno-basic-harness-design_FR.md`

## Contraintes globales

- LibreOffice **7.4.7.2** est l’unique socle runtime supporté pour D2-04.1.
- L’artefact Basic testé est le monolithe produit par `tools/build_monolith.py` ; le chargement direct des fichiers individuels `src/*.bas` est interdit.
- Le fixture versionné est `tests/fixtures/ci/CompareFramework_CI.ods` et ne doit pas contenir une copie embarquée obsolète de CompareFramework.
- `CF_CI_RuntimeSmoke` est un point d’entrée CI technique et ne doit pas être ajouté à `CompareFramework_API.bas` ni aux six API utilisateur supportées gelées par D2-03.24.
- Le contrat de succès est `CompareFramework_CI!B1 == "OK"` et `CompareFramework_CI!B2 == "COMPAREFRAMEWORK_CI_SMOKE_OK"`.
- Aucun scénario métier T001–T010, aucun workflow de comparaison, aucun dialogue, launcher ou appel à `CF_RunReleaseValidation` ne fait partie de D2-04.1.
- Toute exécution LibreOffice utilise un profil utilisateur temporaire isolé et un timeout borné.
- D2-04.1 n’est pas `VALIDÉ` tant qu’un run GitHub Actions réel et récent n’a pas réussi sur le HEAD final de la PR.
- La documentation est maintenue en anglais et en français ; chaque nouveau plan/rapport D2-04.1 possède un équivalent `_FR.md` avec le même statut et les mêmes preuves de validation.

---

## Structure des fichiers

- Créer `src/CompareFramework_CI.bas` — point d’entrée Basic technique `CF_CI_RuntimeSmoke`, sans rôle d’API utilisateur.
- Créer `tests/fixtures/ci/CompareFramework_CI.ods` — document Calc réel minimal utilisé comme conteneur runtime.
- Créer `tools/ci/run_libreoffice_basic_smoke.py` — orchestrateur UNO pour démarrage du processus, ouverture du document, injection Basic, invocation, validation du résultat, nettoyage et modes négatifs.
- Créer `tests/test_d2_04_1_uno_harness_contract.py` — tests statiques de contrat pour la frontière de packaging, la compatibilité avec le gel d’API, le contrat fixture/harness et les appels métier interdits.
- Créer `.github/workflows/d2-04-1-uno-basic-harness.yml` — workflow réel d’intégration LibreOffice 7.4.7.2.
- Créer `D2_04_1_REPORT.md` et `D2_04_1_REPORT_FR.md` — rapports d’implémentation et de preuve.

### Tâche 1 : Définir le contrat statique D2-04.1 dans les tests

**Fichiers :**
- Créer : `tests/test_d2_04_1_uno_harness_contract.py`
- Tester ensuite : `src/CompareFramework_CI.bas`, `tools/ci/run_libreoffice_basic_smoke.py`, `tests/fixtures/ci/CompareFramework_CI.ods`, `.github/workflows/d2-04-1-uno-basic-harness.yml`

**Interfaces :**
- Consomme : racine du dépôt et contrat d’API gelé de D2-03.24.
- Produit : exigences statiques exécutables pour toutes les tâches D2-04.1 suivantes.

- [ ] **Étape 1 : Écrire les tests de contrat en échec**

Créer `tests/test_d2_04_1_uno_harness_contract.py` avec des tests équivalents à :

```python
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CI_BASIC = ROOT / "src" / "CompareFramework_CI.bas"
HARNESS = ROOT / "tools" / "ci" / "run_libreoffice_basic_smoke.py"
FIXTURE = ROOT / "tests" / "fixtures" / "ci" / "CompareFramework_CI.ods"
WORKFLOW = ROOT / ".github" / "workflows" / "d2-04-1-uno-basic-harness.yml"
API = ROOT / "src" / "CompareFramework_API.bas"


class D2041UnoHarnessContractTests(unittest.TestCase):
    def test_ci_basic_entrypoint_is_technical_and_not_user_api(self):
        ci_text = CI_BASIC.read_text(encoding="utf-8-sig")
        api_text = API.read_text(encoding="utf-8-sig")
        self.assertRegex(ci_text, r"(?mi)^\s*Public\s+Sub\s+CF_CI_RuntimeSmoke\b")
        self.assertNotIn("CF_CI_RuntimeSmoke", api_text)
        self.assertIn("COMPAREFRAMEWORK_CI_SMOKE_OK", ci_text)
        self.assertIn("CompareFramework_CI", ci_text)

    def test_harness_uses_built_monolith_and_result_contract(self):
        text = HARNESS.read_text(encoding="utf-8")
        self.assertIn("dist", text)
        self.assertIn("CF_CI_RuntimeSmoke", text)
        self.assertIn("CompareFramework_CI", text)
        self.assertIn("COMPAREFRAMEWORK_CI_SMOKE_OK", text)
        self.assertNotRegex(text, r"src/.+\.bas")

    def test_harness_does_not_run_business_regression(self):
        text = HARNESS.read_text(encoding="utf-8")
        for forbidden in (
            "CF_RunReleaseValidation",
            "CF_RunStandardComparison",
            "CF_StartReferenceComparison",
            "T001",
            "T010",
        ):
            self.assertNotIn(forbidden, text)

    def test_fixture_and_workflow_exist(self):
        self.assertTrue(FIXTURE.is_file())
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("install_libreoffice_7_4_7_2.sh", workflow)
        self.assertIn("build_monolith.py", workflow)
        self.assertIn("run_libreoffice_basic_smoke.py", workflow)
        self.assertIn("ubuntu-22.04", workflow)
```

- [ ] **Étape 2 : Exécuter les tests et confirmer RED**

```bash
PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py
```

Attendu : FAIL car le point d’entrée Basic, le harness, le fixture et le workflow D2-04.1 n’existent pas encore.

- [ ] **Étape 3 : Committer les tests RED**

```bash
git add tests/test_d2_04_1_uno_harness_contract.py
git commit -m "test(D2-04.1): define UNO Basic harness contract"
```

### Tâche 2 : Ajouter le point d’entrée technique de smoke runtime Basic

**Fichiers :**
- Créer : `src/CompareFramework_CI.bas`
- Tester : `tests/test_d2_04_1_uno_harness_contract.py`

**Interfaces :**
- Consomme : document Calc actif disponible via `ThisComponent`.
- Produit : feuille `CompareFramework_CI` avec `A1=STATUS`, `B1=OK`, `A2=MARKER`, `B2=COMPAREFRAMEWORK_CI_SMOKE_OK`.

- [ ] **Étape 1 : Ajouter un test source ciblé sur la sémantique exacte du smoke**

Ajouter au test de contrat :

```python
def test_ci_smoke_has_exact_noninteractive_result_contract(self):
    text = CI_BASIC.read_text(encoding="utf-8-sig")
    self.assertIn('getCellRangeByName("A1").String = "STATUS"', text)
    self.assertIn('getCellRangeByName("B1").String = "OK"', text)
    self.assertIn('getCellRangeByName("A2").String = "MARKER"', text)
    self.assertIn('getCellRangeByName("B2").String = "COMPAREFRAMEWORK_CI_SMOKE_OK"', text)
    self.assertNotRegex(text, r"(?i)MsgBox|InputBox|CF_RunReleaseValidation|CF_RunStandardComparison")
```

Exécuter le test et confirmer l’échec puisque `src/CompareFramework_CI.bas` est absent.

- [ ] **Étape 2 : Implémenter le point d’entrée Basic minimal**

Créer `src/CompareFramework_CI.bas` :

```basic
Option Explicit

' Point d’entrée technique uniquement destiné au smoke test CI.
' Il ne fait pas partie de l’API utilisateur supportée.
Public Sub CF_CI_RuntimeSmoke()
    Dim oDoc As Object
    Dim oSheets As Object
    Dim oSheet As Object

    oDoc = ThisComponent
    oSheets = oDoc.Sheets

    If oSheets.hasByName("CompareFramework_CI") Then
        oSheet = oSheets.getByName("CompareFramework_CI")
    Else
        oSheets.insertNewByName("CompareFramework_CI", oSheets.getCount())
        oSheet = oSheets.getByName("CompareFramework_CI")
    End If

    oSheet.getCellRangeByName("A1").String = "STATUS"
    oSheet.getCellRangeByName("B1").String = "OK"
    oSheet.getCellRangeByName("A2").String = "MARKER"
    oSheet.getCellRangeByName("B2").String = "COMPAREFRAMEWORK_CI_SMOKE_OK"
End Sub
```

Ne pas ajouter cette procédure à `CompareFramework_API.bas`.

- [ ] **Étape 3 : Construire le monolithe et prouver l’inclusion du point d’entrée**

```bash
python tools/build_monolith.py
grep -R "Public Sub CF_CI_RuntimeSmoke" dist/*.bas
```

Attendu : build réussi et présence de `CF_CI_RuntimeSmoke` dans le monolithe généré.

- [ ] **Étape 4 : Relancer la régression du gel d’API D2-03.24**

```bash
PYTHONPATH=. python tests/test_d2_03_24_public_api_freeze.py
```

Attendu : PASS, l’API supportée reste exactement à six procédures.

- [ ] **Étape 5 : Committer le point d’entrée Basic**

```bash
git add src/CompareFramework_CI.bas tests/test_d2_04_1_uno_harness_contract.py
git commit -m "feat(D2-04.1): add technical Basic runtime smoke entrypoint"
```

### Tâche 3 : Créer le fixture Calc minimal versionné

**Fichiers :**
- Créer binaire : `tests/fixtures/ci/CompareFramework_CI.ods`
- Tester : `tests/test_d2_04_1_uno_harness_contract.py`

**Interfaces :**
- Consomme : aucun code CompareFramework au repos.
- Produit : document Calc `.ods` valide contenant une feuille `CompareFramework_CI` mais aucune copie du monolithe CompareFramework.

- [ ] **Étape 1 : Créer le fixture avec LibreOffice 7.4.7.2**

Avec le runtime D2-04.0, créer un classeur Calc vierge avec une feuille unique nommée `CompareFramework_CI`, puis l’enregistrer sous :

```text
tests/fixtures/ci/CompareFramework_CI.ods
```

Le fixture ne doit contenir aucun module Basic nommé `CompareFramework`, `CompareFramework_CI`, ni copie du monolithe généré.

- [ ] **Étape 2 : Ajouter un test structurel du fixture**

Traiter `.ods` comme un ZIP et vérifier qu’il s’agit d’un véritable classeur OpenDocument :

```python
import zipfile


def test_fixture_is_valid_ods_container(self):
    self.assertTrue(FIXTURE.is_file())
    with zipfile.ZipFile(FIXTURE) as archive:
        names = set(archive.namelist())
        self.assertIn("mimetype", names)
        self.assertIn("content.xml", names)
        mimetype = archive.read("mimetype").decode("ascii")
        self.assertEqual("application/vnd.oasis.opendocument.spreadsheet", mimetype)
```

- [ ] **Étape 3 : Exécuter le test de contrat**

```bash
PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py
```

Attendu : assertions liées au fixture PASS ; assertions harness/workflow encore RED jusqu’aux tâches suivantes.

- [ ] **Étape 4 : Committer le fixture**

```bash
git add tests/fixtures/ci/CompareFramework_CI.ods tests/test_d2_04_1_uno_harness_contract.py
git commit -m "test(D2-04.1): add minimal Calc CI fixture"
```

### Tâche 4 : Implémenter le cœur du harness Python/UNO

**Fichiers :**
- Créer : `tools/ci/run_libreoffice_basic_smoke.py`
- Tester : `tests/test_d2_04_1_uno_harness_contract.py`
- Créer test unitaire : `tests/test_d2_04_1_harness_unit.py`

**Interfaces :**
- Consomme : `--soffice`, `--fixture`, `--monolith`, `--macro-name` optionnel, `--expected-marker` optionnel, timeout.
- Produit : code retour `0` uniquement si l’invocation macro et le contrat exact de résultat réussissent ; échec non nul avec diagnostic de phase dans les autres cas.

- [ ] **Étape 1 : Écrire les tests unitaires des helpers purs avant le code UNO**

Créer `tests/test_d2_04_1_harness_unit.py` :

```python
import unittest

from tools.ci.run_libreoffice_basic_smoke import (
    ResultContractError,
    validate_result_values,
)


class HarnessUnitTests(unittest.TestCase):
    def test_exact_result_contract_passes(self):
        validate_result_values("OK", "COMPAREFRAMEWORK_CI_SMOKE_OK")

    def test_wrong_status_fails(self):
        with self.assertRaises(ResultContractError):
            validate_result_values("KO", "COMPAREFRAMEWORK_CI_SMOKE_OK")

    def test_wrong_marker_fails(self):
        with self.assertRaises(ResultContractError):
            validate_result_values("OK", "WRONG")
```

Exécuter et confirmer RED car le module harness n’existe pas encore.

- [ ] **Étape 2 : Implémenter les helpers de contrat purs et le parsing CLI**

Créer `tools/ci/run_libreoffice_basic_smoke.py` avec au minimum :

```python
from __future__ import annotations

import argparse
from pathlib import Path

EXPECTED_STATUS = "OK"
EXPECTED_MARKER = "COMPAREFRAMEWORK_CI_SMOKE_OK"
RESULT_SHEET = "CompareFramework_CI"
DEFAULT_MACRO = "CF_CI_RuntimeSmoke"


class HarnessError(RuntimeError):
    pass


class ResultContractError(HarnessError):
    pass


def validate_result_values(status: str, marker: str, expected_marker: str = EXPECTED_MARKER) -> None:
    if status != EXPECTED_STATUS:
        raise ResultContractError(f"result validation failed: expected STATUS=OK, got {status!r}")
    if marker != expected_marker:
        raise ResultContractError(
            f"result validation failed: expected marker {expected_marker!r}, got {marker!r}"
        )


def parse_args(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--soffice", required=True)
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--monolith", type=Path, required=True)
    parser.add_argument("--macro-name", default=DEFAULT_MACRO)
    parser.add_argument("--expected-marker", default=EXPECTED_MARKER)
    parser.add_argument("--timeout", type=int, default=60)
    return parser.parse_args(argv)
```

Exécuter les tests unitaires et vérifier GREEN pour cette couche pure.

- [ ] **Étape 3 : Ajouter la validation fail-fast des entrées**

Ajouter des helpers exigeant :

- fixture existant et non vide ;
- monolithe existant, non vide et contenant le nom de macro demandé ;
- sortie de `soffice --version` contenant exactement `7.4.7.2` avant démarrage runtime.

Ajouter des tests unitaires pour fixture absent, monolithe absent, macro absente du monolithe et chaîne de version LibreOffice incorrecte.

- [ ] **Étape 4 : Implémenter le démarrage LibreOffice isolé et la connexion UNO**

Le harness doit :

1. créer un profil temporaire et un répertoire de travail temporaire ;
2. copier le fixture dans ce répertoire ;
3. choisir dynamiquement un port TCP localhost ;
4. démarrer `${soffice}` avec :

```text
--headless
--nologo
--nodefault
--nofirststartwizard
-env:UserInstallation=file://<profil-temporaire>
--accept=socket,host=127.0.0.1,port=<port>;urp;StarOffice.ComponentContext
```

5. se connecter via l’environnement Python/UNO fourni par LibreOffice ;
6. retenter la connexion jusqu’au timeout puis lever `HarnessError("UNO connection timeout ...")`.

Conserver démarrage du processus, retry de connexion et nettoyage dans des helpers focalisés pour que les diagnostics indiquent clairement la phase en échec.

- [ ] **Étape 5 : Implémenter l’ouverture du document et l’injection Basic dynamique**

Via UNO :

- convertir le chemin de la copie du fixture en URL fichier ;
- l’ouvrir caché via le desktop loader ;
- accéder au conteneur de bibliothèques Basic du document ;
- s’assurer que `Standard` existe et est chargé ;
- supprimer un éventuel module `CompareFramework_CI_Runtime` déjà présent ;
- insérer l’intégralité du monolithe fraîchement généré dans le module `CompareFramework_CI_Runtime`.

Ne charger aucun fichier individuel `src/*.bas`.

- [ ] **Étape 6 : Résoudre et invoquer la macro via le provider de scripts du document**

Résoudre :

```text
vnd.sun.star.script:Standard.CompareFramework_CI_Runtime.<macro-name>?language=Basic&location=document
```

Invoquer sans argument et convertir les exceptions UNO en :

```text
macro invocation failed: <macro-name>: <exception>
```

Une macro inexistante fournie via `--macro-name` doit produire un code non nul et contenir `macro invocation failed` ou `macro resolution failed` dans stderr.

- [ ] **Étape 7 : Lire le contrat exact de résultat via UNO**

Après invocation, lire :

```text
CompareFramework_CI!B1
CompareFramework_CI!B2
```

Puis appeler `validate_result_values(status, marker, expected_marker)`.

Un mauvais `--expected-marker` doit atteindre cette phase et échouer avec `result validation failed`.

- [ ] **Étape 8 : Implémenter un nettoyage inconditionnel et une sortie déterministe**

Utiliser `try/finally` pour toujours tenter de :

- fermer le document sans dialogue de sauvegarde ;
- terminer LibreOffice ;
- attendre brièvement puis tuer le processus uniquement si nécessaire ;
- supprimer profil et répertoire de travail temporaires.

Comportement principal :

```python
try:
    run_smoke(...)
except HarnessError as exc:
    print(f"D2-04.1 FAIL: {exc}", file=sys.stderr)
    return 1
print("D2-04.1 PASS: LibreOffice Basic runtime smoke completed")
return 0
```

- [ ] **Étape 9 : Exécuter tests unitaires et statiques**

```bash
PYTHONPATH=. python tests/test_d2_04_1_harness_unit.py
PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py
python -m py_compile tools/ci/run_libreoffice_basic_smoke.py
```

Attendu : tests unitaires PASS ; toutes les assertions statiques sauf existence du workflow PASS.

- [ ] **Étape 10 : Committer le cœur du harness**

```bash
git add tools/ci/run_libreoffice_basic_smoke.py tests/test_d2_04_1_harness_unit.py tests/test_d2_04_1_uno_harness_contract.py
git commit -m "feat(D2-04.1): add Python UNO Basic smoke harness"
```

### Tâche 5 : Ajouter le workflow réel d’intégration LibreOffice 7.4.7.2

**Fichiers :**
- Créer : `.github/workflows/d2-04-1-uno-basic-harness.yml`
- Tester : `tests/test_d2_04_1_uno_harness_contract.py`

**Interfaces :**
- Consomme : installateur D2-04.0, builder monolithe, fixture, harness Python/UNO.
- Produit : preuve runtime positive et deux preuves de chemin négatif.

- [ ] **Étape 1 : Créer le workflow dédié**

Créer `.github/workflows/d2-04-1-uno-basic-harness.yml` avec les étapes suivantes :

```yaml
name: D2-04.1 LibreOffice Basic UNO harness

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  uno-basic-smoke:
    runs-on: ubuntu-22.04
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v4

      - name: Static D2-04.1 contract
        run: PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py

      - name: Harness unit tests
        run: PYTHONPATH=. python tests/test_d2_04_1_harness_unit.py

      - name: Install LibreOffice 7.4.7.2
        run: bash tools/ci/install_libreoffice_7_4_7_2.sh

      - name: Build current monolith
        run: python tools/build_monolith.py

      - name: Locate monolith and LibreOffice Python environment
        shell: bash
        run: |
          monolith="$(find dist -maxdepth 1 -type f -name '*.bas' | sort | tail -n 1)"
          test -n "${monolith}"
          echo "CF_MONOLITH=${monolith}" >> "${GITHUB_ENV}"
          test -n "${SOFFICE_BIN}"

      - name: Positive UNO Basic runtime smoke
        run: |
          python tools/ci/run_libreoffice_basic_smoke.py \
            --soffice "${SOFFICE_BIN}" \
            --fixture tests/fixtures/ci/CompareFramework_CI.ods \
            --monolith "${CF_MONOLITH}"

      - name: Negative proof - nonexistent macro must fail
        shell: bash
        run: |
          set +e
          output="$(python tools/ci/run_libreoffice_basic_smoke.py \
            --soffice "${SOFFICE_BIN}" \
            --fixture tests/fixtures/ci/CompareFramework_CI.ods \
            --monolith "${CF_MONOLITH}" \
            --macro-name CF_CI_RuntimeSmoke_DOES_NOT_EXIST 2>&1)"
          rc=$?
          set -e
          echo "${output}"
          test ${rc} -ne 0
          grep -E "macro (resolution|invocation) failed" <<<"${output}"

      - name: Negative proof - wrong marker must fail at validation
        shell: bash
        run: |
          set +e
          output="$(python tools/ci/run_libreoffice_basic_smoke.py \
            --soffice "${SOFFICE_BIN}" \
            --fixture tests/fixtures/ci/CompareFramework_CI.ods \
            --monolith "${CF_MONOLITH}" \
            --expected-marker WRONG_MARKER 2>&1)"
          rc=$?
          set -e
          echo "${output}"
          test ${rc} -ne 0
          grep -F "result validation failed" <<<"${output}"
```

Si le Python embarqué de LibreOffice ou un ajustement `PYTHONPATH` est nécessaire pour `import uno`, l’encoder explicitement après observation des chemins réels de l’installation 7.4.7.2 ; ne pas installer un paquet PyPI `uno` non lié comme substitut.

- [ ] **Étape 2 : Exécuter le test statique de contrat GREEN**

```bash
PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py
```

Attendu : toutes les assertions statiques PASS.

- [ ] **Étape 3 : Relancer les régressions cumulatives existantes**

Exécuter la séquence non-runtime de D2-03.24, notamment :

```bash
python -m tools.architecture --root . --summary
PYTHONPATH=. python tests/test_d2_03_24_public_api_freeze.py
python tools/build_monolith.py
```

Attendu : PASS.

- [ ] **Étape 4 : Committer le workflow**

```bash
git add .github/workflows/d2-04-1-uno-basic-harness.yml tests/test_d2_04_1_uno_harness_contract.py
git commit -m "ci(D2-04.1): execute monolith through LibreOffice UNO"
```

### Tâche 6 : Produire les rapports bilingues et les preuves CI réelles

**Fichiers :**
- Créer : `D2_04_1_REPORT.md`
- Créer : `D2_04_1_REPORT_FR.md`
- Modifier les deux après validation runtime réussie.

**Interfaces :**
- Consomme : résultats réels du workflow D2-04.1 et validation cumulative D2-03.24 sur le même HEAD de PR.
- Produit : preuves bilingues auditables et garde-fou de merge.

- [ ] **Étape 1 : Créer les deux rapports avant validation**

`D2_04_1_REPORT.md` commence par :

```markdown
# D2-04.1 — LibreOffice Basic UNO Harness

## Status

**IMPLEMENTED — verification pending**
```

`D2_04_1_REPORT_FR.md` commence par :

```markdown
# D2-04.1 — Harness UNO pour LibreOffice Basic

## Statut

**IMPLÉMENTÉ — validation en attente**
```

Les deux rapports enregistrent les mêmes contrats : LibreOffice 7.4.7.2, monolithe fraîchement construit, fixture versionné, injection UNO dynamique, `CF_CI_RuntimeSmoke`, cellules de résultat exactes, exigences de chemins négatifs et garde-fou final de run récent.

- [ ] **Étape 2 : Committer les rapports d’implémentation**

```bash
git add D2_04_1_REPORT.md D2_04_1_REPORT_FR.md
git commit -m "docs(D2-04.1): add bilingual UNO harness reports"
```

- [ ] **Étape 3 : Ouvrir une PR vers `main`**

Titre :

```text
D2-04.1 — LibreOffice Basic UNO Harness
```

Le corps de PR doit préciser :

- LibreOffice exactement en version 7.4.7.2 ;
- le monolithe est construit depuis le `src/` courant puis injecté dynamiquement ;
- le fixture est versionné et ne contient pas de copie obsolète de CompareFramework ;
- `CF_CI_RuntimeSmoke` est technique et hors des six API utilisateur supportées ;
- la validation reste en attente tant que les contrôles runtime positifs et négatifs réels n’ont pas réussi.

- [ ] **Étape 4 : Inspecter le premier run réel du workflow**

Exiger simultanément :

- `D2-04.1 LibreOffice Basic UNO harness` en `completed / success` ;
- validation cumulative D2-03.24 existante en `completed / success` sur le même HEAD de PR.

Si le job UNO échoue, inspecter la phase exacte et les logs. Appliquer le processus systematic-debugging ; ne pas affaiblir le contrat pour rendre le workflow vert.

- [ ] **Étape 5 : Reporter les preuves exactes de succès dans les deux rapports**

Après un run D2-04.1 réellement vert, mettre à jour les deux versions linguistiques avec les mêmes faits :

- ID du workflow run ;
- SHA du commit testé ;
- version LibreOffice observée ;
- chemin/nom du monolithe utilisé ;
- résultat positif de `CF_CI_RuntimeSmoke` ;
- preuve `STATUS=OK` ;
- preuve `MARKER=COMPAREFRAMEWORK_CI_SMOKE_OK` ;
- preuve négative macro inexistante PASS ;
- preuve négative mauvais marqueur PASS ;
- validation cumulative D2-03.24 PASS.

Passer les statuts à `VALIDATED` / `VALIDÉ` uniquement à ce stade.

- [ ] **Étape 6 : Committer les preuves validées**

```bash
git add D2_04_1_REPORT.md D2_04_1_REPORT_FR.md
git commit -m "docs(D2-04.1): record validated UNO runtime evidence"
```

Ce commit de preuve crée un nouveau HEAD de PR et doit lui-même obtenir un nouveau run D2-04.1 réussi ainsi qu’un run cumulatif D2-03.24 réussi.

- [ ] **Étape 7 : Merger uniquement avec des checks frais et verts sur le HEAD final**

Vérifier que le SHA du commit des workflows réussis correspond exactement au HEAD courant de la PR avant merge. Ne pas réutiliser un succès obtenu sur le commit précédent.

## Résultat de l’auto-revue

- Couverture de la spec : frontière de packaging monolithe, fixture versionné, orchestration UNO, point d’entrée Basic technique, compatibilité avec le gel d’API, contrat exact de résultat, gestion fail-fast des erreurs, nettoyage, timeout global, preuve runtime positive, deux chemins négatifs obligatoires, compatibilité avec la régression cumulative, documentation bilingue et garde-fou final de merge sur run récent sont tous reliés à des tâches.
- Recherche de placeholders : aucun `TODO`, `TBD` ou étape d’implémentation non spécifiée.
- Cohérence des interfaces : `CF_CI_RuntimeSmoke`, `CompareFramework_CI`, `STATUS=OK`, `COMPAREFRAMEWORK_CI_SMOKE_OK`, chemins du fixture, du harness et du workflow sont cohérents entre les tâches.
