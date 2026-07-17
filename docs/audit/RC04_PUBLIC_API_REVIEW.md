# RC-04 — Revue de l'API publique

## 1. Résultat de l'analyse

L'analyse statique des sources relève :

- **198** procédures et fonctions déclarées publiques ;
- **62** `Sub` publiques sans paramètre obligatoire, donc potentiellement visibles comme macros exécutables ;
- **86** symboles sans appel détecté depuis un autre module, candidats à un passage en `Private` ;
- parmi eux, **25 macros sans paramètre** peuvent être masquées de manière particulièrement rentable.

Le problème utilisateur principal est donc confirmé : la boîte de dialogue des macros présente trop de commandes techniques, historiques et de tests.

## 2. Décision proposée

Créer une façade publique unique :

```text
src/CompareFramework_API.bas
```

Elle contient seulement six commandes clairement nommées :

### API utilisateur

- `CF_StartReferenceComparison()`
- `CF_RunStandardComparison()`
- `CF_ExportLastReportHTML()`
- `CF_OpenSettings()`

### Maintenance

- `CF_RunDiagnostics()`
- `CF_RunReleaseValidation()`

La documentation doit indiquer explicitement :

> Pour exécuter CompareFramework, utiliser uniquement les macros du module `CompareFramework_API`.

## 3. Première réduction sûre

Les 25 macros suivantes n'ont aucun appel inter-module détecté et peuvent être examinées en priorité pour devenir `Private` :

- `CF_AuditWriteCurrentRun`
- `CF_AuditClearHistory`
- `CF_ReloadComparatorConfig`
- `CF_ContextInitIfNeeded`
- `ComparerToutesLesFeuilles_Legacy`
- `CF_RunMilestoneA`
- `ComparerToutesLesFeuilles_Contextualisee`
- `CF_RunAudited`
- `CF_RunPerformanceProfiled`
- `CF_RunMilestoneB`
- `CF_RunMilestoneB_Configured`
- `CF_RunMilestoneB_ConfigTests`
- `CF_RunMilestoneB_Final`
- `CF_RunMilestoneC`
- `CF_RunMilestoneC_Final`
- `CF_ListProfiles`
- `CF_RunEndToEndScenario`
- `CF_ValidateExpectedReport`
- `CF_BuildComparatorCoverageReport`
- `CF_RunFinanceScenario`
- `CF_RunHRScenario`
- `CF_RunERPScenario`
- `CF_RunMilestoneBTests`
- `CF_ReferenceFormatPlan`
- `CF_RunLauncherQuick`

Avant modification, une recherche complémentaire doit vérifier qu'aucune de ces macros n'est liée à un bouton, un événement de document ou un appel externe enregistré dans un classeur.

## 4. Limite de LibreOffice Basic

Certaines procédures internes doivent rester `Public` parce qu'elles sont appelées depuis un autre module Basic. Elles ne font pourtant pas partie de l'API officielle.

Le passage systématique de tous les helpers en `Private` casserait ces appels. La réduction complète de la liste visible nécessite donc une évolution structurelle, et pas seulement un changement de visibilité.

## 5. Plan RC1

### À faire avant RC1

1. ajouter `CompareFramework_API.bas` ;
2. ajouter `docs/API_REFERENCE.md` ;
3. déclarer les 25 macros internes sûres en `Private`, après contrôle des liaisons externes ;
4. retirer des guides les anciens noms de macros ;
5. présenter `CF_StartReferenceComparison` et `CF_RunStandardComparison` comme seuls points d'entrée principaux ;
6. ajouter le nouveau module à `MODULE_ORDER.txt` et au build.

### À ne pas faire avant RC1

- déplacer massivement les procédures entre modules ;
- modifier les signatures nécessaires aux appels inter-modules ;
- renommer les helpers du moteur ;
- séparer immédiatement toutes les bibliothèques de tests.

Ces changements seraient trop risqués pendant la stabilisation.

## 6. Plan CompareFramework 4

Pour réduire réellement la boîte de dialogue à quelques macros, séparer les bibliothèques :

```text
CompareFramework
├── CompareFramework_API
└── runtime interne

CompareFramework_Dev
├── tests
├── scénarios
├── benchmarks
└── outils de release
```

La bibliothèque installée chez l'utilisateur ne contiendrait plus les tests, scénarios et macros de jalons.

Un second axe consiste à regrouper davantage de helpers dans leurs modules consommateurs afin qu'ils puissent devenir `Private`.

## 7. Objectif mesurable

### RC1

- API officielle : **4 macros utilisateur** ;
- API de maintenance : **2 macros** ;
- réduction immédiate possible de la liste visible : **25 macros** ;
- documentation donnant un seul chemin de démarrage par mode.

### V4

- moins de **10 macros visibles** dans la bibliothèque utilisateur ;
- tests et outils de release absents de la distribution runtime ;
- aucune macro `Milestone*` exposée ;
- API stable versionnée et testée.

## 8. Décision RC-04

**Favorable sous condition.**

La RC1 peut conserver les appels inter-modules publics imposés par LibreOffice Basic, à condition de :

- publier une façade officielle claire ;
- masquer les macros internes sans dépendance externe ;
- documenter la différence entre visibilité Basic et API contractuelle ;
- programmer la séparation runtime/développement pour V4.
