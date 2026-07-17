# Architecture de CompareFramework

# Version 3.8 RC1

Ce document présente l'architecture fonctionnelle de CompareFramework et les interactions entre ses principaux modules.

---

# Vue d'ensemble

```text
                 Utilisateur
                      │
                      ▼
          CF_OpenReferenceLauncher
                      │
                      ▼
             Compare_Launcher
                      │
                      ▼
             CF_RunFromLauncher
                      │
                      ▼
          +----------------------+
          |      Main            |
          +----------------------+
             │
   +---------+----------+
   │                    │
Validation         Configuration
   │                    │
   +---------+----------+
             │
             ▼
      Moteur de comparaison
             │
   +---------+----------+
   │                    │
 Index mémoire     Comparateurs
   │                    │
   +---------+----------+
             │
             ▼
     Génération des rapports
             │
   +---------+----------+
   │         │          │
 Audit   Performance   HTML
```

---

# Architecture des modules

| Module | Rôle |
|---|---|
| Main | Point d'entrée des comparaisons |
| Context | Contexte d'exécution |
| Config | Paramètres globaux |
| Profiles | Profils de comparaison |
| Rules | Règles métier |
| Index | Construction des index mémoire |
| EngineMemory | Comparaison des données |
| Comparators | Comparateurs typés |
| ComparatorConfig | Configuration des comparateurs |
| Report | Génération des feuilles de résultats |
| Audit | Journalisation des exécutions |
| Performance | Mesures de performance |
| Validation | Vérifications préalables |
| Quality | Tableau de bord qualité |
| Scenarios | Scénarios de validation |
| Tests | Tests intégrés |
| Utils | Fonctions utilitaires |
| Modes/CF_ModeReference | Mode Référence (MODELE → N feuilles) |

---

# Cycle d'une comparaison

```text
Préparation
    │
Validation
    │
Construction des index
    │
Comparaison
    │
Production des statistiques
    │
Rapports Calc
    │
Audit
    │
Export HTML (optionnel)
```

---

# Sources de vérité

- `src/` contient les modules maintenus.
- `dist/` contient uniquement les artefacts générés.
- `MODULE_ORDER.txt` définit l'ordre d'assemblage.
- `tools/build_monolith.py` génère le monolithe.

Le monolithe ne doit jamais être modifié directement.

---

# Modes de comparaison

## Mode historique

Basé sur les suffixes (`_OLD/_NEW`, `_REF/_NEW`).

## Mode Référence

Une feuille de référence est comparée à plusieurs feuilles cibles via `Compare_Launcher`.

---

# Feuilles produites

| Feuille | Fonction |
|---|---|
| Compare_Reference_Plan | Plan d'exécution |
| Compare_Reference_Summary | Synthèse consolidée |
| Rapport_Comparaison | Détail des écarts |
| Stats_Comparaison | Statistiques |
| Compare_Audit | Historique |
| Compare_Performance | Performances |
| CF_Quality_Dashboard | Qualité |
| CF_Release_Readiness | État de la release |

---

# Principes d'architecture

1. Source de vérité : `src/`
2. Monolithe généré automatiquement.
3. Comparaison en mémoire pour les performances.
4. Séparation entre moteur, configuration, rapports et validation.
5. Toute évolution doit être accompagnée de tests et de documentation.

---

# Évolutions prévues (V4)

- Validation stricte des clés avant indexation.
- Comparaison entre classeurs.
- Comparaison de dossiers complets.
- Historique des comparaisons.
- Statistiques d'évolution.
