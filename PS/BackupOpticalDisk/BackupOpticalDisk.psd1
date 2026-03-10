@{
    RootModule        = 'BackupOpticalDisk.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '7b7e0b43-0b5e-4b07-9b7c-1234567890ab'
    Author            = 'Andrey'
    CompanyName       = 'Community'
    PowerShellVersion = '5.1'
    Description       = 'Backup optical discs to ISO+ZIP+meta.json with automatic 0001-OP folders.'
    FunctionsToExport = @('Backup-OpticalDisk')
    CmdletsToExport   = @()
    AliasesToExport   = @()
    VariablesToExport = @()
}
