# D2-03.21 — Traitement contrôlé des candidats Private après régression

## Statut
**VALIDATED**

## Périmètre
Les 12 procédures classées `private-after-regression-review` par D2-03.20 ont
été soumises à un contrôle supplémentaire avant modification :

- décision d'inventaire `candidate-private-after-regression`;
- absence de référence dans la documentation utilisateur surveillée;
- absence de liaison dans les artefacts LibreOffice `.xml`, `.xba`, `.xdl`, `.xlb`;
- validation cumulative de l'analyseur et du monolithe.

## Procédures passées Private
- `CF_ModeReference.CF_RunLauncherQuick`
- `CompareFramework_Audit.CF_AuditClearHistory`
- `CompareFramework_ComparatorConfig.CF_ReloadComparatorConfig`
- `CompareFramework_Context.CF_ContextCount`
- `CompareFramework_Main.CF_RunMilestoneA`
- `CompareFramework_Main.CF_RunMilestoneB`
- `CompareFramework_Main.CF_RunMilestoneB_Final`
- `CompareFramework_Main.CF_RunMilestoneC`
- `CompareFramework_Main.CF_RunMilestoneC_Final`
- `CompareFramework_Main.CF_RunPerformanceProfiled`
- `CompareFramework_Main.ComparerToutesLesFeuilles_Contextualisee`
- `CompareFramework_Profiles.CF_ListProfiles`

## Contrôle des surfaces externes
Aucune référence externe détectée pour les 12 procédures dans les surfaces
LibreOffice/UI et documents utilisateur contrôlés.

## État après D2-03.21
```text
Public                         : 122
Private                        : 163
Réduction cumulative Public    : 82

Entrypoints restant à revoir   : 10
API officielles Public         : 6
Conflits documentation         : 2
Maintenance/test               : 2
Private-after-regression       : 0
```

Les 10 procédures restantes sont volontairement hors périmètre de cette vague.

## Validation
- 12 changements Public -> Private : PASS;
- contrôle macro/UI/doc externe : PASS;
- audit résiduel cohérent : PASS;
- tests D2-03.2 à D2-03.21 : PASS;
- monolithe reconstruit : PASS;
- 0 appel connu non résolu;
- 0 appel ambigu;
- déterminisme : PASS.
