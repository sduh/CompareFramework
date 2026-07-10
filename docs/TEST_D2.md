# Procédure de test D1

1. Travailler sur une copie du classeur réel.
2. Conserver la feuille `MODELE` sans la renommer.
3. Vérifier que les feuilles cibles contiennent `ref_scat_abs`.
4. Importer le monolithe D1 ou le module `CF_ModeReference.bas`.
5. Compiler.
6. Exécuter :

```basic
CF_RunAgainstReference_MODELE()
```

## Vérifications

- `Compare_Reference_Plan` liste les feuilles cibles.
- Chaque cible valide a le statut `COMPAREE`.
- Les feuilles sans `ref_scat_abs` ont le statut `IGNOREE`.
- `Stats_Comparaison` contient une ligne par cible.
- `Rapport_Comparaison` indique des paires `MODELE -> <cible>`.
- L'ancien mode `_OLD/_NEW` reste disponible.


## Vérifications D2

- `Compare_Reference_Summary` existe.
- Une ligne est présente par cible comparée.
- Les totaux correspondent à `Stats_Comparaison`.
- Une cible sans différence affiche `OK`.
- Une cible avec différences affiche `ECARTS`.
- Une cible avec doublons ou incidents affiche `A CONTROLER`.
