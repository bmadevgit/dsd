# collect-logs.ps1
# Collect error logs from all projects, analyze with AI, push to GitHub
# Scheduled: daily 03:00 AM

$notesDir  = "C:\notes\server-a"
$logsDir   = "C:\notes\server-a\logs"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$bt        = [char]96

$AI_BASE_URL = "http://100.99.107.27:8000/v1"
$AI_API_KEY  = "bon8ihWaS8jqebRIBTt8M3_qV1MLqKbHTnhvaQuHRYm92cVe"

function Invoke-AIAnalysis {
    param([string]$Prompt, [int]$MaxTokens = 400)
    $headers = @{
        "Authorization" = "Bearer $AI_API_KEY"
        "Content-Type"  = "application/json"
    }
    $bodyObj = @{
        model                = "Qwen/Qwen3-14B"
        messages             = @(@{ role = "user"; content = $Prompt })
        max_tokens           = $MaxTokens
        chat_template_kwargs = @{ enable_thinking = $false }
    }
    $body = $bodyObj | ConvertTo-Json -Depth 5 -Compress
    try {
        $r = Invoke-RestMethod -Uri "$AI_BASE_URL/chat/completions" `
             -Method Post -Headers $headers -Body $body -TimeoutSec 45
        return $r.choices[0].message.content.Trim()
    } catch {
        return "(AI unavailable: $($_.Exception.Message))"
    }
}

# Create logs directory if needed
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

$projects = [ordered]@{
    "bs"           = "C:\inetpub\wwwroot\bs"
    "bmapoll"      = "C:\inetpub\wwwroot\bmapoll"
    "car2"         = "C:\inetpub\wwwroot\car2"
    "q"            = "C:\inetpub\wwwroot\q"
    "open"         = "C:\inetpub\wwwroot\open"
    "eva"          = "C:\inetpub\wwwroot\eva"
    "now"          = "C:\inetpub\wwwroot\now"
    "vibe-ide"     = "C:\inetpub\vibe-ide"
    "exam-a"       = "C:\inetpub\wwwroot\exam\a"
    "exam-ai"      = "C:\inetpub\wwwroot\exam\ai"
    "exam-ar"      = "C:\inetpub\wwwroot\exam\ar1"
    "exam-bike"    = "C:\inetpub\wwwroot\exam\bike"
    "exam-chatbot" = "C:\inetpub\wwwroot\exam\chatbot"
    "exam-disc"    = "C:\inetpub\wwwroot\exam\disc"
    "exam-map"     = "C:\inetpub\wwwroot\exam\map"
    "exam-server"  = "C:\inetpub\wwwroot\exam\server"
    "exam-vhv"     = "C:\inetpub\wwwroot\exam\vhv"
}

$cutoff = (Get-Date).AddHours(-24)

foreach ($name in $projects.Keys) {
    $path   = $projects[$name]
    $mdFile = Join-Path $logsDir "$name.md"

    if (-not (Test-Path $path)) { Write-Host "SKIP $name - path not found"; continue }

    # Find .log files modified in last 24h (exclude build artifacts)
    $logFiles = Get-ChildItem -Path $path -Recurse -Filter "*.log" -File -ErrorAction SilentlyContinue |
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

    # Build output document
    $doc = [System.Collections.Generic.List[string]]::new()
    $doc.Add("# $name - Error Log Analysis")
    $doc.Add("")
    $doc.Add("_auto-generated $timestamp_")
    $doc.Add("")

    # Collect all log excerpts for one AI call per project
    $allExcerpts = [System.Text.StringBuilder]::new()

    $logMeta = [System.Collections.Generic.List[string]]::new()

    foreach ($lf in $logFiles) {
        $rel      = $lf.FullName.Substring($path.Length).TrimStart('\')
        $sizeKB   = [math]::Round($lf.Length / 1KB, 1)
        $modified = $lf.LastWriteTime.ToString("yyyy-MM-dd HH:mm")

        $logMeta.Add("- $($bt)$rel$($bt) — $($sizeKB) KB, modified $modified")

        # Read last 200 lines
        $lines = Get-Content -Path $lf.FullName -Tail 200 -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $lines) { continue }

        $excerpt = $lines -join "`n"
        # Trim to 3000 chars per file to stay within context limit
        if ($excerpt.Length -gt 3000) { $excerpt = $excerpt.Substring($excerpt.Length - 3000) }

        [void]$allExcerpts.AppendLine("=== $rel ===")
        [void]$allExcerpts.AppendLine($excerpt)
        [void]$allExcerpts.AppendLine()
    }

    # AI analysis
    $excerptText = $allExcerpts.ToString()
    $prompt = "Project: $name`n`nLog content (last 200 lines each):`n$excerptText`n`nวิเคราะห์ log นี้:`n1. มี error หรือ warning อะไรบ้าง`n2. ปัญหาหลักคืออะไร`n3. แนวทางแก้ไข`nสรุปเป็นภาษาไทย กระชับ"
    $aiResult = Invoke-AIAnalysis -Prompt $prompt -MaxTokens 400

    # Write document
    $doc.Add("## AI Analysis")
    $doc.Add("")
    $doc.Add($aiResult)
    $doc.Add("")
    $doc.Add("---")
    $doc.Add("")
    $doc.Add("## Log Files Scanned")
    $doc.Add("")
    foreach ($m in $logMeta) { $doc.Add($m) }
    $doc.Add("")
    $doc.Add("---")
    $doc.Add("")
    $doc.Add("## Raw Excerpts (last 200 lines)")

    foreach ($lf in $logFiles) {
        $rel   = $lf.FullName.Substring($path.Length).TrimStart('\')
        $lines = Get-Content -Path $lf.FullName -Tail 200 -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $lines) { continue }

        $doc.Add("")
        $doc.Add("### $rel")
        $doc.Add("")
        $doc.Add("$($bt)$($bt)$($bt)")
        $doc.Add(($lines -join "`n"))
        $doc.Add("$($bt)$($bt)$($bt)")
    }

    $content = ($doc -join "`n") + "`n"
    [System.IO.File]::WriteAllText($mdFile, $content, [System.Text.Encoding]::UTF8)
    Write-Host "Written: logs/$name.md"
}

# Commit and push C:\notes
Set-Location "C:\notes"
& git add server-a/logs/

$dirty = & git status --porcelain
if ($dirty) {
    & git commit -m "auto-logs: error log analysis $timestamp"
    & git pull origin main --rebase --autostash
    & git push origin
    Write-Host "Pushed logs to GitHub: $timestamp"
} else {
    Write-Host "No log changes - nothing to push"
}
