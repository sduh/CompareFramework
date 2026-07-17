# Étape 2 — Harmonisation des versions

## Résultat

**Statut : TERMINÉE**

La version active du projet est désormais lue exclusivement depuis le fichier racine `VERSION` :

```text
3.8.0-RC1
```

## Modifications appliquées

- remplacement de la constante source par le jeton de build `@COMPAREFRAMEWORK_VERSION@` ;
- injection de la version dans le monolithe par `tools/build_monolith.py` ;
- remplacement des titres de fenêtres codés en dur par `CF_VERSION` ;
- suppression des versions obsolètes dans les en-têtes des modules actifs ;
- lecture obligatoire de `VERSION` par le générateur de certificat PDF ;
- nommage canonique du monolithe : `dist/CompareFramework-3.8.0-RC1.bas` ;
- version et source de version enregistrées dans `dist/BUILD_MANIFEST.json` ;
- mise à jour des références opérationnelles dans `README.md` et `docs/QUICK_START.md`.

Les références anciennes conservées dans `docs/audit/` et `docs/PROJECT_HISTORY.md` sont historiques et n'ont pas été réécrites.

## Contrôles exécutés

- syntaxe Python des outils : OK ;
- build statique des 20 modules : OK ;
- absence de doublons publics : OK ;
- absence de syntaxe `Optional ... =` interdite : OK ;
- absence d'appels directs interdits à `Round` : OK ;
- absence de jeton de version dans le monolithe généré : OK ;
- absence de versions actives `3.5.1`, `3.7.2-D3` et `3.7.3-D4` : OK ;
- cohérence `VERSION` / monolithe / manifeste : OK.

## Artefacts de contrôle

- `dist/CompareFramework-3.8.0-RC1.bas`
- `dist/BUILD_MANIFEST.json`

La génération complète des artefacts de publication relève de l'étape 3.
