# CompareFramework V3.5.9 — Hotfix validation bout en bout

## Problèmes corrigés

### 1. Statuts métier différents

Le rapport écrit les codes internes :

- `AJOUTE`
- `SUPPRIME`
- `MODIFIE`

Les scénarios attendaient :

- `AJOUT`
- `SUPPRESSION`
- `MODIFICATION`

Les validateurs comparent désormais les statuts par familles d'alias et lisent directement
les colonnes `Type`, `ID` et `Colonne` du rapport.

### 2. Tests non exécutés

Dans `CF_Quality_Dashboard`, une feuille de test absente est désormais indiquée
`NON EXECUTE` au lieu de `ABSENT`.

Le statut global devient :

- `OK` : toutes les suites exécutées sont vertes et aucune ne manque ;
- `PARTIEL OK` : les suites exécutées sont vertes, mais certaines ne sont pas encore lancées ;
- `A CONTROLER` : au moins une suite est en échec.

## Validation

1. Exécuter `CF_RunEndToEndScenario()`.
2. Vérifier `CF_Quality_Results` : 3/3, `OK`.
3. Vérifier `CF_Quality_Dashboard` : scénario `OK`, statut global `PARTIEL OK`
   si les autres suites n'ont pas encore été lancées.
4. Exécuter ensuite `CF_RunGlobalRegression()` pour viser un statut global `OK`.
