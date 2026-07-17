# Étape 4 — Revalidation LibreOffice après correctif V1.3

## Environnement

- LibreOffice : 25.2.3.2 (Build 520)
- Mode : headless via UNO
- Version attendue : `3.8.0-RC1`
- Artefact testé : `dist/CompareFramework-3.8.0-RC1.bas`

## Résultats automatisés

| Contrôle | Résultat |
|---|---|
| Création d'un classeur Calc réel | PASS |
| Injection et compilation réelle du monolithe Basic | PASS |
| Exécution de `CF_HeadlessValidation` | PASS |
| Version runtime | PASS — `3.8.0-RC1` |
| Suite fonctionnelle automatisée | PASS — 7/7 |
| Arrondi de compatibilité | PASS — `12.35` |
| Génération du HTML par `BuildHtmlReport` | PASS |
| Version courante dans le HTML | PASS |
| Ancien libellé `CompareFramework V1.3` dans le HTML | ABSENT |

## Correctif vérifié

Les trois libellés exécutables de `CompareFramework_Report.bas` utilisent désormais `CF_VERSION` :

- titre de confirmation de l'export HTML ;
- en-tête du rapport HTML ;
- pied de page du rapport HTML.

La mention `V1.3` restante est uniquement un commentaire historique de section et n'est pas exposée à l'exécution.

## Décision automatisée

**PASS pour le périmètre automatisable.**

## Conditions restant nécessaires au GO final

La checklist interactive n'est pas attestée dans cet environnement : lanceur du Mode Référence, boîtes de dialogue, inspection visuelle Calc et navigateur, réouverture du classeur et événements/boutons.

Le certificat reste donc en attente et aucun tag Git n'est créé tant que :

1. la checklist interactive n'est pas signée ;
2. le commit qualifié n'est pas connu ;
3. le dépôt Git réel n'est pas disponible.
