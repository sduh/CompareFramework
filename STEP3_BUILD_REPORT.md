# Étape 3 - Build complet et artefacts de release

## Résultat

Le build complet de CompareFramework `3.8.0-RC1` a été exécuté avec succès le 2026-07-17.

## Artefacts générés

- `dist/CompareFramework-3.8.0-RC1.bas`
- `dist/BUILD_MANIFEST.json`
- `dist/RELEASE_CERTIFICATE_3.8.0-RC1.pdf`
- `dist/RELEASE_MANIFEST.json`
- `dist/SHA256SUMS.txt`
- `dist/CompareFramework-3.8.0-RC1.zip`
- copies de `README.md`, `CHANGELOG.md`, `RELEASE_NOTES.md` et `VERSION` dans `dist/`

## Contrôles réussis

- 20 modules assemblés selon `MODULE_ORDER.txt` ;
- une seule directive `Option Explicit` dans le monolithe ;
- aucun doublon de procédure publique ;
- aucune syntaxe `Optional ... =` interdite ;
- aucun appel interdit à `Round` ;
- version `3.8.0-RC1` cohérente entre `VERSION`, le monolithe et les manifestes ;
- aucune ancienne version active détectée dans les sources, outils ou documents opérationnels ;
- sommes SHA-256 générées ;
- archive ZIP vérifiée ;
- certificat PDF rendu et contrôlé visuellement sur trois pages.

## Automatisation

La commande suivante reconstruit tous les artefacts de distribution :

```bash
python3 tools/build_release.py
```

Le script nettoie les artefacts générés précédemment, reconstruit le monolithe, génère le certificat PDF, produit les manifestes et checksums, puis crée l’archive ZIP.

## Statut de publication

Le build est techniquement prêt pour la validation opérationnelle. Le statut reste :

`pending-libreoffice-validation`

Le certificat reste **EN ATTENTE / NO GO POUR PUBLICATION** jusqu’à l’achèvement de l’étape 4 sous LibreOffice.
