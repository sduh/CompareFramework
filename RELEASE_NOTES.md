# CompareFramework 3.8.0-RC1

## Objet de cette release candidate

La version `3.8.0-RC1` stabilise CompareFramework avant publication. Elle consolide le mode Référence, clarifie l’API publique, harmonise l’architecture du dépôt et rend le build reproductible depuis les modules présents sous `src/`.

## Points principaux

- Façade publique dédiée dans `src/CompareFramework_API.bas`.
- Build du monolithe piloté par `MODULE_ORDER.txt` et `VERSION`.
- Artefact principal : `CompareFramework-3.8.0-RC1.bas`.
- Documentation utilisateur, développeur, architecture et audits réorganisée.
- Gestion uniforme de la version dans le code, les manifestes et les artefacts.
- Certificat de release généré automatiquement depuis Markdown.

## Installation

1. Ouvrir LibreOffice Calc.
2. Aller dans **Outils > Macros > Gérer les macros > Basic**.
3. Créer ou sélectionner un module dans le classeur.
4. Importer `CompareFramework-3.8.0-RC1.bas`.
5. Compiler le module.
6. Exécuter l’un des points d’entrée documentés dans `docs/API_REFERENCE.md`.

## Validation attendue

Cette release candidate a réussi les contrôles statiques du build. Avant publication définitive, elle doit encore réussir :

- la compilation réelle dans LibreOffice ;
- la validation stable intégrée ;
- la validation du mode Référence ;
- les scénarios sur données réelles.

Le certificat de release reste donc au statut **EN ATTENTE** jusqu’à l’achèvement de l’étape 4.

## Limites connues

- Certains cycles internes restent présents entre modules historiques.
- La réduction complète de la surface `Public` est reportée à une évolution majeure.
- La colonne identifiant doit rester unique dans chaque feuille comparée.

Les détails sont documentés dans `docs/release/KNOWN_LIMITATIONS.md` et `docs/audit/`.
