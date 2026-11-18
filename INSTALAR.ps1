#requires -Version 7.0
# Instalador / atualizador - Claude Code Opus Medium (Windows)
[CmdletBinding()]
param(
  [ValidateSet('Projeto','Global')][string]$Escopo = 'Projeto',
  [string]$Destino = (Get-Location).Path,
  [switch]$VerificacaoRigorosa
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$origem = $PSScriptRoot
$stamp = (Get-Date -Format 'yyyyMMdd-HHmmss-fff')
$dirClaude = if ($Escopo -eq 'Global') {
  if ($env:CLAUDE_CONFIG_DIR) { [System.IO.Path]::GetFullPath($env:CLAUDE_CONFIG_DIR) }
  else { Join-Path $HOME '.claude' }
} else {
  $projeto = [System.IO.Path]::GetFullPath($Destino)
  if (-not (Test-Path -LiteralPath $projeto -PathType Container)) { throw "Pasta do projeto nao existe: $projeto" }
  Join-Path $projeto '.claude'
}
$instrucoes = if ($Escopo -eq 'Global') { Join-Path $dirClaude 'CLAUDE.md' } else { Join-Path $projeto 'CLAUDE.md' }
New-Item -Path $dirClaude -ItemType Directory -Force | Out-Null

function Fazer-Backup([string]$arquivo) {
  if (Test-Path -LiteralPath $arquivo -PathType Leaf) {
    $backup = "$arquivo.backup-$stamp"
    Copy-Item -LiteralPath $arquivo -Destination $backup -ErrorAction Stop
    Write-Host "Backup: $backup" -ForegroundColor DarkCyan
  }
}
function Obter-Json([string]$arquivo) {
  $obj = Get-Content -LiteralPath $arquivo -Raw -Encoding utf8 | ConvertFrom-Json -AsHashtable
  if ($null -eq $obj -or $obj -isnot [System.Collections.IDictionary]) { throw "JSON precisa ser objeto: $arquivo" }
  return $obj
}
function Gravar-Json([string]$arquivo, [System.Collections.IDictionary]$obj) {
  $json = ConvertTo-Json -InputObject $obj -Depth 70
  [System.IO.File]::WriteAllText($arquivo, ($json + "`n"), [System.Text.UTF8Encoding]::new($false))
}

# Modelo principal em Opus Medium. Demais configuracoes do usuario sao mantidas.
$settingsDestino = Join-Path $dirClaude 'settings.json'
$novo = Obter-Json (Join-Path $origem '.claude/settings.json')
$atual = if (Test-Path -LiteralPath $settingsDestino) { Obter-Json $settingsDestino } else { @{} }
if (Test-Path -LiteralPath $settingsDestino) { Fazer-Backup $settingsDestino }

# Modelo principal: atalho 'opus' (acompanha a versao mais nova do Opus), sempre em esforco Medium.
# O esforco fica no nivel geral (effortLevel), valendo para qualquer versao futura do Opus.
$atual.Remove('autoCompactWindow')
$atual['model'] = $novo['model']
$atual['effortLevel'] = $novo['effortLevel']
# Remove esforco fixado por versao (sobrescreveria o Medium geral) deixado por versoes anteriores do pacote.
if ($atual.Contains('modelSettings') -and $atual['modelSettings'] -is [System.Collections.IDictionary]) {
  foreach ($id in @($atual['modelSettings'].Keys)) {
    $cfg = $atual['modelSettings'][$id]
    if ($id -like 'claude-opus-*' -and $cfg -is [System.Collections.IDictionary]) {
      $cfg.Remove('effortLevel'); $cfg.Remove('autoCompactWindow')
      if ($cfg.Count -eq 0) { $atual['modelSettings'].Remove($id) }
    }
  }
  if ($atual['modelSettings'].Count -eq 0) { $atual.Remove('modelSettings') }
}
# Sem bloqueio de leitura de .env: nenhuma regra de permissao e adicionada.

# Hook de verificacao rigorosa opcional (nao ativa por padrao).
if ($VerificacaoRigorosa) {
  $extra = Obter-Json (Join-Path $origem 'PERFIL_VERIFICACAO_INTENSA.json')
  if (-not $atual.Contains('hooks')) { $atual['hooks'] = @{} }
  if ($atual['hooks'] -isnot [System.Collections.IDictionary]) { throw 'hooks existente nao e um objeto JSON.' }
  if (-not $atual['hooks'].Contains('Stop')) { $atual['hooks']['Stop'] = @() }
  $novoHook = $extra['hooks']['Stop'][0]
  $stopAtual = @($atual['hooks']['Stop'])
  $filtros = @()
  foreach ($item in $stopAtual) {
    $eDoPacote = $false
    if ($item -is [System.Collections.IDictionary] -and $item.Contains('hooks')) {
      foreach ($sub in @($item['hooks'])) {
        if ($sub -is [System.Collections.IDictionary] -and $sub.Contains('prompt') -and
          ([string]$sub['prompt']).StartsWith('Você é o portão de qualidade do Claude Code.')) { $eDoPacote = $true }
        if ($sub -is [System.Collections.IDictionary] -and $sub.Contains('prompt') -and
          ([string]$sub['prompt']).StartsWith('Você é um revisor objetivo de encerramento.')) { $eDoPacote = $true }
      }
    }
    if (-not $eDoPacote) { $filtros += $item }
  }
  $atual['hooks']['Stop'] = @($filtros) + @($novoHook)
  Write-Host 'Hook opcional de revisao no encerramento habilitado; pode aumentar o consumo.' -ForegroundColor Yellow
}
Gravar-Json $settingsDestino $atual
Write-Host "Settings atualizados: $settingsDestino" -ForegroundColor Green

# Atualiza arquivos intactos do pacote v1; nunca sobrescreve alteracoes feitas pelo usuario.
$legado = Obter-Json (Join-Path $origem 'MANIFESTO-V1.json')
foreach ($categoria in @('agents', 'skills')) {
  $raizOrigem = Join-Path (Join-Path $origem '.claude') $categoria
  foreach ($f in (Get-ChildItem -LiteralPath $raizOrigem -File -Recurse)) {
    $rel = [System.IO.Path]::GetRelativePath($raizOrigem, $f.FullName)
    $chave = ($categoria + '/' + ($rel -replace '\\', '/'))
    $arquivoDestino = Join-Path (Join-Path $dirClaude $categoria) $rel
    $pastaDestino = Split-Path -Parent $arquivoDestino
    New-Item -Path $pastaDestino -ItemType Directory -Force | Out-Null
    if (-not (Test-Path -LiteralPath $arquivoDestino)) {
      Copy-Item -LiteralPath $f.FullName -Destination $arquivoDestino
      Write-Host "Criado: $arquivoDestino"
      continue
    }
    $hashInstalado = (Get-FileHash -LiteralPath $arquivoDestino -Algorithm SHA256).Hash
    $hashNovo = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash
    if ($hashInstalado -eq $hashNovo) { continue }
    if ($legado.Contains($chave) -and $hashInstalado -eq $legado[$chave]) {
      Fazer-Backup $arquivoDestino
      Copy-Item -LiteralPath $f.FullName -Destination $arquivoDestino -Force
      Write-Host "Atualizado da versao anterior: $arquivoDestino" -ForegroundColor Green
    } else {
      Write-Warning "Arquivo personalizado preservado: $arquivoDestino (compare com o novo pacote manualmente)."
    }
  }
}

# Atualiza apenas o bloco do pacote em CLAUDE.md, preservando todo o restante.
$blocoNovo = Get-Content -LiteralPath (Join-Path $origem 'CLAUDE.md') -Raw -Encoding utf8
$marcadores = @(
  @('<!-- BEGIN ORQUESTRADOR-OPUS-MEDIUM -->','<!-- END ORQUESTRADOR-OPUS-MEDIUM -->'),
  @('<!-- BEGIN ORQUESTRADOR-ECONOMICO -->','<!-- END ORQUESTRADOR-ECONOMICO -->')
)
if (Test-Path -LiteralPath $instrucoes) {
  $texto = Get-Content -LiteralPath $instrucoes -Raw -Encoding utf8
  $aplicado = $false
  foreach ($par in $marcadores) {
    $inicio = $texto.IndexOf($par[0], [System.StringComparison]::Ordinal)
    if ($inicio -ge 0) {
      $fimIndice = $texto.IndexOf($par[1], $inicio, [System.StringComparison]::Ordinal)
      if ($fimIndice -lt 0) { throw "Marcador final nao encontrado em $instrucoes. Nada foi alterado nesse arquivo." }
      Fazer-Backup $instrucoes
      $fim = $fimIndice + $par[1].Length
      $texto = $texto.Substring(0,$inicio) + $blocoNovo.TrimEnd() + $texto.Substring($fim)
      $aplicado = $true
      break
    }
  }
  if (-not $aplicado) {
    Fazer-Backup $instrucoes
    $texto = $texto.TrimEnd() + "`n`n" + $blocoNovo
  }
  [System.IO.File]::WriteAllText($instrucoes, $texto, [System.Text.UTF8Encoding]::new($false))
} else {
  [System.IO.File]::WriteAllText($instrucoes, $blocoNovo, [System.Text.UTF8Encoding]::new($false))
}
Write-Host "Instrucoes atualizadas: $instrucoes" -ForegroundColor Green
Write-Host "`nConcluido: Opus (atalho, sempre Medium) + Sonnet/Haiku auxiliares." -ForegroundColor Green
Write-Host 'No Claude Code, confira /model, /effort, /status, /agents e /skills.'
Write-Host 'Se necessario, execute claude update antes de abrir uma nova sessao.'
if ($Escopo -eq 'Projeto') { Write-Host "Projeto: $projeto" }
