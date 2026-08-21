# Plan d’implémentation D2-04.0 — Runtime CI LibreOffice 7.4.7.2

> **Pour les agents d’implémentation :** SOUS-SKILL REQUIS : utiliser `superpowers:subagent-driven-development` (recommandé) ou `superpowers:executing-plans` pour exécuter ce plan tâche par tâche. Les étapes utilisent la syntaxe de cases à cocher (`- [ ]`) pour le suivi.

**Objectif :** Établir un runtime GitHub Actions reproductible qui installe et smoke-teste exactement LibreOffice 7.4.7.2 depuis l’archive officielle LibreOffice.

**Architecture :** Conserver inchangé le workflow Python/architecture D2-03.24 existant. Ajouter un installateur appartenant au dépôt sous `tools/ci/`, des tests statiques du contrat qui figent son comportement et un workflow GitHub Actions distinct qui installe LibreOffice 7.4.7.2 sur un runner Ubuntu propre puis exécute une opération smoke headless avec un profil utilisateur temporaire isolé.

**Stack technique :** Bash, GitHub Actions, runner Ubuntu hébergé, paquets Debian Linux x86_64 LibreOffice 7.4.7.2, Python `unittest` pour les tests statiques du contrat.

**Spec :** `docs/superpowers/specs/2026-08-20-d2-04-0-libreoffice-7-4-7-2-ci-runtime-design.md`

## Contraintes globales

- LibreOffice **7.4.7.2** est l’unique socle runtime supporté pour D2-04.0.
- Les paquets doivent provenir de l’archive officielle LibreOffice ; aucun `apt install libreoffice` Ubuntu, miroir tiers, image Docker ni fallback de version.
- Le contrôle de version doit échouer sauf si la version observée contient exactement `7.4.7.2`.
- Toute exécution headless doit utiliser un profil utilisateur LibreOffice temporaire isolé.
- D2-04.0 ne doit exécuter ni macro Basic CompareFramework ni scénario métier T001–T010.
- `.github/workflows/d2-03-24-validation.yml` reste inchangé.
- D2-04.0 n’est pas `VALIDATED` tant qu’un véritable run GitHub Actions frais n’a pas réussi.

---

## Structure des fichiers

- Créer `tools/ci/install_libreoffice_7_4_7_2.sh` — responsable unique du téléchargement de l’archive, de l’extraction, de l’installation des paquets, de la découverte de l’exécutable et de la vérification exacte de version.
- Créer `tests/test_d2_04_0_libreoffice_runtime_contract.py` — tests statiques du gel de version, de la provenance officielle, du fail-fast, de la politique de profil isolé et de l’absence de fallback vers un LibreOffice système non épinglé.
- Créer `.github/workflows/d2-04-0-libreoffice-7-4-7-2.yml` — job CI dédié au runtime réel.
- Créer `D2_04_0_REPORT.md` — document de preuve/statut ; commence par `IMPLEMENTED — verification pending` et passe à `VALIDATED` uniquement après un run réel réussi.

### Tâche 1 : Figer et tester le contrat de l’installateur

**Fichiers :**
- Créer : `tests/test_d2_04_0_libreoffice_runtime_contract.py`
- Créé plus tard en tâche 2 : `tools/ci/install_libreoffice_7_4_7_2.sh`

**Interfaces :**
- Consomme : racine du dépôt et futurs chemins attendus de l’installateur/workflow.
- Produit : tests statiques de régression définissant le contrat runtime D2-04.0.

- [ ] **Étape 1 : Écrire les tests RED du contrat installateur**

Créer `tests/test_d2_04_0_libreoffice_runtime_contract.py` avec des tests équivalents à :

```python
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = ROOT / "tools" / "ci" / "install_libreoffice_7_4_7_2.sh"
WORKFLOW = ROOT / ".github" / "workflows" / "d2-04-0-libreoffice-7-4-7-2.yml"


class D2040LibreOfficeRuntimeContractTests(unittest.TestCase):
    def test_installer_pins_exact_version_and_official_archive(self):
        text = INSTALLER.read_text(encoding="utf-8")
        self.assertIn('LO_VERSION="7.4.7.2"', text)
        self.assertIn("downloadarchive.documentfoundation.org/libreoffice/old/7.4.7.2", text)
        self.assertNotRegex(text, r"apt(?:-get)?\s+install\s+.*\blibreoffice\b")

    def test_installer_is_fail_fast_and_checks_version(self):
        text = INSTALLER.read_text(encoding="utf-8")
        self.assertRegex(text, r"(?m)^set -euo pipefail$")
        self.assertIn("--version", text)
        self.assertIn("7.4.7.2", text)

    def test_workflow_uses_dedicated_installer_and_isolated_profile(self):
        text = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("tools/ci/install_libreoffice_7_4_7_2.sh", text)
        self.assertIn("mktemp -d", text)
        self.assertIn("-env:UserInstallation=file://", text)
        self.assertNotIn("apt install libreoffice", text)
        self.assertNotIn("apt-get install libreoffice", text)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Étape 2 : Exécuter les nouveaux tests et confirmer RED**

Exécuter :

```bash
PYTHONPATH=. python tests/test_d2_04_0_libreoffice_runtime_contract.py
```

Attendu : FAIL car les fichiers installateur et workflow n’existent pas encore.

- [ ] **Étape 3 : Commiter les tests RED du contrat**

```bash
git add tests/test_d2_04_0_libreoffice_runtime_contract.py
git commit -m "test(D2-04.0): define LibreOffice runtime contract"
```

### Tâche 2 : Implémenter l’installateur LibreOffice 7.4.7.2 épinglé

**Fichiers :**
- Créer : `tools/ci/install_libreoffice_7_4_7_2.sh`
- Tester : `tests/test_d2_04_0_libreoffice_runtime_contract.py`

**Interfaces :**
- Consomme : accès réseau à l’archive officielle LibreOffice et `sudo dpkg` sur Ubuntu.
- Produit : un exécutable `soffice` installé dont la sortie `--version` correspond à `7.4.7.2` ; aucun état persistant autre que les paquets installés.

- [ ] **Étape 1 : Implémenter l’installateur fail-fast minimal**

Créer `tools/ci/install_libreoffice_7_4_7_2.sh` avec la structure suivante :

```bash
#!/usr/bin/env bash
set -euo pipefail

LO_VERSION="7.4.7.2"
LO_ARCHIVE="LibreOffice_${LO_VERSION}_Linux_x86-64_deb.tar.gz"
LO_BASE_URL="https://downloadarchive.documentfoundation.org/libreoffice/old/${LO_VERSION}/deb/x86_64"
LO_URL="${LO_BASE_URL}/${LO_ARCHIVE}"

workdir="$(mktemp -d)"
trap 'rm -rf "${workdir}"' EXIT

printf 'Downloading LibreOffice %s from official archive\n' "${LO_VERSION}"
curl --fail --location --silent --show-error \
  --output "${workdir}/${LO_ARCHIVE}" \
  "${LO_URL}"

tar -xzf "${workdir}/${LO_ARCHIVE}" -C "${workdir}"
mapfile -t packages < <(find "${workdir}" -type f -path '*/DEBS/*.deb' -print | sort)
if [[ ${#packages[@]} -eq 0 ]]; then
  echo "No LibreOffice Debian packages found in archive" >&2
  exit 1
fi

sudo dpkg -i "${packages[@]}" || sudo apt-get -f install -y

SOFFICE_BIN="$(command -v soffice || command -v libreoffice || true)"
if [[ -z "${SOFFICE_BIN}" ]]; then
  echo "LibreOffice executable not found after installation" >&2
  exit 1
fi

observed_version="$(${SOFFICE_BIN} --version)"
printf 'Observed LibreOffice version: %s\n' "${observed_version}"
if [[ "${observed_version}" != *"${LO_VERSION}"* ]]; then
  printf 'Expected LibreOffice %s, got: %s\n' "${LO_VERSION}" "${observed_version}" >&2
  exit 1
fi

printf 'SOFFICE_BIN=%s\n' "${SOFFICE_BIN}"
```

Ne jamais ajouter de fallback installant le paquet Ubuntu `libreoffice`. `apt-get -f install -y` est autorisé uniquement pour satisfaire les dépendances après `dpkg -i` des paquets officiels épinglés.

- [ ] **Étape 2 : Rendre l’installateur exécutable**

```bash
chmod +x tools/ci/install_libreoffice_7_4_7_2.sh
```

- [ ] **Étape 3 : Exécuter le test statique du contrat**

```bash
PYTHONPATH=. python tests/test_d2_04_0_libreoffice_runtime_contract.py
```

Attendu à ce stade : assertions liées à l’installateur PASS ; assertion liée au workflow encore FAIL car le workflow n’existe pas encore.

- [ ] **Étape 4 : Vérifier la syntaxe shell**

```bash
bash -n tools/ci/install_libreoffice_7_4_7_2.sh
```

Attendu : code de sortie 0, aucune sortie.

- [ ] **Étape 5 : Commiter l’implémentation de l’installateur**

```bash
git add tools/ci/install_libreoffice_7_4_7_2.sh tests/test_d2_04_0_libreoffice_runtime_contract.py
git commit -m "feat(D2-04.0): install pinned LibreOffice 7.4.7.2 runtime"
```

### Tâche 3 : Ajouter le smoke test runtime réel GitHub Actions

**Fichiers :**
- Créer : `.github/workflows/d2-04-0-libreoffice-7-4-7-2.yml`
- Tester : `tests/test_d2_04_0_libreoffice_runtime_contract.py`

**Interfaces :**
- Consomme : `tools/ci/install_libreoffice_7_4_7_2.sh`.
- Produit : contrôle GitHub Actions dédié prouvant installation, version exacte, exécution headless avec profil isolé et sortie propre.

- [ ] **Étape 1 : Créer le workflow dédié**

Créer `.github/workflows/d2-04-0-libreoffice-7-4-7-2.yml` avec la même définition que le plan anglais, notamment : `ubuntu-22.04`, exécution du test statique, installation via le script dédié, vérification de `7.4.7.2`, puis conversion `smoke.txt -> smoke.pdf` avec `-env:UserInstallation=file://...`.

Le choix `ubuntu-22.04` est volontaire afin d’éviter le caractère mouvant de `ubuntu-latest`. Ne pas modifier le workflow D2-03.24.

- [ ] **Étape 2 : Exécuter le test statique runtime en GREEN**

```bash
PYTHONPATH=. python tests/test_d2_04_0_libreoffice_runtime_contract.py
```

Attendu : PASS, tous les tests du contrat sont verts.

- [ ] **Étape 3 : Réexécuter localement la validation statique D2-03.24 existante**

Exécuter les mêmes validations non-LibreOffice que `.github/workflows/d2-03-24-validation.yml`, en terminant par :

```bash
python -m tools.architecture --root . --summary
python tests/test_d2_03_24_public_api_freeze.py
python tools/build_monolith.py
```

Attendu : tous les contrôles D2-03 existants PASS.

- [ ] **Étape 4 : Commiter le workflow**

```bash
git add .github/workflows/d2-04-0-libreoffice-7-4-7-2.yml tests/test_d2_04_0_libreoffice_runtime_contract.py
git commit -m "ci(D2-04.0): validate LibreOffice 7.4.7.2 headless runtime"
```

### Tâche 4 : Produire les preuves de livraison, ouvrir la PR et valider sur un vrai runner

**Fichiers :**
- Créer : `D2_04_0_REPORT.md`
- Modifier après succès CI : `D2_04_0_REPORT.md`

**Interfaces :**
- Consomme : tests statiques réussis et run GitHub Actions réel du workflow D2-04.0.
- Produit : statut D2-04.0 auditable et PR prête à fusionner.

- [ ] **Étape 1 : Créer le rapport pré-validation**

Créer `D2_04_0_REPORT.md` avec le statut :

```markdown
**IMPLEMENTED — verification pending**
```

Le rapport doit rappeler le socle 7.4.7.2, la provenance officielle, `ubuntu-22.04`, le mode headless, le profil isolé et le fait que l’exécution de macros CompareFramework est hors périmètre.

- [ ] **Étape 2 : Commiter le rapport**

```bash
git add D2_04_0_REPORT.md
git commit -m "docs(D2-04.0): add runtime baseline report"
```

- [ ] **Étape 3 : Ouvrir une PR vers `main`**

Titre :

```text
D2-04.0 — LibreOffice 7.4.7.2 CI Runtime Baseline
```

Le corps de PR doit préciser la version exacte, la provenance archive officielle, le smoke test avec profil isolé et le statut de validation en attente du run réel.

- [ ] **Étape 4 : Inspecter le run workflow réel**

Exiger que le workflow D2-04.0 atteigne `completed / success`. En cas d’échec, analyser les logs du job défaillant et corriger la cause racine ; ne jamais valider sur succès partiel.

- [ ] **Étape 5 : Mettre à jour le rapport uniquement après une preuve fraîche de succès**

Passer le statut à :

```markdown
**VALIDATED**
```

Ajouter le Run ID réussi, le SHA testé, la sortie observée de `soffice --version` et le résultat du smoke test.

- [ ] **Étape 6 : Commiter les preuves validées**

```bash
git add D2_04_0_REPORT.md
git commit -m "docs(D2-04.0): record validated LibreOffice runtime evidence"
```

Ce nouveau commit doit déclencher un nouveau run D2-04.0. La PR ne peut être fusionnée qu’après réussite du workflow runtime sur ce commit final.

- [ ] **Étape 7 : Fusionner uniquement avec des contrôles frais et verts**

Vérifier que le SHA HEAD de la PR correspond au run final réussi, puis fusionner dans `main`. Ne jamais réutiliser le succès d’un commit antérieur.

## Résultat de l’auto-revue

- Couverture de la spec : provenance/version épinglée, profil isolé, workflow CI dédié, gestion fail-fast, tests statiques, preuve runtime réelle, hors-périmètre et critères de clôture couverts.
- Aucun placeholder `TODO`/`TBD`.
- Les noms de fichiers, constantes et commandes restent cohérents avec la spec anglaise.
