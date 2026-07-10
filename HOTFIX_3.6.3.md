# CompareFramework V3.6.3 Stable

## Correction

`CF_PreflightComparison()` exécutait deux validations successives qui réinitialisaient les mêmes compteurs et remplaçaient la feuille `Compare_Validation`. Le message final pouvait donc annoncer un échec alors que la dernière feuille affichait `SYNTHESE OK`.

Le préflight est désormais exécuté dans une seule session et produit un rapport unique contenant :

- modules ;
- feuilles de configuration ;
- profils ;
- sources ;
- profil actif.

## Convention de paire actuelle

Pour comparer la feuille MODELE à une cible renommée MODELE_NEW, la référence doit être renommée :

- `MODELE_REF` / `MODELE_NEW`, ou
- `MODELE_OLD` / `MODELE_NEW`.

La paire `MODELE` / `MODELE_NEW` n'est pas reconnue par le moteur V3.6.x. Le futur Jalon D ajoutera le mode référence unique sans renommage.
