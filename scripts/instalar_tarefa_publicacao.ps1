param(
    [string]$TaskName = "Painel Orion - Publicacao Automatica",
    [int]$IntervalMinutes = 5,
    [string]$RepoDir = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$RepoDir = (Resolve-Path $RepoDir).Path
$BatchPath = Join-Path $RepoDir "publicar_painel.bat"

$escapedTaskName = '"' + $TaskName + '"'
$escapedBatchPath = '"' + $BatchPath + '"'
$startTime = (Get-Date).AddMinutes(1).ToString("HH:mm")

schtasks /Create /F /SC MINUTE /MO $IntervalMinutes /TN $escapedTaskName /TR $escapedBatchPath /ST $startTime | Out-Null

Write-Output "Tarefa instalada/atualizada: $TaskName"
Write-Output "Intervalo: $IntervalMinutes minuto(s)"
Write-Output "Comando: $BatchPath"
