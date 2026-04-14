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
$LauncherVbs = Join-Path $LauncherDir "painel_orion_publicar.vbs"

$ps1Content = 'powershell -ExecutionPolicy Bypass -File "' + $ScriptPath + '"'
$vbsContent = @'
Set shell = CreateObject("WScript.Shell")
shell.Run "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File ""C:\Users\Public\painel_orion_publicar.ps1""", 0, False
'@

Set-Content -Path $LauncherPs1 -Value $ps1Content -Encoding ASCII
Set-Content -Path $LauncherVbs -Value $vbsContent -Encoding ASCII

schtasks /Create /F /SC MINUTE /MO $IntervalMinutes /TN $TaskName /TR "wscript.exe `"$LauncherVbs`"" /ST (Get-Date).AddMinutes(1).ToString("HH:mm") | Out-Null

Write-Output "Tarefa instalada/atualizada: $TaskName"
Write-Output "Intervalo: $IntervalMinutes minuto(s)"
Write-Output "Launcher PS1: $LauncherPs1"
Write-Output "Launcher VBS: $LauncherVbs"
