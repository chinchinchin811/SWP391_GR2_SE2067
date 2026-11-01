param(
    [string]$Server = 'localhost',
    [string]$Database = 'HRM_Project_DB',
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'local_exports')
)

$ErrorActionPreference = 'Stop'
# SQLPS bundled with SQL Server requires Windows PowerShell 5.1.
if ($PSVersionTable.PSEdition -eq 'Core') {
    throw 'Run this script using powershell.exe (Windows PowerShell), not pwsh.'
}
Import-Module SQLPS -DisableNameChecking
Write-Output 'Connecting to SQL Server...'
$connection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection
$connection.ConnectionString = "Server=$Server;Integrated Security=True;Encrypt=True;TrustServerCertificate=True;Connect Timeout=15"
$serverObject = New-Object Microsoft.SqlServer.Management.Smo.Server $connection
$connection.Connect()
Write-Output 'Reading database metadata...'
$db = $serverObject.Databases[$Database]
if ($null -eq $db) { throw "Database not found: $Database" }
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
Write-Output "Writing export to $OutputDirectory"
$output = Join-Path $OutputDirectory ($Database + '_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.sql')
$scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter $serverObject
$options = $scripter.Options
$options.ScriptSchema = $true
$options.ScriptData = $true
$options.DriAll = $true
$options.Indexes = $true
$options.Triggers = $true
$options.WithDependencies = $true
$options.ScriptBatchTerminator = $true
$options.IncludeDatabaseContext = $false
$options.ToFileOnly = $true
$options.FileName = $output
$options.Encoding = New-Object System.Text.UTF8Encoding $true
$objects = New-Object 'System.Collections.Generic.List[Microsoft.SqlServer.Management.Sdk.Sfc.Urn]'
foreach ($collection in @($db.Schemas, $db.UserDefinedDataTypes, $db.UserDefinedTableTypes,
        $db.Sequences, $db.Tables, $db.Views, $db.UserDefinedFunctions, $db.StoredProcedures)) {
    foreach ($item in $collection) {
        if ($item.IsSystemObject -eq $true) { continue }
        if ($item -is [Microsoft.SqlServer.Management.Smo.Schema] -and
            ($item.Name -in @('dbo', 'guest', 'sys', 'INFORMATION_SCHEMA') -or $item.Name -like 'db_*')) { continue }
        $objects.Add($item.Urn)
    }
}
$scripter.EnumScript($objects.ToArray()) | Out-Null
$db.Tables | Where-Object { -not $_.IsSystemObject } |
    Select-Object Schema, Name, RowCount |
    Export-Csv -Path ($output + '.counts.csv') -NoTypeInformation -Encoding UTF8
Write-Output "Export created: $output"
