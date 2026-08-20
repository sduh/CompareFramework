# D2-03.17 — Vague contrôlée sur EngineMemory avec garde-fou API

        ## Statut
        **VALIDATED**

        ## Garde-fou
        Chaque candidat `local-only` / confiance `high` est croisé avec
        `docs/audit/PUBLIC_SYMBOL_INVENTORY.csv`.

        Toute décision explicite `Keep Public` prévaut sur l'analyse statique.

        ## Périmètre
        Module : `src/CompareFramework_EngineMemory.bas`

        Procédures privatisées :
        - `CF_CompareDetectedPairsMemory`
- `CF_CompareFallbackMemory`
- `CF_BuildMemoryIdIndex`
- `CF_CompareMemoryRows`
- `CF_MemoryFullRow`
- `CF_ReportMemoryDuplicates`
- `CF_MemoryValueText`

        ## Exclusions documentées conservées Public
        - `CF_ModeReference.CF_RunAgainstReference` — Advanced API / Keep Public
- `CompareFramework_Main.GetFrameworkVersion` — Advanced API / Keep Public
- `CompareFramework_Profiles.CF_ApplyProfile` — Advanced API / Keep Public
- `CompareFramework_Quality.CF_BuildQualityDashboard` — Developer/diagnostic API / Keep Public
- `CompareFramework_Reliability.CF_RunTypedRegressionSuite` — Developer/diagnostic API / Keep Public

        ## Mesure cumulative
        ```text
        Baseline D2-03.1 Public  : 204
        Après D2-03.17           : 145
        Baseline D2-03.1 Private : 81
        Après D2-03.17           : 140
        ```

        Réduction nette cumulative : **59 procédures publiques**.

        ## Validation
        - garde-fou inventaire API : PASS;
        - 112 contrats `Keep Public` vérifiés : PASS;
        - 0 appel connu non résolu;
        - 0 appel ambigu;
        - monolithe reconstruit : PASS;
        - tests de visibilité D2-03.2 à D2-03.17 : PASS;
        - régressions analyseur : PASS;
        - déterminisme : PASS.

        ## Patch
        `CompareFramework_D2-03.17.patch`
