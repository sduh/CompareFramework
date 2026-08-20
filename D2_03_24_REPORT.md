# D2-03.24 — Public API Freeze & Closure

## Statut

**IMPLEMENTED — verification pending**

## Contrat gelé

La façade utilisateur supportée est limitée à exactement six procédures de
`CompareFramework_API.bas` :

- `CF_StartReferenceComparison`
- `CF_RunStandardComparison`
- `CF_ExportLastReportHTML`
- `CF_OpenSettings`
- `CF_RunDiagnostics`
- `CF_RunReleaseValidation`

Les procédures `Public` nécessaires aux appels techniques inter-modules restent
autorisées mais ne font pas partie du contrat API utilisateur.

## Garde-fou

Le modèle canonique d'architecture exporte désormais `public_api_contract` et
le schéma passe de `1.5.0` à `1.6.0`.

Le test `tests/test_d2_03_24_public_api_freeze.py` verrouille :

- la liste exacte des six procédures de façade ;
- le statut canonique `frozen` ;
- l'audit résiduel limité aux six `keep-public-api`.

## Baseline de clôture

```text
Public                      : 204 -> 118
Private                     : 167
Réduction cumulative Public : 86
API utilisateur supportées  : 6
Maintenance/test à revoir   : 0
Conflits documentation      : 0
```

## Vérification

La validation complète doit être exécutée sur le dépôt après régénération de
`build/architecture` avec l'analyseur 1.6.0. Le statut `VALIDATED` ne doit être
posé qu'après réussite de cette validation fraîche.
