# D2-03.14 — Premier lot de cinq procédures

        ## Statut
        **VALIDATED**

        ## Périmètre
        Vague limitée à `src/CompareFramework_Rules.bas`.

        Cinq procédures `local-only` / confiance `high` passent de `Public` à `Private` :
        - `RuleAppliesToColumn`
- `RuleAppliesToScope`
- `EvaluateDifferenceRule`
- `ValuesAreEquivalentByList`
- `ValuesAreWithinNumericTolerance`

        ## Mesure cumulative
        ```text
        Baseline D2-03.1 Public  : 204
        Après D2-03.14           : 160
        Baseline D2-03.1 Private : 81
        Après D2-03.14           : 125
        ```

        Réduction cumulée : **44 procédures publiques**.

        ## Validation
        - 0 appel connu non résolu;
        - 0 appel ambigu;
        - monolithe reconstruit : PASS;
        - tests de visibilité D2-03.2 à D2-03.14 : PASS;
        - régressions analyseur : PASS;
        - déterminisme : PASS.

        ## Impact
        Aucune modification de `CompareFramework_API.bas`.

        ## Patch
        `CompareFramework_D2-03.14.patch`
