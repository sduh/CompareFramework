# CompareFramework — Référence de l'API

**Statut :** proposition RC-04  
**Version cible :** `3.8.0-RC1`

## 1. Principe

Une procédure déclarée `Public` dans LibreOffice Basic n'appartient pas nécessairement à l'API stable de CompareFramework.

Le mot-clé `Public` est aussi nécessaire pour permettre certains appels entre modules. L'API officielle est donc définie par le présent document et regroupée dans le module :

```text
CompareFramework_API.bas
```

Pour une utilisation normale, l'utilisateur ne doit exécuter directement que les macros de ce module.

## 2. Démarrage rapide

### Comparaison par rapport à une feuille de référence

```basic
CF_StartReferenceComparison
```

Ouvre le lanceur du Mode Référence. C'est le point d'entrée recommandé lorsque le classeur contient une feuille modèle et plusieurs feuilles cibles.

### Comparaison standard

```basic
CF_RunStandardComparison
```

Exécute les contrôles préalables puis lance la comparaison standard.

## 3. API utilisateur stable

| Macro | Usage |
|---|---|
| `CF_StartReferenceComparison()` | Ouvrir le lanceur du Mode Référence |
| `CF_RunStandardComparison()` | Lancer une comparaison standard validée |
| `CF_ExportLastReportHTML()` | Exporter le dernier rapport en HTML |
| `CF_OpenSettings()` | Ouvrir la configuration des comparateurs |

Ces quatre macros constituent l'API utilisateur recommandée pour la RC1.

## 4. API de diagnostic et de maintenance

| Macro | Usage |
|---|---|
| `CF_RunDiagnostics()` | Afficher le diagnostic principal du framework |
| `CF_RunReleaseValidation()` | Exécuter la régression globale avant une release |

Ces macros sont destinées au mainteneur, pas à l'utilisateur métier courant.

## 5. API avancée existante

Les procédures suivantes restent accessibles pour les intégrations avancées, mais ne sont pas les points d'entrée recommandés dans l'interface des macros :

| Procédure | Rôle |
|---|---|
| `CF_RunAgainstReference(referenceSheetName, keyColumnName)` | Lancer directement le Mode Référence avec des paramètres explicites |
| `CF_ApplyProfile(profileName)` | Appliquer un profil |
| `CF_SaveCurrentConfigAsProfile(profileName)` | Enregistrer la configuration comme profil |
| `CF_RunWithProfile(profileName)` | Lancer une comparaison avec un profil |
| `GetFrameworkVersion()` | Retourner la version du framework |
| `FrameworkManifest()` | Retourner les informations de manifeste |

Cette API est utilisable par du code d'intégration. Sa stabilisation définitive doit être confirmée avant la version `3.8.0` finale.

## 6. Compatibilité

Pour une même version majeure :

- les noms et comportements essentiels de l'API utilisateur stable doivent rester compatibles ;
- une procédure ne peut être retirée sans période de dépréciation ;
- les procédures internes peuvent évoluer sans garantie de compatibilité ;
- les procédures de tests et de diagnostic ne constituent pas une API métier.

## 7. Dépréciation

Lorsqu'une macro stable doit être remplacée :

1. conserver l'ancienne macro comme enveloppe temporaire ;
2. documenter son remplacement dans le `CHANGELOG.md` ;
3. afficher un avertissement non bloquant si cela reste compatible avec l'usage ;
4. ne supprimer l'ancienne macro qu'à l'occasion d'une version majeure.

## 8. Macros historiques

Les anciens points d'entrée, notamment les macros `Legacy`, `MilestoneA`, `MilestoneB`, `MilestoneC` et `D1` à `D4`, ne doivent plus être présentés comme API courante.

Ils doivent être soit :

- rendus `Private` lorsqu'ils ne sont utilisés que dans leur module ;
- déplacés dans une bibliothèque de tests ou de compatibilité ;
- maintenus temporairement comme enveloppes de compatibilité clairement dépréciées.

## 9. Règle pour les nouveaux développements

Toute nouvelle macro destinée à être exécutée directement doit :

- être ajoutée dans `CompareFramework_API.bas` ;
- commencer par `CF_` ;
- avoir un nom orienté action ;
- ne pas exposer de détail d'implémentation ;
- être ajoutée à ce document ;
- être couverte par un test de fumée.

Une procédure publique créée uniquement pour un appel entre modules ne doit pas être ajoutée à l'API de référence.
