# D2-04.0 — Socle d’exécution CI LibreOffice 7.4.7.2

## Statut

**VALIDATED**

## Contrat runtime

- Socle : LibreOffice 7.4.7.2 uniquement
- Provenance : archive officielle LibreOffice
- Plateforme : GitHub Actions `ubuntu-22.04`
- Exécution : headless
- Profil utilisateur : profil temporaire isolé
- Exécution de macros CompareFramework : hors périmètre de D2-04.0

## Preuves de validation

Run GitHub Actions runtime réussi :

- Workflow : `D2-04.0 LibreOffice 7.4.7.2 runtime`
- Run ID : `32382296896`
- SHA du commit testé : `9e5632d1f3f53abc28e5bf0bc2b4a764a22e0e9d`
- Runner : Ubuntu 22.04.5 LTS (`ubuntu-22.04`)
- Archive officielle : `LibreOffice_7.4.7.2_Linux_x86-64_deb.tar.gz`
- Nombre de paquets installés depuis l’archive : 42
- Exécutable résolu : `/usr/local/bin/libreoffice7.4`
- Version observée : `LibreOffice 7.4.7.2 723314e595e8007d3cf785c16538505a1c878ca5`
- Tests statiques du contrat runtime : PASS (4 tests)
- Vérification syntaxique shell de l’installateur : PASS
- Conversion smoke headless avec profil isolé : PASS
- Sortie smoke : `smoke.txt -> smoke.pdf` via `writer_pdf_Export`
- Validation cumulative D2-03.24 sur le même commit testé : PASS

## Notes d’implémentation

L’installateur appartient au dépôt et se trouve dans `tools/ci/install_libreoffice_7_4_7_2.sh`.
Il télécharge l’archive Debian épinglée depuis l’archive officielle de la Document Foundation, installe uniquement cet ensemble de paquets, vérifie la version runtime observée et exporte le chemin `SOFFICE_BIN` résolu vers GitHub Actions.

Le workflow de validation D2-03.24 reste inchangé et séparé.

## Garde de fusion final

Le commit contenant ce rapport doit lui-même recevoir de nouveaux runs réussis pour le workflow runtime D2-04.0 et le workflow cumulatif D2-03.24 existant avant fusion.

Un succès obtenu sur un commit antérieur constitue bien une preuve enregistrée ci-dessus, mais ne suffit pas à autoriser la fusion du HEAD final de la PR.
