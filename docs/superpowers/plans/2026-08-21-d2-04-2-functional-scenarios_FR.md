# D2-04.2 Plan d’implémentation — Automatisation des scénarios fonctionnels

> **Pour les agents d’implémentation :** SOUS-SKILL REQUIS : utiliser superpowers:subagent-driven-development (recommandé) ou superpowers:executing-plans pour exécuter ce plan tâche par tâche. Les étapes utilisent la syntaxe de cases à cocher (`- [ ]`) pour le suivi.

**Objectif :** Automatiser le catalogue officiel de régression fonctionnelle T001 à T010 avec LibreOffice 7.4.7.2 réel, le monolithe CompareFramework fraîchement construit, une orchestration UNO, les feuilles de sortie natives de CompareFramework et une comparaison stricte `actual.json` / `expected.json`.

**Architecture :** Réutiliser les primitives de processus et d’injection UNO de D2-04.1, mais exécuter chaque scénario fonctionnel dans son propre processus LibreOffice, son propre profil utilisateur temporaire et son propre document de travail. Python prépare `MODELE` et `TARGET` à partir des CSV existants et invoque le point d’entrée technique `CF_CI_RunScenario` ; LibreOffice Basic exécute le véritable chemin métier de comparaison par référence, tandis que Python se limite à extraire les sorties natives dans un contrat JSON normalisé et à effectuer une égalité stricte avec l’attendu canonique.

**Pile technique :** LibreOffice 7.4.7.2, LibreOffice Basic, Python 3, PyUNO/UNO, CSV, JSON, GitHub Actions `ubuntu-22.04`, Python `unittest`.

**Spec :** `docs/superpowers/specs/2026-08-21-d2-04-2-functional-scenarios-design_FR.md`

## Contraintes globales

- LibreOffice **7.4.7.2** est l’unique socle runtime de D2-04.2.
- L’artefact Basic testé est le monolithe produit par `tools/build_monolith.py` ; l’injection directe de modules `src/*.bas` individuels est interdite.
- Chaque scénario T001 à T010 utilise un processus LibreOffice, un profil temporaire et un document de travail distincts.
- `expected.json` est le contrat machine canonique ; `expected.md` reste la documentation humaine.
- `actual.json` est dérivé uniquement des feuilles de sortie natives de CompareFramework, jamais d’une réimplémentation Python de la logique de comparaison.
- `CF_CI_RunScenario` est un point d’entrée CI technique, hors `CompareFramework_API.bas` et hors des six API utilisateur gelées.
- `CF_CI_RuntimeSmoke` reste inchangé comme contrat smoke D2-04.1.
- Le schéma de résultat normalisé contient exactement : `scenario_id`, `decision`, `added_rows`, `deleted_rows`, `modified_rows`, `modified_cells`, `duplicate_ids`, `structure_alerts`.
- La suite complète doit poursuivre l’exécution après l’échec d’un scénario afin que la CI puisse signaler tous les cas en échec.
- D2-04.2 ne devient pas `VALIDATED` tant qu’un run GitHub Actions frais n’est pas réussi sur le HEAD final de la PR, avec D2-03.24, D2-04.0 et D2-04.1 également au vert.
- La documentation et les rapports sont maintenus en anglais et en français, avec des équivalents `_FR.md` portant le même statut et les mêmes preuves.

---

## Structure des fichiers

- Modifier `src/Modes/CF_ModeReference.bas` — ajouter le mode non interactif destiné à la CI, `CF_CI_RunScenario` et des totaux de synthèse natifs faisant autorité.
- Créer `tools/ci/run_functional_scenarios.py` — découverte des scénarios, préparation CSV vers Calc, exécution LibreOffice isolée, injection du monolithe, extraction des sorties natives, persistance JSON, comparaison stricte et diagnostics.
- Créer `tests/test_d2_04_2_scenario_contract.py` — contrat statique pour T001-T010, attentes JSON, gel API, point d’entrée Basic technique et workflow.
- Créer `tests/test_d2_04_2_runner_unit.py` — tests unitaires purs pour la découverte, la validation JSON, la comparaison stricte et les helpers d’extraction des feuilles natives.
- Créer `tests/datasets/*/expected.json` — contrats machine canoniques des dix scénarios officiels.
- Créer `.github/workflows/d2-04-2-functional-scenarios.yml` — workflow d’intégration réel LibreOffice 7.4.7.2 avec dépôt d’artefacts.
- Créer `D2_04_2_REPORT.md` et `D2_04_2_REPORT_FR.md` — rapports d’implémentation et preuves runtime finales.

### Tâche 1 : Introduire les attentes machine canoniques de T001 à T010

**Fichiers :**
- Créer : `tests/datasets/identical/expected.json`
- Créer : `tests/datasets/additions/expected.json`
- Créer : `tests/datasets/deletions/expected.json`
- Créer : `tests/datasets/modifications/expected.json`
- Créer : `tests/datasets/combined_changes/expected.json`
- Créer : `tests/datasets/duplicates/expected.json`
- Créer : `tests/datasets/missing_key_column/expected.json`
- Créer : `tests/datasets/extra_column/expected.json`
- Créer : `tests/datasets/reordered_columns/expected.json`
- Créer : `tests/datasets/typed_values/expected.json`
- Créer : `tests/test_d2_04_2_scenario_contract.py`

**Interfaces :**
- Consomme : `tests/catalog.md`, les `expected.md`, `MODELE.csv` et `TARGET.csv` de chaque scénario.
- Produit : exactement dix contrats machine validés avec le schéma commun à huit champs.

- [ ] **Étape 1 : Écrire le test de contrat en échec**

Créer `tests/test_d2_04_2_scenario_contract.py` avec une table fixe du catalogue et une validation du schéma :

```python
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATASETS = ROOT / "tests" / "datasets"
SCENARIOS = (
    ("T001", "identical"),
    ("T002", "additions"),
    ("T003", "deletions"),
    ("T004", "modifications"),
    ("T005", "combined_changes"),
    ("T006", "duplicates"),
    ("T007", "missing_key_column"),
    ("T008", "extra_column"),
    ("T009", "reordered_columns"),
    ("T010", "typed_values"),
)
FIELDS = {
    "scenario_id", "decision", "added_rows", "deleted_rows",
    "modified_rows", "modified_cells", "duplicate_ids", "structure_alerts",
}


class D2042ScenarioContractTests(unittest.TestCase):
    def test_exactly_t001_to_t010_have_machine_contracts(self):
        self.assertEqual(10, len(SCENARIOS))
        for scenario_id, folder in SCENARIOS:
            path = DATASETS / folder / "expected.json"
            self.assertTrue(path.is_file(), path)
            payload = json.loads(path.read_text(encoding="utf-8"))
            self.assertEqual(FIELDS, set(payload))
            self.assertEqual(scenario_id, payload["scenario_id"])
            self.assertIn(payload["decision"], {"OK", "ECARTS", "A CONTROLER"})
            for field in FIELDS - {"scenario_id", "decision"}:
                self.assertIsInstance(payload[field], int)
                self.assertGreaterEqual(payload[field], 0)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Étape 2 : Exécuter le test et confirmer RED**

```bash
PYTHONPATH=. python tests/test_d2_04_2_scenario_contract.py
```

Résultat attendu : FAIL car les dix fichiers `expected.json` n’existent pas encore.

- [ ] **Étape 3 : Ajouter les dix contrats JSON canoniques**

Utiliser exactement les attentes normalisées suivantes :

```text
T001 identical:          OK          0 ajout, 0 suppression, 0 ligne modifiée, 0 cellule modifiée, 0 doublon, 0 alerte
T002 additions:          ECARTS      1 ajout, 0 suppression, 0 ligne modifiée, 0 cellule modifiée, 0 doublon, 0 alerte
T003 deletions:          ECARTS      0 ajout, 1 suppression, 0 ligne modifiée, 0 cellule modifiée, 0 doublon, 0 alerte
T004 modifications:      ECARTS      0 ajout, 0 suppression, 1 ligne modifiée, 1 cellule modifiée, 0 doublon, 0 alerte
T005 combined_changes:   ECARTS      1 ajout, 1 suppression, 1 ligne modifiée, 1 cellule modifiée, 0 doublon, 0 alerte
T006 duplicates:         A CONTROLER 0 ajout, 0 suppression, 0 ligne modifiée, 0 cellule modifiée, 1 doublon, 0 alerte
T007 missing_key_column: A CONTROLER 0 ajout, 0 suppression, 0 ligne modifiée, 0 cellule modifiée, 0 doublon, 1 alerte
T008 extra_column:       A CONTROLER 0 ajout, 0 suppression, 0 ligne modifiée, 0 cellule modifiée, 0 doublon, 1 alerte
T009 reordered_columns:  OK          0 ajout, 0 suppression, 0 ligne modifiée, 0 cellule modifiée, 0 doublon, 0 alerte
T010 typed_values:       OK          0 ajout, 0 suppression, 0 ligne modifiée, 0 cellule modifiée, 0 doublon, 0 alerte
```

Chaque fichier contient les huit clés, par exemple :

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

- [ ] **Étape 4 : Exécuter le contrat en GREEN**

```bash
PYTHONPATH=. python tests/test_d2_04_2_scenario_contract.py
```

Résultat attendu : PASS.

- [ ] **Étape 5 : Commiter le contrat d’attentes**

```bash
git add tests/datasets/*/expected.json tests/test_d2_04_2_scenario_contract.py
git commit -m "test(D2-04.2): add canonical functional scenario contracts"
```

### Tâche 2 : Ajouter un point d’entrée Basic natif non interactif pour les scénarios

**Fichiers :**
- Modifier : `src/Modes/CF_ModeReference.bas`
- Étendre : `tests/test_d2_04_2_scenario_contract.py`
- Test de régression : `tests/test_d2_03_24_public_api_freeze.py`

**Interfaces :**
- Consomme : feuilles `MODELE` et `TARGET`, clé `ProductId`.
- Produit : feuilles CompareFramework normales, notamment `Stats_Comparaison`, `Rapport_Comparaison`, `Compare_Reference_Plan` et `Compare_Reference_Summary`, sans dialogue interactif.

- [ ] **Étape 1 : Ajouter les assertions source qui doivent échouer**

Étendre `tests/test_d2_04_2_scenario_contract.py` :

```python
REFERENCE_MODE = ROOT / "src" / "Modes" / "CF_ModeReference.bas"
API = ROOT / "src" / "CompareFramework_API.bas"


def test_ci_scenario_entrypoint_is_technical_and_noninteractive(self):
    text = REFERENCE_MODE.read_text(encoding="utf-8-sig")
    api = API.read_text(encoding="utf-8-sig")
    self.assertIn("Public Sub CF_CI_RunScenario()", text)
    self.assertIn('CF_REFERENCE_SELECTED_TARGETS = "TARGET"', text)
    self.assertIn('CF_RunAgainstReference "MODELE", "ProductId"', text)
    self.assertNotIn("CF_CI_RunScenario", api)
```

Exécuter le test et confirmer RED.

- [ ] **Étape 2 : Ajouter un drapeau silencieux au mode référence**

Dans `src/Modes/CF_ModeReference.bas`, ajouter :

```basic
Public CF_REFERENCE_SILENT As Boolean
```

Encadrer les `MsgBox` atteignables depuis `CF_RunAgainstReference` et `CF_ReferenceBuildSummary` par :

```basic
If Not CF_REFERENCE_SILENT Then
    MsgBox ...
End If
```

Le comportement interactif normal doit rester inchangé quand le drapeau vaut `False`.

- [ ] **Étape 3 : Ajouter `CF_CI_RunScenario` avec restauration d’état**

Ajouter dans `CF_ModeReference.bas` :

```basic
Public Sub CF_CI_RunScenario()
    Dim previousSilent As Boolean
    Dim previousMode As String
    Dim previousSelected As String

    On Error GoTo Cleanup

    previousSilent = CF_REFERENCE_SILENT
    previousMode = CF_REFERENCE_TARGET_MODE
    previousSelected = CF_REFERENCE_SELECTED_TARGETS

    CF_REFERENCE_SILENT = True
    CF_REFERENCE_TARGET_MODE = "SELECTED"
    CF_REFERENCE_SELECTED_TARGETS = "TARGET"

    CF_RunAgainstReference "MODELE", "ProductId"

Cleanup:
    CF_REFERENCE_SILENT = previousSilent
    CF_REFERENCE_TARGET_MODE = previousMode
    CF_REFERENCE_SELECTED_TARGETS = previousSelected
End Sub
```

Cette procédure doit appeler le véritable moteur de référence existant et ne doit contenir aucune logique de comparaison de lignes ou cellules spécifique à la CI.

- [ ] **Étape 4 : Rendre les totaux de `Compare_Reference_Summary` autoritatifs**

Modifier `CF_ReferenceBuildSummary` afin que la ligne `TOTAL` utilise les totaux déjà accumulés par `CF_RunAgainstReference`, y compris les incidents structurels ne créant pas de ligne de statistiques de paire. Modifier l’appel pour transmettre :

```basic
totalAdded, totalRemoved, totalChangedRows, totalChangedCells, _
totalDuplicates, totalIssues, targetCount
```

Les lignes par cible restent dérivées de `Stats_Comparaison`, mais la ligne TOTAL et sa décision sont écrites à partir de ces totaux transmis. Cette correction garantit notamment que T007 reste nativement `A CONTROLER` lorsqu’une cible est ignorée avant la production d’une ligne de stats de paire.

- [ ] **Étape 5 : Construire le monolithe et vérifier le point d’entrée**

```bash
python tools/build_monolith.py
grep -R "Public Sub CF_CI_RunScenario" dist/*.bas
```

Résultat attendu : build réussi et un match dans le monolithe généré.

- [ ] **Étape 6 : Vérifier le gel des six API utilisateur**

```bash
PYTHONPATH=. python -m tools.architecture --root . --summary
PYTHONPATH=. python tests/test_d2_03_24_public_api_freeze.py
```

Résultat attendu : PASS ; `CF_CI_RunScenario` reste technique et ne modifie pas la façade utilisateur supportée.

- [ ] **Étape 7 : Commiter le pont Basic natif**

```bash
git add src/Modes/CF_ModeReference.bas tests/test_d2_04_2_scenario_contract.py
git commit -m "feat(D2-04.2): add noninteractive reference scenario entrypoint"
```

### Tâche 3 : Implémenter la découverte des scénarios, la validation JSON et la comparaison stricte

**Fichiers :**
- Créer : `tools/ci/run_functional_scenarios.py`
- Créer : `tests/test_d2_04_2_runner_unit.py`

**Interfaces :**
- Produit : `Scenario`, `discover_scenarios`, `load_expected`, `compare_contracts`, `write_json`.
- Consommé par : l’exécution UNO réelle de la tâche 4.

- [ ] **Étape 1 : Écrire les tests unitaires purs en échec**

Tester l’ordre exact du catalogue, le rejet d’un JSON malformé, d’un champ manquant et d’une différence stricte :

```python
import unittest
from pathlib import Path

from tools.ci.run_functional_scenarios import (
    ScenarioContractError,
    compare_contracts,
    discover_scenarios,
)


class D2042RunnerUnitTests(unittest.TestCase):
    def test_discovery_returns_exact_t001_to_t010(self):
        scenarios = discover_scenarios(Path("tests/datasets"))
        self.assertEqual([f"T{i:03d}" for i in range(1, 11)], [s.scenario_id for s in scenarios])

    def test_strict_contract_detects_any_field_difference(self):
        expected = {
            "scenario_id": "T001", "decision": "OK", "added_rows": 0,
            "deleted_rows": 0, "modified_rows": 0, "modified_cells": 0,
            "duplicate_ids": 0, "structure_alerts": 0,
        }
        actual = dict(expected, added_rows=1)
        with self.assertRaises(ScenarioContractError):
            compare_contracts(expected, actual)
```

Exécuter et confirmer RED puisque le module n’existe pas.

- [ ] **Étape 2 : Implémenter le catalogue fixe et le modèle de données**

Dans `tools/ci/run_functional_scenarios.py` :

```python
from dataclasses import dataclass
from pathlib import Path

SCENARIO_CATALOG = (
    ("T001", "identical"), ("T002", "additions"),
    ("T003", "deletions"), ("T004", "modifications"),
    ("T005", "combined_changes"), ("T006", "duplicates"),
    ("T007", "missing_key_column"), ("T008", "extra_column"),
    ("T009", "reordered_columns"), ("T010", "typed_values"),
)
RESULT_FIELDS = (
    "scenario_id", "decision", "added_rows", "deleted_rows",
    "modified_rows", "modified_cells", "duplicate_ids", "structure_alerts",
)

@dataclass(frozen=True)
class Scenario:
    scenario_id: str
    name: str
    directory: Path
    model_csv: Path
    target_csv: Path
    expected_json: Path
```

Vérifier l’existence de tous les fichiers obligatoires avant de retourner un scénario.

- [ ] **Étape 3 : Implémenter le chargement exact et la comparaison**

`load_expected()` doit rejeter les champs manquants/supplémentaires, les décisions invalides, les compteurs non entiers ou négatifs et un `scenario_id` incohérent. `compare_contracts()` compare l’intégralité du mapping et indique les noms des champs divergents dans l’exception.

- [ ] **Étape 4 : Implémenter une persistance JSON stable**

```python
path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
```

- [ ] **Étape 5 : Exécuter les tests unitaires en GREEN**

```bash
PYTHONPATH=. python tests/test_d2_04_2_runner_unit.py
PYTHONPATH=. python tests/test_d2_04_2_scenario_contract.py
```

Résultat attendu : PASS.

- [ ] **Étape 6 : Commiter le contrat pur du runner**

```bash
git add tools/ci/run_functional_scenarios.py tests/test_d2_04_2_runner_unit.py
git commit -m "feat(D2-04.2): add functional scenario contract runner"
```

### Tâche 4 : Ajouter la préparation isolée des documents LibreOffice et l’extraction des résultats natifs

**Fichiers :**
- Modifier : `tools/ci/run_functional_scenarios.py`
- Étendre : `tests/test_d2_04_2_runner_unit.py`
- Réutiliser : `tools/ci/run_libreoffice_basic_smoke.py`

**Interfaces :**
- Réutilise : `choose_local_port`, `file_url`, `connect_uno`, `inject_monolith`, `invoke_macro`, `validate_version_output`.
- Produit : `actual.json` et `scenario.ods` conservés par scénario.

- [ ] **Étape 1 : Ajouter des tests d’extraction en échec avec de fausses feuilles UNO**

Créer de petits objets factices cellule/feuille et vérifier le mapping de la zone label/valeur de `Stats_Comparaison` :

```text
Lignes ajoutees       -> added_rows
Lignes supprimees     -> deleted_rows
Lignes modifiees      -> modified_rows
Cellules modifiees    -> modified_cells
ID doublons           -> duplicate_ids
Alertes structure     -> structure_alerts
```

Tester aussi que `Compare_Reference_Summary` est parcourue pour trouver la ligne dont la colonne A vaut exactement `TOTAL`, puis que la colonne H fournit `decision`.

- [ ] **Étape 2 : Importer et réutiliser les primitives UNO de D2-04.1**

```python
from tools.ci.run_libreoffice_basic_smoke import (
    choose_local_port,
    connect_uno,
    file_url,
    inject_monolith,
    invoke_macro,
    validate_version_output,
)
```

Ne pas recopier ces helpers.

- [ ] **Étape 3 : Créer un document Calc neuf et charger les CSV**

Pour chaque scénario :

1. démarrer un processus LibreOffice neuf avec profil temporaire et socket UNO propres ;
2. se connecter via UNO ;
3. créer un document Calc avec `private:factory/scalc` ;
4. renommer la première feuille en `MODELE` ;
5. créer une seconde feuille `TARGET` ;
6. lire les CSV avec `csv.reader` et recopier les tokens sources dans les cellules Calc via `.String` uniquement ;
7. enregistrer une copie de travail persistante sous `<artifacts>/<scenario_id>/scenario.ods` avec le filtre Calc `calc8`.

Python ne doit pas interpréter les tokens source pour décider de leur équivalence métier.

- [ ] **Étape 4 : Injecter le monolithe final et invoquer `CF_CI_RunScenario`**

Utiliser le même chemin de monolithe construit pour tous les scénarios de la suite. Vérifier `soffice --version` avant la suite. Chaque démarrage reste une unité runtime isolée. Invoquer exactement :

```text
CF_CI_RunScenario
```

- [ ] **Étape 5 : Extraire uniquement les sorties natives de CompareFramework**

Après le retour de la macro :

- lire les compteurs dans la zone de résumé global label/valeur de `Stats_Comparaison` ;
- lire `decision` sur la ligne `TOTAL` de `Compare_Reference_Summary` ;
- ne déduire aucun compteur ni décision depuis `MODELE`, `TARGET` ou `expected.json` ;
- produire une erreur d’extraction explicite si une feuille ou un label obligatoire est absent.

Construire :

```python
actual = {
    "scenario_id": scenario.scenario_id,
    "decision": decision,
    "added_rows": ...,
    "deleted_rows": ...,
    "modified_rows": ...,
    "modified_cells": ...,
    "duplicate_ids": ...,
    "structure_alerts": ...,
}
```

- [ ] **Étape 6 : Persister les artefacts et nettoyer chaque processus**

Écrire systématiquement `actual.json` dès que l’extraction réussit. En cas d’échec, écrire `diagnostic.txt`. Utiliser `try/finally` pour fermer/disposer le document, terminer le desktop, arrêter le processus LibreOffice et supprimer le profil temporaire. Ne conserver que le répertoire d’artefacts du scénario.

- [ ] **Étape 7 : Exécuter les tests purs en GREEN**

```bash
PYTHONPATH=. python tests/test_d2_04_2_runner_unit.py
PYTHONPATH=. python tests/test_d2_04_2_scenario_contract.py
```

Résultat attendu : PASS sans nécessiter LibreOffice.

- [ ] **Étape 8 : Commiter le cœur UNO des scénarios**

```bash
git add tools/ci/run_functional_scenarios.py tests/test_d2_04_2_runner_unit.py
git commit -m "feat(D2-04.2): execute isolated scenarios through UNO"
```

### Tâche 5 : Ajouter l’orchestration de la suite et le reporting complet des échecs

**Fichiers :**
- Modifier : `tools/ci/run_functional_scenarios.py`
- Étendre : `tests/test_d2_04_2_runner_unit.py`

**Interfaces :**
- Entrées CLI : `--soffice`, `--monolith`, `--datasets`, `--artifacts`, `--timeout`.
- Résultat CLI : code de sortie 0 uniquement pour `10/10 PASS` ; code non nul après les dix tentatives si au moins un scénario échoue.

- [ ] **Étape 1 : Ajouter les tests du résumé de suite**

Tester une fonction pure de formatage afin que deux échecs produisent deux lignes explicites et un total final non réussi, sans arrêt au premier échec.

- [ ] **Étape 2 : Implémenter le parsing CLI**

Utiliser comme valeurs par défaut stables :

```text
--datasets tests/datasets
--artifacts build/d2-04-2
--timeout 60
```

Rendre `--soffice` et `--monolith` obligatoires.

- [ ] **Étape 3 : Exécuter tous les scénarios indépendamment**

Pour chaque scénario découvert :

- créer `<artifacts>/<Txxx>/` ;
- y copier `expected.json` avant l’exécution ;
- exécuter un runtime isolé ;
- comparer strictement les contrats observé/attendu ;
- afficher `Txxx PASS` ou `Txxx FAIL: <classification>: <message>` ;
- poursuivre avec le scénario suivant après un échec.

À la fin, afficher `N/10 PASS` et retourner 0 uniquement si `N == 10`.

- [ ] **Étape 4 : Ajouter les classes d’échec explicites**

Utiliser des exceptions dédiées ou préfixes normalisés couvrant au minimum :

```text
CONTRACT
RUNTIME
UNO
INJECTION
MACRO
EXTRACTION
MISMATCH
TIMEOUT
CLEANUP
```

- [ ] **Étape 5 : Exécuter les tests unitaires en GREEN**

```bash
PYTHONPATH=. python tests/test_d2_04_2_runner_unit.py
```

Résultat attendu : PASS.

- [ ] **Étape 6 : Commiter le runner complet**

```bash
git add tools/ci/run_functional_scenarios.py tests/test_d2_04_2_runner_unit.py
git commit -m "feat(D2-04.2): report complete T001-T010 suite results"
```

### Tâche 6 : Ajouter le workflow GitHub Actions réel D2-04.2

**Fichiers :**
- Créer : `.github/workflows/d2-04-2-functional-scenarios.yml`
- Étendre : `tests/test_d2_04_2_scenario_contract.py`

**Interfaces :**
- Consomme : installateur D2-04.0 épinglé, monolithe construit, runner D2-04.2.
- Produit : check CI réel T001-T010 et artefacts de diagnostic téléversés même en cas d’échec.

- [ ] **Étape 1 : Étendre le test statique avec les exigences du workflow**

Vérifier la présence future de :

```text
ubuntu-22.04
install_libreoffice_7_4_7_2.sh
build_monolith.py
run_functional_scenarios.py
actions/upload-artifact@v4
build/d2-04-2
```

Exécuter et confirmer RED car le workflow n’existe pas encore.

- [ ] **Étape 2 : Créer le workflow dédié**

Créer `.github/workflows/d2-04-2-functional-scenarios.yml` :

```yaml
name: D2-04.2 functional scenarios T001-T010

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  functional-scenarios:
    runs-on: ubuntu-22.04
    timeout-minutes: 35
```

Ajouter ensuite les étapes suivantes :

1. checkout ;
2. installation LibreOffice 7.4.7.2 avec `tools/ci/install_libreoffice_7_4_7_2.sh` ;
3. build du monolithe ;
4. exécution de `tests/test_d2_04_2_scenario_contract.py` et `tests/test_d2_04_2_runner_unit.py` ;
5. résolution de PyUNO selon le mécanisme D2-04.1 ;
6. vérification de `import uno` ;
7. localisation de l’artefact `dist/*.bas` généré ;
8. exécution de `tools/ci/run_functional_scenarios.py` avec `--artifacts build/d2-04-2` ;
9. upload de `build/d2-04-2` avec `actions/upload-artifact@v4` et `if: always()` ;
10. régénération de l’architecture et exécution de `tests/test_d2_03_24_public_api_freeze.py`.

- [ ] **Étape 3 : Exécuter les tests statiques en GREEN**

```bash
PYTHONPATH=. python tests/test_d2_04_2_scenario_contract.py
PYTHONPATH=. python tests/test_d2_04_2_runner_unit.py
```

Résultat attendu : PASS.

- [ ] **Étape 4 : Reconstruire le monolithe**

```bash
python tools/build_monolith.py
```

Résultat attendu : succès avec tous les contrôles de build au vert.

- [ ] **Étape 5 : Commiter le workflow**

```bash
git add .github/workflows/d2-04-2-functional-scenarios.yml tests/test_d2_04_2_scenario_contract.py
git commit -m "ci(D2-04.2): run T001-T010 through LibreOffice"
```

### Tâche 7 : Produire les rapports bilingues, ouvrir la PR et valider le HEAD final

**Fichiers :**
- Créer : `D2_04_2_REPORT.md`
- Créer : `D2_04_2_REPORT_FR.md`
- Modifier après CI réussie : les deux rapports.

**Interfaces :**
- Consomme : les preuves GitHub Actions du HEAD final.
- Produit : statut auditable du livrable et garde de fusion.

- [ ] **Étape 1 : Créer les rapports avant validation dans les deux langues**

Statut :

```text
IMPLEMENTED — verification pending
```

Consigner :

- socle LibreOffice 7.4.7.2 ;
- un processus/profil/document isolé par scénario T001-T010 ;
- monolithe final comme artefact testé ;
- contrats stricts `expected.json` / `actual.json` ;
- extraction depuis les sorties natives uniquement ;
- exigence `10/10 PASS` et garde-fous précédents au vert.

- [ ] **Étape 2 : Exécuter la régression non-runtime complète avant PR**

```bash
PYTHONPATH=. python tests/test_d2_04_2_scenario_contract.py
PYTHONPATH=. python tests/test_d2_04_2_runner_unit.py
PYTHONPATH=. python tests/test_d2_04_1_harness_unit.py
PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py
PYTHONPATH=. python -m tools.architecture --root . --summary
PYTHONPATH=. python tests/test_d2_03_24_public_api_freeze.py
python tools/build_monolith.py
```

Résultat attendu : tous PASS.

- [ ] **Étape 3 : Commiter les rapports avant validation**

```bash
git add D2_04_2_REPORT.md D2_04_2_REPORT_FR.md
git commit -m "docs(D2-04.2): add functional scenario validation reports"
```

- [ ] **Étape 4 : Ouvrir une PR vers `main`**

Titre :

```text
D2-04.2 — Functional Scenario Automation T001-T010
```

Le corps précise que la validation finale nécessite une exécution LibreOffice 7.4.7.2 réelle et fraîche sur le HEAD de la PR.

- [ ] **Étape 5 : Inspecter le workflow D2-04.2 réel**

Exiger :

```text
T001 PASS
T002 PASS
T003 PASS
T004 PASS
T005 PASS
T006 PASS
T007 PASS
T008 PASS
T009 PASS
T010 PASS
10/10 PASS
```

Si un scénario échoue, examiner ses artefacts `expected.json`, `actual.json` si disponible, `scenario.ods` et `diagnostic.txt`, corriger la cause racine et relancer via un nouveau commit.

- [ ] **Étape 6 : Consigner les preuves runtime dans les deux rapports uniquement après succès réel**

Passer les deux statuts à `VALIDATED` et consigner :

- ID du run D2-04.2 réussi ;
- SHA du commit testé ;
- version LibreOffice observée ;
- résultat agrégé `10/10 PASS` ;
- confirmation que D2-03.24, D2-04.0 et D2-04.1 sont verts sur le même HEAD final.

- [ ] **Étape 7 : Commiter les preuves et exiger un nouveau run final**

```bash
git add D2_04_2_REPORT.md D2_04_2_REPORT_FR.md
git commit -m "docs(D2-04.2): record validated T001-T010 runtime evidence"
```

Ce commit modifie le HEAD de la PR : un succès antérieur ne suffit donc plus. Attendre des checks frais sur ce nouveau SHA.

- [ ] **Étape 8 : Fusionner uniquement si le HEAD final est totalement vert**

Vérifier que le run D2-04.2 réussi ainsi que les workflows précédents correspondent exactement au SHA HEAD final de la PR avant toute fusion.

## Résultat de l’auto-revue

- Couverture de la spec : version LibreOffice exacte, frontière monolithe, isolation par scénario, attentes machine, point d’entrée Basic technique, extraction native, contrats stricts, reporting de suite complète, artefacts, garde-fous précédents, rapports bilingues et garde de fusion sur HEAD frais sont tous couverts par des tâches d’implémentation.
- Recherche de placeholders : aucun TODO, TBD ou instruction différée ne subsiste.
- Cohérence des interfaces : `CF_CI_RunScenario`, les huit champs JSON normalisés, les identifiants T001-T010, les noms de feuilles natives et le répertoire d’artefacts du workflow sont cohérents entre les tâches.
- Périmètre : D2-04.2 s’arrête à l’automatisation T001-T010 et n’ajoute ni autre version LibreOffice ni refonte du moteur de comparaison.
