param(
    [string]$TaskName = "Painel Orion - Publicacao Automatica",
    [int]$IntervalMinutes = 5,
    [string]$RepoDir = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$RepoDir = (Resolve-Path $RepoDir).Path
$BatchPath = Join-Path $RepoDir "publicar_painel.bat"

$action = New-ScheduledTaskAction -Execute $BatchPath
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) -RepetitionDuration ([TimeSpan]::MaxValue)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description "Coleta dados do Orion e publica atualizacoes do painel no GitHub." -Force | Out-Null

Write-Output "Tarefa instalada/atualizada: $TaskName"
Write-Output "Intervalo: $IntervalMinutes minuto(s)"
Write-Output "Comando: $BatchPath"
