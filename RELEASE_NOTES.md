# CompareFramework 3.8.0

## Publication

La version `3.8.0` est la première publication stable issue de la qualification de `3.8.0-RC1`.
Elle reprend sans modification fonctionnelle le code qualifié de la release candidate et remplace uniquement l’identifiant de version par la version finale.

## Points principaux

- Façade publique dédiée dans `src/CompareFramework_API.bas`.
- Build reproductible du monolithe piloté par `MODULE_ORDER.txt` et `VERSION`.
- Artefact principal : `CompareFramework-3.8.0.bas`.
- Gestion uniforme de la version dans le code, les manifestes et les artefacts.
- Mode Référence consolidé.
- Documentation utilisateur, développeur et architecture réorganisée.
- Certificat de publication et sommes SHA-256 générés automatiquement.

## Installation

1. Ouvrir LibreOffice Calc.
2. Aller dans **Outils > Macros > Gérer les macros > Basic**.
3. Créer ou sélectionner un module dans le classeur.
4. Importer `CompareFramework-3.8.0.bas`.
5. Compiler le module.
6. Exécuter l’un des points d’entrée documentés dans `docs/API_REFERENCE.md`.

## Qualification

La version finale reprend le code de `3.8.0-RC1`, qualifié sous LibreOffice 25.2.3.2 :

- compilation réelle réussie ;
- suite interne : **7/7 tests réussis** ;
- version runtime de la RC conforme ;
- export HTML de la RC conforme ;
- build final vérifié avec injection de `3.8.0` et écriture UTF-8 explicite ;
- aucun libellé de version obsolète actif détecté.

## Limites connues

- Certains cycles internes restent présents entre modules historiques.
- La réduction complète de la surface `Public` est reportée à une évolution majeure.
- La colonne identifiant doit rester unique dans chaque feuille comparée.

Les détails sont conservés dans `docs/audit/` et `docs/PROJECT_HISTORY.md`.
