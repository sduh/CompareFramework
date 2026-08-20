# D2-03.18 — Vague contrôlée sur CompareFramework_Report

        ## Statut
        **VALIDATED**

        ## Garde-fou
        Chaque candidat `local-only` / confiance `high` est croisé avec
        `docs/audit/PUBLIC_SYMBOL_INVENTORY.csv`.

        Toute décision explicite `Keep Public` prévaut sur l'analyse statique.

        ## Périmètre
        Module : `src/CompareFramework_Report.bas`

        Candidats analysés : **11**

        Procédures privatisées :
        - `WriteActionHeader`
- `IsActionableStatus`
- `ActionPriority`
- `ActionRecommendation`
- `ApplyOptionalAutoFilter`
- `BuildHtmlReport`
- `HtmlStyleBlock`
- `HtmlScriptBlock`
- `SheetToHtmlSection`
- `SheetToHtmlTableOnly`
- `HtmlCssClassForCell`

        ## Exclusions contractuelles
        - Aucune

        ## Mesure cumulative
        ```text
        Baseline D2-03.1 Public  : 204
        Après D2-03.18           : 134
        Baseline D2-03.1 Private : 81
        Après D2-03.18           : 151
        ```

        Réduction nette cumulative : **70 procédures publiques**.

        ## Validation
        - garde-fou inventaire API : PASS;
        - 112 contrats `Keep Public` vérifiés : PASS;
        - 0 appel connu non résolu;
        - 0 appel ambigu;
        - monolithe reconstruit : PASS;
        - tests de visibilité D2-03.2 à D2-03.18 : PASS;
        - régressions analyseur : PASS;
        - déterminisme : PASS.

        ## Patch
        `CompareFramework_D2-03.18.patch`
