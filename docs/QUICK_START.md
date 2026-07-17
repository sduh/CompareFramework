# Démarrage rapide

Ce guide permet de réaliser une première comparaison avec CompareFramework en moins de cinq minutes.

## 1. Préparer le classeur

Travaillez d’abord sur une copie de votre classeur.

Le scénario recommandé utilise :

- une feuille de référence ;
- une ou plusieurs feuilles cibles ;
- une colonne identifiant unique présente dans chaque feuille.

Exemple :

```text
MODELE
CLIENT_A
CLIENT_B
CLIENT_C
```

La colonne identifiant peut être, par exemple :

```text
ref_scat_abs
```

> La valeur de cette colonne doit être unique dans chaque feuille. Les doublons entraînent une décision `A CONTROLER` et rendent la comparaison ambiguë.

## 2. Générer le monolithe

Depuis la racine du dépôt :

```bash
python3 tools/build_monolith.py
```

Le script doit générer :

```text
dist/CompareFramework-3.8.0-RC1.bas
dist/BUILD_MANIFEST.json
```

Dans `BUILD_MANIFEST.json`, vérifiez :

```json
"all_checks_passed": true
```

## 3. Importer la macro dans LibreOffice Calc

1. Ouvrez le classeur `.ods`.
2. Allez dans **Outils → Macros → Gérer les macros → Basic**.
3. Sélectionnez le classeur.
4. Créez un module.
5. Importez le fichier monolithique présent dans `dist/`.
6. Compilez le module.

## 4. Créer l’assistant

Exécutez :

```basic
CF_OpenReferenceLauncher()
```

La feuille `Compare_Launcher` est créée.

## 5. Configurer la comparaison

Pour comparer toutes les feuilles métier :

```text
REFERENCE_SHEET = MODELE
KEY_COLUMN = ref_scat_abs
TARGET_MODE = ALL
```

Pour ne comparer que certaines feuilles :

```text
TARGET_MODE = SELECTED
SELECTED_TARGETS = CLIENT_A;CLIENT_C
```

## 6. Lancer la comparaison

Exécutez :

```basic
CF_RunFromLauncher()
```

## 7. Lire les résultats

### `Compare_Reference_Plan`

- `COMPAREE` : feuille traitée ;
- `IGNOREE` : feuille non éligible ;
- `PLANIFIEE` : feuille prévue dans le plan.

### `Compare_Reference_Summary`

| Décision | Signification |
|---|---|
| `OK` | Aucun écart, doublon ou incident |
| `ECARTS` | Ajout, suppression ou modification détecté |
| `A CONTROLER` | Doublon ou alerte structurelle |

### `Rapport_Comparaison`

Le rapport détaille les ajouts, suppressions, modifications, doublons et alertes structurelles.

## 8. Cas de contrôle recommandés

| Test | Résultat attendu |
|---|---|
| Feuilles identiques | Rapport vide, décision `OK` |
| Un ajout | Un ajout, décision `ECARTS` |
| Une suppression | Une suppression, décision `ECARTS` |
| Une modification | Une cellule modifiée, décision `ECARTS` |
| Un doublon sur la clé | Décision `A CONTROLER` |

## 9. Exporter en HTML

Exécutez :

```basic
ExporterRapportHTML()
```

Le fichier `Rapport_Comparaison.html` est créé à côté du classeur.

## 10. En cas de problème

Vérifiez :

1. que la feuille de référence existe ;
2. que la colonne identifiant existe dans toutes les feuilles cibles ;
3. que cette colonne ne contient aucun doublon ;
4. que `Compare_Reference_Plan` ne contient pas de feuille utile marquée `IGNOREE` ;
5. que le monolithe a été régénéré après toute modification de `src/`.
