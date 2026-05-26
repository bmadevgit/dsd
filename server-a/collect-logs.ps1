# collect-logs.ps1
# Collect error logs from projects, summarize with AI, then push only server-a/logs.
# Scheduled: daily 03:00 AM

$ErrorActionPreference = 'Stop'

$notesDir  = 'C:\notes\server-a'
$logsDir   = 'C:\notes\server-a\logs'
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
$bt        = [char]96

$AI_BASE_URL = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_BASE_URL', 'Machine'))
if ([string]::IsNullOrWhiteSpace($AI_BASE_URL)) { $AI_BASE_URL = 'http://100.99.107.27:8000/v1' }
$AI_API_KEY = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_API_KEY', 'Machine'))
if ([string]::IsNullOrWhiteSpace($AI_API_KEY)) { $AI_API_KEY = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_API_KEY', 'User')) }
if ([string]::IsNullOrWhiteSpace($AI_API_KEY)) { $AI_API_KEY = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_API_KEY', 'Process')) }
$AI_MODEL = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_MODEL', 'Machine'))
if ([string]::IsNullOrWhiteSpace($AI_MODEL)) { $AI_MODEL = 'Qwen/Qwen3-14B' }

function Invoke-AIAnalysis {
    param([string]$Prompt, [int]$MaxTokens = 400)
    if ([string]::IsNullOrWhiteSpace($AI_API_KEY)) {
        return '(AI unavailable: SERVER_A_AI_API_KEY not found)'
    }

    $headers = @{
        Authorization  = "Bearer $AI_API_KEY"
        'Content-Type' = 'application/json; charset=utf-8'
    }
    $bodyObj = @{
        model                = $AI_MODEL
        messages             = @(@{ role = 'user'; content = $Prompt })
        max_tokens           = $MaxTokens
        chat_template_kwargs = @{ enable_thinking = $false }
    }
    $body = $bodyObj | ConvertTo-Json -Depth 6 -Compress
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
        $r = Invoke-WebRequest -Uri ($AI_BASE_URL.TrimEnd('/') + '/chat/completions') `
             -Method Post -Headers $headers -Body $bytes -UseBasicParsing -TimeoutSec 45
        $respBytes = $r.RawContentStream.ToArray()
        $respText = [System.Text.Encoding]::UTF8.GetString($respBytes)
        $obj = $respText | ConvertFrom-Json
        return [string]$obj.choices[0].message.content
    } catch {
        return "(AI unavailable: $($_.Exception.Message))"
    }
}

if (-not (Test-Path -LiteralPath $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

$projects = [ordered]@{
    'bs'           = 'C:\inetpub\wwwroot\bs'
    'bmapoll'      = 'C:\inetpub\wwwroot\bmapoll'
    'car2'         = 'C:\inetpub\wwwroot\car2'
    'q'            = 'C:\inetpub\wwwroot\q'
    'open'         = 'C:\inetpub\wwwroot\open'
    'eva'          = 'C:\inetpub\wwwroot\eva'
    'now'          = 'C:\inetpub\wwwroot\now'
    'vibe-ide'     = 'C:\inetpub\vibe-ide'
    'exam-a'       = 'C:\inetpub\wwwroot\exam\a'
    'exam-ai'      = 'C:\inetpub\wwwroot\exam\ai'
    'exam-ar'      = 'C:\inetpub\wwwroot\exam\ar1'
    'exam-bike'    = 'C:\inetpub\wwwroot\exam\bike'
    'exam-chatbot' = 'C:\inetpub\wwwroot\exam\chatbot'
    'exam-disc'    = 'C:\inetpub\wwwroot\exam\disc'
    'exam-map'     = 'C:\inetpub\wwwroot\exam\map'
    'exam-server'  = 'C:\inetpub\wwwroot\exam\server'
    'exam-vhv'     = 'C:\inetpub\wwwroot\exam\vhv'
}

$cutoff = (Get-Date).AddHours(-24)

foreach ($name in $projects.Keys) {
    $path   = $projects[$name]
    $mdFile = Join-Path $logsDir "$name.md"

    if (-not (Test-Path -LiteralPath $path)) {
        Write-Host "SKIP $name - path not found"
        continue
    }

    $logFiles = Get-ChildItem -LiteralPath $path -Recurse -Filter '*.log' -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.LastWriteTime -gt $cutoff         -and
            $_.FullName -notmatch 'node_modules' -and
            $_.FullName -notmatch '\.venv'       -and
            $_.FullName -notmatch '\\vendor\\'   -and
            $_.FullName -notmatch '\\obj\\'      -and
            $_.FullName -notmatch '\\bin\\'
        } |
        Sort-Object LastWriteTime -Descending

    if ($logFiles.Count -eq 0) {
        Write-Host "SKIP $name - no log changes in last 24h"
        continue
    }

    Write-Host "Processing $name ($($logFiles.Count) log files)..."

    $doc = [System.Collections.Generic.List[string]]::new()
    $doc.Add("# $name - Error Log Analysis")
    $doc.Add('')
    $doc.Add("_auto-generated $timestamp_")
    $doc.Add('')

    $allExcerpts = [System.Text.StringBuilder]::new()
    $logMeta = [System.Collections.Generic.List[string]]::new()

    foreach ($lf in $logFiles) {
        $rel      = $lf.FullName.Substring($path.Length).TrimStart('\')
        $sizeKB   = [math]::Round($lf.Length / 1KB, 1)
        $modified = $lf.LastWriteTime.ToString('yyyy-MM-dd HH:mm')

        $logMeta.Add("- $($bt)$rel$($bt) - $($sizeKB) KB, modified $modified")

        $lines = Get-Content -LiteralPath $lf.FullName -Tail 200 -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $lines) { continue }

        $excerpt = $lines -join "`n"
        if ($excerpt.Length -gt 3000) { $excerpt = $excerpt.Substring($excerpt.Length - 3000) }

        [void]$allExcerpts.AppendLine("=== $rel ===")
        [void]$allExcerpts.AppendLine($excerpt)
        [void]$allExcerpts.AppendLine()
    }

    $excerptText = $allExcerpts.ToString()
    $prompt = @"
Project: $name

Log content (last 200 lines each):
$excerptText

Analyze this log and respond in Thai language with 3 sections:
1) Error/Warning found
2) Main cause
3) Suggested fix
Keep it concise and practical.
"@
    $aiResult = Invoke-AIAnalysis -Prompt $prompt -MaxTokens 400

    $doc.Add('## AI Analysis')
    $doc.Add('')
    $doc.Add($aiResult.Trim())
    $doc.Add('')
    $doc.Add('---')
    $doc.Add('')
    $doc.Add('## Log Files Scanned')
    $doc.Add('')
    foreach ($m in $logMeta) { $doc.Add($m) }
    $doc.Add('')
    $doc.Add('---')
    $doc.Add('')
    $doc.Add('## Raw Excerpts (last 200 lines)')

    foreach ($lf in $logFiles) {
        $rel   = $lf.FullName.Substring($path.Length).TrimStart('\')
        $lines = Get-Content -LiteralPath $lf.FullName -Tail 200 -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $lines) { continue }

        $doc.Add('')
        $doc.Add("### $rel")
        $doc.Add('')
        $doc.Add("$($bt)$($bt)$($bt)")
        $doc.Add(($lines -join "`n"))
        $doc.Add("$($bt)$($bt)$($bt)")
    }

    $content = ($doc -join "`n") + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($mdFile, $content, $utf8NoBom)
    Write-Host "Written: logs/$name.md"
}

Set-Location 'C:\notes'
& git pull --rebase --autostash origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "git pull failed - skip commit/push"
    exit 1
}

& git add server-a/logs/

$dirty = & git status --porcelain server-a/logs/
if ($dirty) {
    & git commit -m "auto-logs: error log analysis $timestamp" -- server-a/logs/
    & git push origin HEAD:main
    Write-Host "Pushed logs to GitHub: $timestamp"
} else {
    Write-Host 'No log changes - nothing to push'
}
