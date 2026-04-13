param(
    [string]$RepoDir = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$RepoDir = (Resolve-Path $RepoDir).Path
$LogDir = Join-Path $RepoDir "logs"
$LogFile = Join-Path $LogDir "publicacao-painel.log"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Message"
    Add-Content -Path $LogFile -Value $line
    Write-Output $line
}

function Invoke-Checked {
    param(
        [string]$FilePath,
        [string[]]$Arguments,
        [string]$WorkingDirectory = $RepoDir
    )

    Write-Log ("Executando: {0} {1}" -f $FilePath, ($Arguments -join " "))
    Push-Location $WorkingDirectory
    try {
        & $FilePath @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao executar: $FilePath $($Arguments -join ' ')"
        }
    }
    finally {
        Pop-Location
    }
}

function Get-JsonSummary {
    param([string]$JsonPath)
    $json = Get-Content -Raw $JsonPath | ConvertFrom-Json
    [PSCustomObject]@{
        Total = [int]$json.total
        AtualizadoEm = [string]$json.atualizado_em
    }
}

Write-Log "Inicio da publicacao automatica."

$jsonPath = Join-Path $RepoDir "dados_orion.json"
$deployJsonPath = Join-Path $RepoDir "deploy-netlify\dados_orion.json"

Invoke-Checked -FilePath "git" -Arguments @("pull", "--rebase", "origin", "main")
Invoke-Checked -FilePath "python" -Arguments @("orion_scraper_1.py", "--output-dir", ".", "--publish-dir", "deploy-netlify")

$summary = Get-JsonSummary -JsonPath $jsonPath
if ($summary.Total -le 0) {
    throw "JSON invalido apos coleta: total=$($summary.Total)."
}

Write-Log "JSON validado. total=$($summary.Total) atualizado_em=$($summary.AtualizadoEm)"

$status = git -C $RepoDir status --porcelain -- "dados_orion.json" "deploy-netlify/dados_orion.json" "index.html" "deploy-netlify/index.html"
if (-not $status) {
    Write-Log "Nenhuma mudanca detectada para publicar."
    exit 0
}

Invoke-Checked -FilePath "git" -Arguments @("add", "dados_orion.json", "deploy-netlify/dados_orion.json", "index.html", "deploy-netlify/index.html")
Invoke-Checked -FilePath "git" -Arguments @("commit", "-m", "chore: atualiza dados do painel")
Invoke-Checked -FilePath "git" -Arguments @("push")

$deploySummary = Get-JsonSummary -JsonPath $deployJsonPath
Write-Log "Publicacao concluida. deploy total=$($deploySummary.Total) atualizado_em=$($deploySummary.AtualizadoEm)"
