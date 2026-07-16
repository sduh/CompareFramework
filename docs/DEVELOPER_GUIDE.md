# Guide développeur

# CompareFramework 3.8 RC1

Ce document est destiné aux développeurs souhaitant comprendre, maintenir ou faire évoluer CompareFramework.

---

# 1. Philosophie

CompareFramework est un moteur de comparaison de données pour LibreOffice Calc.

Principes :

- `src/` est la source de vérité.
- `dist/` est généré automatiquement.
- Toute évolution doit être testée, documentée et validée sur LibreOffice Calc.

---

# 2. Architecture du dépôt

```text
CompareFramework/
├── src/
│   ├── Modes/
│   └── *.bas
├── dist/
├── docs/
├── tests/
├── tools/
├── MODULE_ORDER.txt
└── README.md
```

---

# 3. Cycle de développement

1. Modifier les modules dans `src/`
2. Compiler dans LibreOffice
3. Générer le monolithe :

```bash
python3 tools/build_monolith.py
```

4. Vérifier `dist/BUILD_MANIFEST.json`
5. Exécuter la validation
6. Mettre à jour la documentation
7. Committer

---

# 4. Modules principaux

| Module | Responsabilité |
|---|---|
| Main | Point d'entrée |
| Context | Contexte d'exécution |
| Config | Configuration |
| Profiles | Profils |
| Rules | Règles |
| Index | Index mémoire |
| EngineMemory | Comparaison |
| Comparators | Comparateurs typés |
| ComparatorConfig | Configuration des comparateurs |
| Report | Rapports Calc |
| Audit | Journalisation |
| Performance | Mesures |
| Validation | Contrôles |
| Quality | Tableau de bord |
| Scenarios | Validation métier |
| Tests | Régression |
| Utils | Fonctions communes |
| Modes/CF_ModeReference | Mode Référence |

---

# 5. Ajouter un comparateur

Étapes recommandées :

1. Implémenter le comparateur.
2. L'enregistrer dans `ComparatorConfig`.
3. Ajouter les tests unitaires.
4. Documenter son fonctionnement.
5. Vérifier la non-régression.

---

# 6. Ajouter un nouveau mode

Créer un module dans `src/Modes/`.

Le mode doit :

- valider les paramètres ;
- utiliser le moteur mémoire existant ;
- produire les mêmes feuilles de résultats ;
- alimenter l'audit et les statistiques.

---

# 7. Build reproductible

Le script `tools/build_monolith.py` :

- assemble les modules selon `MODULE_ORDER.txt` ;
- vérifie les doublons de symboles publics ;
- contrôle les incompatibilités LibreOffice ;
- génère le monolithe et le manifeste.

Ne jamais modifier le monolithe manuellement.

---

# 8. Tests

Avant toute livraison :

- build réussi ;
- validation LibreOffice ;
- tests intégrés ;
- test sur un jeu de données réel si la fonctionnalité impacte le moteur.

---

# 9. Documentation

Toute évolution doit mettre à jour :

- CHANGELOG
- README (si visible utilisateur)
- documentation concernée
- exemples si nécessaire

---

# 10. Bonnes pratiques

- Préserver la compatibilité LibreOffice Basic.
- Préférer des modules spécialisés.
- Éviter les dépendances circulaires.
- Documenter les choix d'architecture.
- Ajouter des tests avant toute optimisation.

---

# 11. Checklist avant Pull Request

- [ ] Compilation réussie
- [ ] Build reproductible OK
- [ ] Tests OK
- [ ] Documentation mise à jour
- [ ] CHANGELOG mis à jour
- [ ] Validation sur Calc effectuée

---

# 12. Roadmap développeur

Les évolutions majeures prévues pour CompareFramework 4 sont :

- validation stricte des clés ;
- comparaison entre classeurs ;
- comparaison de dossiers ;
- architecture extensible par plugins.
