# Guide utilisateur

# CompareFramework 3.8 RC1

Ce guide explique l'utilisation quotidienne de CompareFramework. Il complète le **QUICK_START** en détaillant les modes de comparaison, les rapports produits et les bonnes pratiques.

---

# 1. Les deux modes de comparaison

## Mode historique

Le mode historique compare automatiquement des feuilles selon une convention de nommage.

Exemples :

```text
Clients_OLD  -> Clients_NEW
Produits_REF -> Produits_NEW
```

Macros principales :

```basic
CF_RunValidated()
CF_RunAudited()
ComparerToutesLesFeuilles()
```

---

## Mode Référence

Le mode Référence compare une feuille de référence à plusieurs feuilles cibles.

Exemple :

```text
MODELE
CLIENT_A
CLIENT_B
CLIENT_C
```

Chaque feuille est comparée indépendamment à la référence.

---

# 2. Préparer les données

## Choisir la clé

Chaque ligne doit être identifiée par une colonne unique.

Exemple :

```text
ref_scat_abs
```

⚠️ La clé doit être unique dans chaque feuille.

En présence de doublons :

- la comparaison devient ambiguë ;
- la décision passe à **A CONTROLER**.

💡 Nettoyez toujours les doublons avant d'interpréter les résultats.

## Structure des feuilles

Les feuilles comparées doivent utiliser la même structure de colonnes.

Les colonnes techniques inutiles sont à éviter.

---

# 3. Lancer une comparaison

1. Générer le monolithe (`python3 tools/build_monolith.py`) ou utiliser celui fourni.
2. Importer le monolithe dans le classeur.
3. Exécuter :

```basic
CF_OpenReferenceLauncher()
```

4. Renseigner :

```text
REFERENCE_SHEET = MODELE
KEY_COLUMN = ref_scat_abs
TARGET_MODE = ALL
```

5. Lancer :

```basic
CF_RunFromLauncher()
```

---

# 4. Comprendre les rapports

## Compare_Reference_Plan

Indique quelles feuilles ont été planifiées, comparées ou ignorées.

## Compare_Reference_Summary

Présente une ligne par feuille cible avec :

- ajouts ;
- suppressions ;
- lignes modifiées ;
- cellules modifiées ;
- doublons ;
- incidents ;
- décision.

## Rapport_Comparaison

Contient le détail de chaque écart détecté.

## Compare_Audit

Conserve l'historique des exécutions avec les métriques.

## Compare_Performance

Mesure les performances du moteur.

---

# 5. Comprendre les décisions

| Décision | Signification |
|---|---|
| OK | Aucun écart, aucun doublon, aucun incident |
| ECARTS | Ajout, suppression ou modification détecté |
| A CONTROLER | Doublon ou incident structurel détecté |

---

# 6. Cas d'utilisation

## Vérifier une livraison

Comparer une version reçue avec la feuille MODELE.

## Contrôler plusieurs exports

Comparer plusieurs feuilles d'un même classeur à une référence commune.

## Régression

Comparer une nouvelle version avec une version validée.

---

# 7. Bonnes pratiques

✅ Utiliser une clé unique.

✅ Tester d'abord sur une copie du classeur.

✅ Régénérer le monolithe après toute modification de `src/`.

✅ Vérifier `Compare_Reference_Summary` avant d'analyser le détail.

---

# 8. Dépannage

## Décision A CONTROLER

Vérifier :

- les doublons de la clé ;
- les alertes structurelles ;
- la présence de la colonne identifiant.

## Feuille IGNORÉE

Contrôler les paramètres de `Compare_Launcher` et la structure de la feuille.

## Build en erreur

Relancer :

```bash
python3 tools/build_monolith.py
```

et vérifier que `BUILD_MANIFEST.json` contient :

```json
"all_checks_passed": true
```

---

# 9. Glossaire

**Clé** : colonne identifiant utilisée pour faire correspondre les lignes.

**Référence** : feuille servant de base de comparaison.

**Cible** : feuille comparée à la référence.

**Incident** : problème technique ou structurel détecté pendant la comparaison.

**Monolithe** : fichier `.bas` généré à partir des modules présents dans `src/`.
