# D2-03.23 — Décision sur les points d'entrée maintenance/test

## Statut
**VALIDATED**

## Décision
Les deux derniers points d'entrée `maintenance-entrypoint-review` sont
approuvés pour `Private` :

- `CompareFramework_Main.CF_RunMilestoneB_ConfigTests`
- `CompareFramework_Tests.CF_RunMilestoneBTests`

Cette décision est consignée dans :
`docs/audit/D2_03_23_MAINTENANCE_ENTRYPOINT_DECISION.md`.

## Justification
Pour les deux procédures :
- aucun appelant résolu dans le dépôt;
- aucune référence dans les documents utilisateur contrôlés;
- aucune liaison LibreOffice `.xml`, `.xba`, `.xdl`, `.xlb`;
- elles ne font pas partie de `CompareFramework_API.bas`;
- l'inventaire de support les classait déjà `Review -> Private`.

## État final de l'audit des points d'entrée
```text
Public                         : 118
Private                        : 167
Réduction cumulative Public    : 86

Entrypoints restant à revoir   : 6
API officielles Public         : 6
Maintenance/test à revoir      : 0
Conflits documentation         : 0
```

Les six éléments encore présents dans `entrypoint_audit` et dans la liste
statique des candidats sont exclusivement les six commandes de la façade
officielle `CompareFramework_API`; elles sont protégées par leur contrat
`keep-public-api`.

## Validation
- 2 changements Public -> Private : PASS;
- décision de cycle de vie documentée : PASS;
- contrôle macro/UI/documentation : PASS;
- façade officielle toujours Public : PASS;
- aucun candidat non officiel restant : PASS;
- tests cumulatifs : PASS;
- monolithe reconstruit : PASS;
- 0 appel connu non résolu;
- 0 appel ambigu;
- déterminisme : PASS.
