Option Explicit

' ============================================================================
' CompareFramework - API publique supportee (4.0-D1)
' Version lue par le framework depuis la source de verite du projet.
'
' Ce module regroupe les macros que l'utilisateur doit executer directement.
' Contrat D1 : ces six procedures constituent la seule facade utilisateur supportee.
' Les autres procedures Public restent exposees uniquement pour compatibilite ou
' appels inter-modules et seront migrees par lots dans les jalons suivants.
' ============================================================================

' Point d'entree recommande pour le Mode Reference.
Public Sub CF_StartReferenceComparison()
    CF_OpenReferenceLauncher()
End Sub

' Lance une comparaison standard apres les controles prealables.
Public Sub CF_RunStandardComparison()
    CF_RunValidated()
End Sub

' Exporte le dernier rapport produit au format HTML.
Public Sub CF_ExportLastReportHTML()
    ExporterRapportHTML()
End Sub

' Ouvre la configuration des comparateurs.
Public Sub CF_OpenSettings()
    CF_OpenComparatorConfig()
End Sub

' Affiche le diagnostic principal du framework.
Public Sub CF_RunDiagnostics()
    DiagnosticFramework()
End Sub

' Lance la regression globale. Reserve aux mainteneurs et aux releases.
Public Sub CF_RunReleaseValidation()
    CF_RunGlobalRegression()
End Sub
