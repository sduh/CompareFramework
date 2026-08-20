# D2-03.16 — Garde-fou de contrat public et réconciliation

## Statut
**VALIDATED**

## Garde-fou
Chaque candidat `local-only` / confiance `high` est désormais croisé avec
`docs/audit/PUBLIC_SYMBOL_INVENTORY.csv`.

Une décision explicite `Keep Public` prévaut sur la qualification statique.

## Réconciliation historique
Le nouveau garde-fou a identifié trois symboles `Keep Public` qui avaient été
privatisés avant son introduction. Ils sont restaurés `Public` :

- `CompareFramework_Profiles.bas:CF_ApplyProfile` — Advanced API / Keep Public
- `CompareFramework_Quality.bas:CF_BuildQualityDashboard` — Developer/diagnostic API / Keep Public
- `CompareFramework_Reliability.bas:CF_RunTypedRegressionSuite` — Developer/diagnostic API / Keep Public

## Exclusions courantes
Les candidats suivants restent `Public` malgré leur qualification statique :

- `CF_ModeReference.CF_RunAgainstReference` — Advanced API / Keep Public
- `CompareFramework_Main.GetFrameworkVersion` — Advanced API / Keep Public
- `CompareFramework_Profiles.CF_ApplyProfile` — Advanced API / Keep Public
- `CompareFramework_Quality.CF_BuildQualityDashboard` — Developer/diagnostic API / Keep Public
- `CompareFramework_Reliability.CF_RunTypedRegressionSuite` — Developer/diagnostic API / Keep Public

## Nouvelle vague appliquée
Module : `src/Modes/CF_ModeReference.bas`

- `CF_BuildReferencePlan` → Private
- `CF_ReferenceIsTargetSheet` → Private
- `CF_ReferenceSheetHasKey` → Private
- `CF_ReferencePlanSetStatus` → Private
- `CF_ReferenceFormatPlan` → Private
- `CF_ReferenceBuildSummary` → Private
- `CF_ReferenceFormatSummary` → Private

## Mesure cumulative
```text
Baseline D2-03.1 Public  : 204
Après D2-03.16           : 152
Baseline D2-03.1 Private : 81
Après D2-03.16           : 133
```

Réduction nette cumulative : **52 procédures publiques**.

## Validation
- réconciliation `Keep Public` : PASS;
- 112 contrats `Keep Public` vérifiés dans les sources : PASS;
- exclusions documentées vérifiées : PASS;
- 0 appel connu non résolu;
- 0 appel ambigu;
- monolithe reconstruit : PASS;
- tests de visibilité D2-03.2 à D2-03.16 : PASS;
- régressions analyseur : PASS;
- déterminisme : PASS.

## Patch
`CompareFramework_D2-03.16.patch`
