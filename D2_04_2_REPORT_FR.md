# D2-04.2 — Rapport d’automatisation des scénarios fonctionnels

**Statut :** IMPLEMENTED — verification pending

## Périmètre

D2-04.2 automatise le catalogue officiel de régression fonctionnelle T001-T010 à travers LibreOffice 7.4.7.2 réel et le harness UNO introduit par D2-04.1.

## Contrat implémenté

- Le socle LibreOffice est figé exactement sur **7.4.7.2**.
- L’artefact Basic testé est le monolithe généré par `tools/build_monolith.py`.
- Chaque scénario T001-T010 utilise son propre processus LibreOffice, son profil utilisateur temporaire et son document Calc de travail.
- Chaque jeu de données possède désormais un contrat machine canonique `expected.json` ; `expected.md` reste la documentation lisible par l’humain.
- `CF_CI_RunScenario` est un point d’entrée CI technique et non interactif, hors `CompareFramework_API.bas` et hors des six API utilisateur gelées.
- Python prépare `MODELE` et `TARGET`, invoque la vraie comparaison Basic en mode référence, lit les feuilles de sortie natives de CompareFramework, écrit `actual.json` et effectue une égalité stricte des contrats.
- Python ne réimplémente aucune logique de comparaison ligne/cellule de CompareFramework.
- `actual.json` est dérivé des sorties natives `Stats_Comparaison` et `Compare_Reference_Summary`.
- Les scénarios T001-T010 continuent indépendamment après un échec individuel afin de rapporter tous les cas en échec dans un même run.
- Les artefacts de diagnostic sont conservés sous `build/d2-04-2` et téléversés par GitHub Actions.

## Porte de validation

D2-04.2 ne doit pas être marqué `VALIDATED` avant qu’un run GitHub Actions frais sur le HEAD final de la PR ne prouve l’ensemble des points suivants :

- T001 PASS à T010 PASS ;
- agrégat `10/10 PASS` ;
- version LibreOffice observée 7.4.7.2 ;
- validation cumulative/gel API D2-03.24 verte ;
- validation runtime D2-04.0 verte ;
- validation harness UNO Basic D2-04.1 verte.

Les preuves d’exécution seront ajoutées à ce rapport uniquement après réussite de ces contrôles sur le SHA exact du HEAD final.
