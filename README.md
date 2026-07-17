# CompareFramework

**Moteur de comparaison avancé pour LibreOffice Calc**

CompareFramework compare des données structurées directement dans un classeur LibreOffice Calc. Il peut comparer deux versions d’une feuille ou utiliser une feuille de référence pour contrôler plusieurs feuilles cibles, puis produire des rapports détaillés, une synthèse consolidée, un audit et un export HTML.

> Version en préparation : **3.8.0-RC1**  
> Baseline stable : **3.6.3**  
> Compatibilité validée : **LibreOffice Calc 7.4.7.2**

## Fonctionnalités

- Comparaison de feuilles par paires : `_OLD/_NEW`, `_REF/_NEW` ou `_AVANT/_APRES`
- Comparaison d’une feuille de référence avec plusieurs feuilles cibles
- Sélection de toutes les cibles ou d’une liste explicite
- Lecture et indexation des données en mémoire
- Détection des ajouts, suppressions et modifications
- Comparateurs typés : texte, nombres, dates, booléens, pourcentages et devises
- Profils et tolérances configurables
- Détection des identifiants en doublon
- Rapports Calc détaillés et consolidés
- Audit d’exécution et métriques de performance
- Export HTML autonome avec filtres et mise en couleur
- Tests intégrés et validation de release
- Build reproductible du monolithe depuis les modules source

## Pré-requis

- LibreOffice Calc
- Macros autorisées
- Un classeur enregistré au format `.ods`
- Une colonne identifiant présente dans chaque feuille comparée

### Unicité de la clé

La colonne identifiant doit contenir une valeur unique par ligne dans chaque feuille.

En présence de doublons :

- CompareFramework signale un état `A CONTROLER` ;
- la comparaison devient ambiguë ;
- l’index peut retenir une occurrence parmi les doublons.

Nettoyez les doublons avant d’interpréter les résultats. Une future version proposera un mode strict qui interrompra la comparaison avant l’indexation.

## Installation rapide

### Utilisation du monolithe

1. Générez ou récupérez le fichier présent dans `dist/`.
2. Ouvrez votre classeur Calc.
3. Allez dans **Outils → Macros → Gérer les macros → Basic**.
4. Créez un module dans le classeur.
5. Importez le fichier `.bas`.
6. Compilez le module.

Le monolithe est destiné à l’installation et à la distribution. Il ne doit pas être modifié manuellement.

### Développement modulaire

Les fichiers de `src/` sont la source de vérité.

L’ordre d’assemblage est défini dans :

```text
MODULE_ORDER.txt
```

Pour générer le monolithe :

```bash
python3 tools/build_monolith.py
```

Les fichiers générés sont placés dans `dist/`.

## Démarrage rapide : mode Référence

Ce mode compare une feuille de référence à plusieurs feuilles cibles.

Exemple :

```text
MODELE
CLIENT_A
CLIENT_B
CLIENT_C
```

Chaque feuille contient une colonne identifiant unique, par exemple `ref_scat_abs`.

### 1. Créer l’assistant

Exécutez :

```basic
CF_OpenReferenceLauncher()
```

Une feuille `Compare_Launcher` est créée.

### 2. Renseigner les paramètres

Pour comparer toutes les feuilles métier :

```text
REFERENCE_SHEET = MODELE
KEY_COLUMN = ref_scat_abs
TARGET_MODE = ALL
```

Pour comparer uniquement certaines feuilles :

```text
TARGET_MODE = SELECTED
SELECTED_TARGETS = CLIENT_A;CLIENT_C
```

### 3. Lancer la comparaison

Exécutez :

```basic
CF_RunFromLauncher()
```

### 4. Lire les résultats

| Feuille | Rôle |
|---|---|
| `Compare_Reference_Plan` | Liste des cibles planifiées, comparées ou ignorées |
| `Compare_Reference_Summary` | Synthèse par cible et totaux consolidés |
| `Rapport_Comparaison` | Détail des ajouts, suppressions et modifications |
| `Stats_Comparaison` | Statistiques techniques par comparaison |
| `Synthese_Comparaison` | Tableau de bord global |
| `Plan_Action_Comparaison` | Écarts à traiter |
| `Journal_Comparaison` | Journal d’exécution |
| `Compare_Audit` | Historique des exécutions |
| `Compare_Performance` | Durées et métriques |

## Interprétation de la synthèse

| Décision | Signification |
|---|---|
| `OK` | Aucun écart et aucun incident |
| `ECARTS` | Ajout, suppression ou modification détecté |
| `A CONTROLER` | Doublon ou incident structurel détecté |

## Mode historique par paires

CompareFramework conserve le mode par conventions de noms.

Exemples :

```text
Clients_OLD
Clients_NEW
```

```text
Produits_REF
Produits_NEW
```

Points d’entrée principaux :

```basic
CF_RunValidated()
CF_RunAudited()
ComparerToutesLesFeuilles()
```

Le moteur historique reste disponible pour contrôle :

```basic
ComparerToutesLesFeuilles_Legacy()
```

## Export HTML

Après une comparaison, exécutez :

```basic
ExporterRapportHTML()
```

Le fichier `Rapport_Comparaison.html` est créé à côté du classeur.

## Validation

Pour exécuter la validation complète de la baseline stable :

```basic
CF_RunStableValidation()
```

Résultats attendus :

- `CF_Quality_Dashboard` : `OK`
- `CF_Scenario_Results` : tous les scénarios en `OK`
- `CF_Release_Readiness` : `RELEASE CANDIDATE`
- dernière ligne de `Compare_Audit` : `DONE`

## Architecture du dépôt

```text
CompareFramework/
├── src/                 Modules LibreOffice Basic
│   └── Modes/           Modes de comparaison
├── dist/                Monolithes et manifestes générés
├── docs/                Documentation
├── tools/               Scripts de build
├── MODULE_ORDER.txt     Ordre d’assemblage
├── CHANGELOG.md
└── README.md
```

Principes :

1. `src/` est la source de vérité.
2. `dist/` est généré.
3. Le monolithe ne doit pas être modifié manuellement.
4. Toute fonctionnalité doit être accompagnée de tests et de documentation.
5. Toute Release Candidate doit être vérifiée sur un jeu de données réel.

## Build reproductible

```bash
python3 tools/build_monolith.py
```

Le build contrôle notamment :

- les modules manquants ;
- les procédures publiques dupliquées ;
- la présence d’un seul `Option Explicit` ;
- les syntaxes optionnelles incompatibles avec LibreOffice Basic ;
- les appels interdits à `Round()` ;
- la cohérence du monolithe généré.

Le manifeste de build est écrit dans `dist/BUILD_MANIFEST.json`.

## Documentation

- [Installation D4](docs/INSTALLATION_D4.md)
- [Procédure de release D4](docs/RELEASE_D4.md)
- [Tests du mode Référence](docs/TEST_D1.md)
- [Tests de la synthèse consolidée](docs/TEST_D2.md)
- [Tests de l’assistant](docs/TEST_D3.md)

## Statut du projet

La baseline `v3.6.3-stable` a été validée sous LibreOffice Calc. Le Jalon D a ensuite ajouté le mode Référence, la synthèse consolidée, l’assistant de lancement et le build reproductible. La version 3.8.0-RC1 consolide ces travaux en vue d’une première distribution documentée.

## Roadmap

### V3.8

- kit de distribution ;
- documentation complète ;
- démonstrateur générique ;
- validation de release unifiée ;
- préparation de la Release Candidate.

### CompareFramework 4

- validation stricte des clés ;
- arrêt immédiat sur doublon ;
- pré-validation complète ;
- comparaison entre classeurs ;
- comparaison d’un dossier ;
- statistiques historiques.

## Contribution

Les contributions devront respecter les principes suivants :

- modifier les modules de `src/`, jamais directement le monolithe ;
- régénérer `dist/` après modification ;
- lancer les contrôles du build ;
- documenter les changements ;
- ajouter ou mettre à jour les tests concernés.

## Licence

La licence du projet doit être définie avant la publication de la V3.8.0 Stable.
