# CHANGELOG

## V2.5 - Execution Context

### Ajouté
- Nouveau module `CompareFramework_Context.bas`.
- API de contexte : `CF_ContextReset`, `CF_ContextSet`, `CF_ContextGet`, `CF_ContextHas`.
- Gestion début/fin d'exécution : `CF_ContextBeginRun`, `CF_ContextEndRun`.
- Export du contexte dans la feuille `Compare_Context`.
- Wrapper `ComparerToutesLesFeuilles_Contextualisee()`.
- Wrapper `DiagnosticFramework_Contextualise()`.
- Tests `CF_RunContextTests()`.

### Objectif
Préparer le remplacement progressif des variables globales par un contexte d'exécution centralisé, sans casser l'API publique existante.
