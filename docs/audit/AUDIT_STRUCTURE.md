# AUDIT_STRUCTURE — CompareFramework 3.8.0 RC1

## Objet

Audit de la structure réelle du dépôt avant publication de la Release Candidate.

## Synthèse

Le dépôt est globalement bien structuré autour de quatre patrimoines :

- `src/` : code source modulaire ;
- `docs/` : documentation ;
- `tests/` : jeux de données de référence ;
- `dist/` : artefacts générés.

Aucun défaut structurel bloquant n’a été identifié. Plusieurs nettoyages sont toutefois recommandés avant la publication de la RC1.

## Tableau de conformité

| Élément | État | Priorité | Action |
|---|---:|---:|---|
| `src/` modulaire | Conforme | — | Conserver |
| `src/Modes/CF_ModeReference.bas` | Conforme | — | Conserver |
| `tests/datasets/` | Conforme | — | Conserver |
| `tools/build_monolith.py` | Conforme | — | Conserver |
| `MODULE_ORDER.txt` | Conforme | — | Vérifier à chaque build |
| Multiples monolithes dans `dist/` | À nettoyer | Important | Ne conserver que le monolithe RC courant et la baseline stable |
| Fichier `D3_PREVIEW` | Obsolète | Important | Supprimer avant RC1 |
| `APPLY_PATCH.sh` à la racine | Temporaire | Important | Supprimer après application |
| Fichiers `HOTFIX_*` à la racine | Historique de travail | Important | Supprimer de la branche principale ou déplacer dans les releases/tags |
| `PATCH.md` | Temporaire | Important | Supprimer |
| Documentation D4 dispersée | À harmoniser | Amélioration | Déplacer sous `docs/developer/` ou `docs/release/` |
| `RELEASE_D4.md` et `docs/release/*` | Doublon potentiel | Important | Fusionner ou supprimer l’ancien document |
| `RELEASE_POLICY.md` hors `docs/release/` | Incohérent | Amélioration | Déplacer vers `docs/release/` |
| `TEST_D1.md`, `TEST_D2.md`, `TEST_D3.md` | Documentation historique | Amélioration | Fusionner dans un guide de qualification du mode Référence |
| Absence visible de `examples/` | Incomplet | Important | Ajouter le démonstrateur avant RC1 |
| Absence visible de `LICENSE` | Bloquant publication publique | Bloquant | Choisir et ajouter une licence |
| Absence visible de `CONTRIBUTING.md` | Non bloquant RC | Amélioration | Ajouter avant ouverture large aux contributions |
| Absence visible de `.gitignore` | Risque de pollution | Important | Ajouter un `.gitignore` adapté |
| `RELEASE_MANIFEST.json` à la racine | Ambigu | Amélioration | Déplacer dans `dist/` ou supprimer si obsolète |
| `RELEASE_NOTES.md` à la racine | Acceptable | — | Mettre à jour pour RC1 |
| `VALIDATION.md` à la racine | Acceptable | Amélioration | Déplacer éventuellement sous `docs/release/` |
| `QUALITY.md` à la racine | Conforme | — | Conserver |

## Actions obligatoires avant RC1

### 1. Nettoyer `dist/`

Conserver uniquement :

```text
dist/
├── BUILD_MANIFEST.json
├── CompareFramework_3_8_0_RC1_Monolith.bas
└── CompareFramework_Stable_3_6_3.bas
```

Supprimer ou archiver hors de la branche principale :

```text
CompareFramework_3_7_0_D1_Monolith.bas
CompareFramework_3_7_1_D2_Monolith.bas
CompareFramework_3_7_2_D3_Monolith.bas
CompareFramework_3_7_2_D3_PREVIEW.bas
CompareFramework_3_7_3_D4_Monolith.bas
```

L’historique Git et les tags suffisent pour conserver ces versions.

### 2. Supprimer les fichiers temporaires

À retirer de la racine :

```text
APPLY_PATCH.sh
PATCH.md
HOTFIX_*.md
```

Ces fichiers documentent des étapes intermédiaires déjà intégrées dans les sources. Ils encombrent la découverte du projet.

### 3. Ajouter une licence

La publication publique de la RC1 nécessite un fichier :

```text
LICENSE
```

La licence doit être choisie explicitement avant la release.

### 4. Ajouter le démonstrateur

Le dossier suivant manque dans la photographie du dépôt :

```text
examples/
└── Demo/
    ├── Demo.ods
    ├── README.md
    ├── EXPECTED_RESULTS.md
    └── screenshots/
```

La RC1 peut techniquement être construite sans démonstrateur, mais elle ne satisferait pas la Definition of Done du Sprint Foundation.

### 5. Ajouter `.gitignore`

Exemple minimal :

```gitignore
*.lock
*.tmp
*.bak
*.swp
~$*
__pycache__/
*.pyc
.DS_Store
Thumbs.db
```

Ne pas ignorer les fichiers `.ods` du démonstrateur ni les CSV de test.

## Harmonisation documentaire recommandée

Organisation cible :

```text
docs/
├── user/
│   ├── QUICK_START.md
│   └── USER_GUIDE.md
├── developer/
│   ├── ARCHITECTURE.md
│   ├── DEVELOPER_GUIDE.md
│   ├── BEST_PRACTICES.md
│   ├── DECISIONS.md
│   ├── INSTALLATION.md
│   └── adr/
├── release/
│   ├── RELEASE_POLICY.md
│   ├── RELEASE_PROCESS.md
│   ├── RELEASE_CHECKLIST.md
│   ├── VERSIONING.md
│   ├── SUPPORT.md
│   ├── KNOWN_LIMITATIONS.md
│   └── VALIDATION.md
├── PROJECT_HISTORY.md
└── PROJECT_PHILOSOPHY.md
```

Cette réorganisation n’est pas techniquement bloquante, mais elle améliore nettement la navigation.

## Structure cible proposée

```text
CompareFramework/
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── MODULE_ORDER.txt
├── QUALITY.md
├── README.md
├── RELEASE_NOTES.md
├── src/
│   ├── Modes/
│   └── *.bas
├── dist/
│   ├── BUILD_MANIFEST.json
│   ├── CompareFramework_3_8_0_RC1_Monolith.bas
│   └── CompareFramework_Stable_3_6_3.bas
├── docs/
│   ├── user/
│   ├── developer/
│   └── release/
├── examples/
│   └── Demo/
├── tests/
│   ├── catalog.md
│   └── datasets/
└── tools/
    └── build_monolith.py
```

## Commandes de nettoyage suggérées

À vérifier avant exécution :

```bash
git rm APPLY_PATCH.sh PATCH.md
git rm HOTFIX_*.md
git rm dist/CompareFramework_3_7_0_D1_Monolith.bas
git rm dist/CompareFramework_3_7_1_D2_Monolith.bas
git rm dist/CompareFramework_3_7_2_D3_Monolith.bas
git rm dist/CompareFramework_3_7_2_D3_PREVIEW.bas
git rm dist/CompareFramework_3_7_3_D4_Monolith.bas
```

Puis régénérer l’artefact RC1 avec le script de build.

## Décision RC-01

**État : favorable sous conditions.**

Le dépôt est suffisamment structuré pour préparer la RC1, sous réserve de réaliser avant publication :

1. le nettoyage des artefacts et hotfix obsolètes ;
2. l’ajout d’une licence ;
3. l’ajout du démonstrateur ;
4. la génération du monolithe RC1 ;
5. la vérification des liens après éventuel déplacement de la documentation.
