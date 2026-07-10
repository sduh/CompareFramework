# CHANGELOG

## V3.0 - Jalon A : moteur en memoire

### Ajoute
- `CompareFramework_EngineMemory.bas`.
- Pipeline lecture, indexation, comparaison et rapport en memoire.
- `CF_RunMilestoneA()`.
- `CF_RunMemoryEngineTests()`.

### Modifie
- `ComparerToutesLesFeuilles()` utilise le moteur en memoire.
- L'ancien moteur devient `ComparerToutesLesFeuilles_Legacy()`.
- Version globale portee a 3.0.
- Manifeste et ordre d'import actualises.

### Objectif
Reduire fortement les appels UNO cellule par cellule et rendre le moteur testable par phases.
