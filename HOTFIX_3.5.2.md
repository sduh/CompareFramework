# CompareFramework V3.5.2 — Hotfix Round

Correction de l'erreur LibreOffice Basic :

`Erreur 35 - Sous-procédure ou procédure fonction non définie : Round`

## Modification

L'appel à `Round(..., 3)` a été remplacé par la fonction interne compatible :

`CF_RoundCompat(value, decimals)`

## Validation recommandée

1. Compiler le module.
2. Exécuter `CF_RunAuditTests()`.
3. Vérifier que le message indique `Tests audit : 3/3`.
4. Vérifier la création de la feuille `Compare_Audit`.
