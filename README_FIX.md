# Correctif des libellés V1.3

Ce correctif remplace les trois références actives à `V1.3` dans
`src/CompareFramework_Report.bas` par la constante de version `CF_VERSION`.

## Modifications

- titre de la boîte de dialogue d’export HTML ;
- en-tête du rapport HTML ;
- pied de page du rapport HTML.

Le commentaire historique `V1.3 - HTML REPORT EXPORT` n’est pas modifié.

## Application

Depuis la racine du dépôt :

```bash
patch -p1 < CompareFramework_V1.3_labels.patch
```

Le fichier corrigé complet est également fourni sous
`src/CompareFramework_Report.bas`.

Après application, reconstruire la release puis relancer la validation
LibreOffice de l’étape 4.
