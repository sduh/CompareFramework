# D2-03.13 — Lot de quatre procédures

        ## Statut
        **VALIDATED**

        ## Périmètre
        Vague limitée à `src/CompareFramework_Config.bas`.

        Quatre procédures `local-only` / confiance `high` passent de `Public` à `Private` :
        - `WriteDefaultConfig`
- `EnsureRulesSheet`
- `WriteDefaultRulesSheet`
- `TokenInList`

        ## Mesure cumulative
        ```text
        Baseline D2-03.1 Public  : 204
        Après D2-03.13           : 165
        Baseline D2-03.1 Private : 81
        Après D2-03.13           : 120
        ```

        Réduction cumulée : **39 procédures publiques**.

        ## Validation
        - 0 appel connu non résolu;
        - 0 appel ambigu;
        - monolithe reconstruit : PASS;
        - tests de visibilité D2-03.2 à D2-03.13 : PASS;
        - régressions analyseur : PASS;
        - déterminisme : PASS.

        ## Impact
        Aucune modification de `CompareFramework_API.bas`.

        ## Patch
        `CompareFramework_D2-03.13.patch`
