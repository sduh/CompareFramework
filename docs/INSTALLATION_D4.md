# Installation et distribution — D4

## Développement modulaire

Les fichiers de `src/` constituent la source de vérité.

Importer les modules dans LibreOffice dans l'ordre indiqué par
`MODULE_ORDER.txt`.

## Générer le monolithe

Depuis la racine du dépôt :

```bash
python3 tools/build_monolith.py
```

Le script crée :

- `dist/CompareFramework_3_7_3_D4_Monolith.bas`
- `dist/BUILD_MANIFEST.json`

## Contrôles automatiques

Le build échoue si :

- un module référencé est absent ;
- plusieurs procédures publiques portent le même nom ;
- le monolithe contient plusieurs `Option Explicit` ;
- la syntaxe VBA `Optional ... = ...` réapparaît ;
- un appel à `Round()` réapparaît.

## Installation utilisateur

Pour une installation simple, importer uniquement le fichier monolithique
généré dans `dist/`.

Pour contribuer au projet, modifier uniquement les fichiers de `src/`, puis
régénérer `dist/`.
