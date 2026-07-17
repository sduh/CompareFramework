# Publication de CompareFramework 3.8.0

## Statut

**Prêt pour publication et création du tag `v3.8.0`.**

## Séquence finale dans le dépôt Git réel

```bash
python3 tools/build_release.py
git status --short
git add VERSION CHANGELOG.md RELEASE_NOTES.md RELEASE_MANIFEST.json docs/RELEASE_CERTIFICATE.md dist/
git commit -m "release: publish CompareFramework 3.8.0"
git tag -a v3.8.0 -m "CompareFramework 3.8.0"
git push origin HEAD
git push origin v3.8.0
```

Avant le commit, vérifier que `git status --short` ne contient que les changements attendus et que le tag `v3.8.0` n’existe pas déjà.
