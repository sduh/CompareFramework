# CompareFramework - Certificat de publication

| Champ | Valeur |
|---|---|
| Projet | CompareFramework |
| Version | 3.8.0 |
| Type de publication | Version stable |
| Date de qualification | 17 juillet 2026 |
| Décision de qualification | GO |

## Objet

Le présent certificat enregistre la qualification et l’autorisation de publication de CompareFramework version **3.8.0**.

La version finale reprend sans modification fonctionnelle le code qualifié de `3.8.0-RC1`. Le changement porte sur l’identifiant de version et sur la régénération des artefacts de publication.

## Références

### Gouvernance

- `VERSION`
- `docs/RELEASE_POLICY.md`
- `CHANGELOG.md`
- `RELEASE_NOTES.md`
- `RELEASE_MANIFEST.json`

### Architecture

- `docs/adr/`

### Preuves de qualification

- `docs/audit/AUDIT_STRUCTURE.md`
- `docs/audit/AUDIT_CODE.md`
- `docs/audit/AUDIT_DEPENDENCIES.md`
- `docs/audit/RC04_PUBLIC_API_REVIEW.md`
- `docs/audit/RC05_RELEASE_READINESS.md`
- validation LibreOffice de `3.8.0-RC1` ;
- contrôle du build final `3.8.0` et de l’injection de version.

## Résultats de qualification

| Contrôle | Résultat |
|---|---|
| Build statique des 20 modules | PASS |
| Compilation LibreOffice de la RC1 | PASS |
| Suite interne sur la RC1 | 7/7 PASS |
| Build final et injection de version | 3.8.0 - PASS |
| Export HTML de la RC1 | PASS |
| Écriture UTF-8 dans le code final | PASS |
| Cohérence des manifestes et checksums | PASS |

## Conformité architecturale

- les modules sources sont maintenus sous `src/` ;
- le monolithe est généré depuis `src/`, `MODULE_ORDER.txt` et `VERSION` ;
- les artefacts générés sont stockés sous `dist/` ;
- `VERSION` est l’unique source éditable de version ;
- la façade publique officielle est définie par `src/CompareFramework_API.bas`.

## Artefacts de publication

- `dist/CompareFramework-3.8.0.bas` ;
- `dist/RELEASE_CERTIFICATE_3.8.0.pdf` ;
- `dist/CompareFramework-3.8.0.zip` ;
- `dist/RELEASE_MANIFEST.json` ;
- `dist/SHA256SUMS.txt`.

## Décision

**Décision finale : GO POUR PUBLICATION**

CompareFramework version **3.8.0** est qualifiée pour publication. Le tag attendu est `v3.8.0` et doit être créé sur le commit contenant exactement les artefacts et sources certifiés.

## Approbation

| Champ | Valeur |
|---|---|
| Projet qualifié | CompareFramework |
| Version qualifiée | 3.8.0 |
| Tag Git attendu | `v3.8.0` |
| Version candidate qualifiée | `v3.8.0-rc1` |
| Approuvé par | s.duhamel |
| Date d’approbation | 17 juillet 2026 |
