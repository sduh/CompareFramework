Option Explicit

' ============================================================================
' CompareFramework - API publique simplifiee
' Version lue par le framework depuis la source de verite du projet.
'
' Ce module regroupe les macros que l'utilisateur doit executer directement.
' Les autres procedures Public existent principalement pour les appels internes
' entre modules LibreOffice Basic.
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
