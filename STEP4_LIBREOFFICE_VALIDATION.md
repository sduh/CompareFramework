# Étape 4 — Validation réelle LibreOffice

## Environnement

- LibreOffice : 25.2.3.2 (Build 520)
- Mode : headless via UNO
- Artefact validé : `dist/CompareFramework-3.8.0-RC1.bas`
- Version attendue : `3.8.0-RC1`

## Résultats automatisés

| Contrôle | Résultat |
|---|---|
| Création d'un classeur Calc réel | PASS |
| Installation du monolithe dans une bibliothèque Basic du document | PASS |
| Compilation réelle du module Basic | PASS |
| Exécution d'une macro du monolithe | PASS |
| Valeur runtime de `CF_VERSION` | PASS — `3.8.0-RC1` |
| Création des feuilles de test OLD et NEW | PASS |
| Contrôle des en-têtes | PASS |
| Détection d'un ajout | PASS |
| Détection d'une suppression | PASS |
| Détection d'une modification | PASS |
| Stabilité d'une ligne inchangée | PASS |
| Test d'arrondi | PASS — `12.345` devient `12.35` |

Résultat de la suite automatisée : **7/7 tests réussis**.

## Anomalie bloquante découverte

Le module `src/CompareFramework_Report.bas` contient encore des libellés actifs de version `V1.3` :

- titre de la boîte de dialogue après export HTML ;
- en-tête du rapport HTML ;
- pied de page du rapport HTML.

Occurrences concernées : lignes 434, 457 et 482, plus le commentaire de section ligne 411.

Ces libellés doivent utiliser `CF_VERSION` avant la publication. Le commentaire historique peut être conservé ou reformulé, mais il ne doit pas être interprété comme la version courante.

## Contrôles nécessitant encore une validation interactive

Les contrôles suivants ne sont pas considérés comme validés par l'exécution headless :

- affichage du lanceur du Mode Référence ;
- interaction avec les boîtes de dialogue ;
- sélection manuelle des feuilles et colonnes ;
- inspection visuelle du rapport dans Calc ;
- ouverture du rapport HTML dans un navigateur ;
- comportement des boutons ou événements liés à un classeur utilisateur.

## Décision de l'étape 4

**NO GO temporaire.**

La compilation réelle et les tests automatisables sont concluants, mais l'export HTML expose encore une version obsolète et les contrôles interactifs restent à exécuter après correction.

## Actions requises

1. Remplacer les trois libellés actifs `V1.3` par `CF_VERSION` dans `CompareFramework_Report.bas`.
2. Reconstruire les artefacts de l'étape 3.
3. Relancer cette validation headless.
4. Exécuter la checklist interactive dans LibreOffice Calc.
5. Passer le certificat à GO uniquement lorsque tous les contrôles sont validés.
