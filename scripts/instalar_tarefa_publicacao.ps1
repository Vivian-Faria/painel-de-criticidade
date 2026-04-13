param(
    [string]$TaskName = "Painel Orion - Publicacao Automatica",
    [int]$IntervalMinutes = 1,
    [string]$RepoDir = (Split-Path -Parent $PSScriptRoot),
    [string]$LauncherDir = "C:\Users\Public"
)

$ErrorActionPreference = "Stop"

$RepoDir = (Resolve-Path $RepoDir).Path
$ScriptPath = Join-Path $RepoDir "scripts\publicar_painel.ps1"
$LauncherPs1 = Join-Path $LauncherDir "painel_orion_publicar.ps1"
$LauncherBat = Join-Path $LauncherDir "painel_orion_publicar.bat"

$ps1Content = 'powershell -ExecutionPolicy Bypass -File "' + $ScriptPath + '"'
$batContent = "@echo off`r`npowershell -ExecutionPolicy Bypass -File `"$LauncherPs1`"`r`n"

Set-Content -Path $LauncherPs1 -Value $ps1Content -Encoding ASCII
Set-Content -Path $LauncherBat -Value $batContent -Encoding ASCII

schtasks /Create /F /SC MINUTE /MO $IntervalMinutes /TN $TaskName /TR $LauncherBat /ST (Get-Date).AddMinutes(1).ToString("HH:mm") | Out-Null

Write-Output "Tarefa instalada/atualizada: $TaskName"
Write-Output "Intervalo: $IntervalMinutes minuto(s)"
Write-Output "Launcher PS1: $LauncherPs1"
Write-Output "Launcher BAT: $LauncherBat"
