# refresh-server-b-logs.ps1
# Scan each project's logs for .log files modified in last 24h, send tail to AI for analysis,
# write to C:\notes\server-b\logs\{project}.md, then commit+push (server-b/ only).
# Run daily at 03:00 via Windows Task Scheduler (after 02:00 refresh).

$ErrorActionPreference = 'Stop'

$NotesRoot   = 'C:\notes'
$ServerBDir  = Join-Path $NotesRoot 'server-b'
$LogsOutDir  = Join-Path $ServerBDir 'logs'
$Now         = Get-Date
$DateStr     = $Now.ToString('yyyy-MM-dd HH:mm')

if (-not (Test-Path $LogsOutDir)) { New-Item -ItemType Directory -Path $LogsOutDir -Force | Out-Null }

# Load AI credentials (gitignored)
$ConfigPath = Join-Path $ServerBDir '.config.ps1'
if (-not (Test-Path $ConfigPath)) {
    Write-Error "No .config.ps1 found - cannot run AI analysis"
    exit 1
}
. $ConfigPath

# Project -> list of log paths to scan. Each entry can be a file or a folder; folders are scanned recursively for *.log/*.err/*.out
$projectLogPaths = [ordered]@{
    'lake' = @(
        'C:\inetpub\lake-data'
    )
    'chatbot' = @(
        'C:\inetpub\wwwroot\chatbot\tmp-iis.cookie',
        'C:\inetpub\wwwroot\chatbot\tmp-php-server.err.log',
        'C:\inetpub\wwwroot\chatbot\tmp-php-server.out.log',
        'C:\inetpub\chatbot-data'
    )
    'link' = @(
        'C:\inetpub\wwwroot\link\storage\logs',
        'C:\inetpub\wwwroot\link\storage'
    )
    'open' = @(
        'C:\inetpub\wwwroot\open\logs'
    )
    'realtime-frontend' = @()
    'realtime-backend' = @(
        'C:\apps\realtime-thai-transcribe\logs'
    )
    'bma-houseid-proxy' = @()
    'iis-shared' = @(
        'C:\inetpub\logs\LogFiles'
    )
}

function Get-LogFilesModifiedSince {
    param([string[]]$Paths, [datetime]$Since)
    $results = @()
    foreach ($p in $Paths) {
        if (-not (Test-Path $p)) { continue }
        $item = Get-Item $p -ErrorAction SilentlyContinue
        if (-not $item) { continue }
        if ($item.PSIsContainer) {
            $found = Get-ChildItem $p -Recurse -File -Force -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.LastWriteTime -gt $Since -and
                    ($_.Extension -match '^\.(log|err|out)$' -or $_.Name -match '\.log\.' -or $_.Name -match '\.log$')
                }
            $results += @($found)
        } else {
            if ($item.LastWriteTime -gt $Since) { $results += @($item) }
        }
    }
    return $results
}

function Get-LogTail {
    param([string]$Path, [int]$Lines = 200, [int]$MaxChars = 8000)
    try {
        # Read last $Lines lines efficiently
        $tail = Get-Content -Path $Path -Tail $Lines -ErrorAction SilentlyContinue
        if (-not $tail) { return $null }
        $text = ($tail -join "`n")
        if ($text.Length -gt $MaxChars) {
            $text = "... [truncated head]`n" + $text.Substring($text.Length - $MaxChars)
        }
        return $text
    } catch { return $null }
}

function Invoke-AILogAnalysis {
    param(
        [string]$ProjectSlug,
        [object[]]$LogFiles  # array of [pscustomobject]@{Path; Tail; LastWriteTime}
    )

    $logBlocks = foreach ($lf in $LogFiles) {
        @"
----- LOG: $($lf.Path) (mtime $($lf.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))) -----
$($lf.Tail)
"@
    }
    $context = ($logBlocks -join "`n`n") -replace "`r`n", "`n"

    $systemPrompt = @"
คุณเป็น SRE ช่วยวิเคราะห์ log ของ web application ตอบเป็นภาษาไทย กระชับ มี 3 ส่วน:
1) **สถานะรวม** - 1-2 ประโยค บอกว่า log นี้บ่งชี้ว่าระบบเป็นอย่างไร (เขียว/เหลือง/แดง)
2) **Error/Warning ที่ต้องสนใจ** - bullet list สั้นๆ ของ error/warning ที่พบ พร้อมไฟล์ + เวลาที่เกิด (ถ้า log บอก) + ความเสี่ยง
3) **คำแนะนำเบื้องต้น** - ทำอะไรต่อ (เช่น restart, check config, แจ้ง dev)

ห้ามเดาเกินหลักฐาน log ถ้าเป็น log ที่ปกติไม่มี error ให้บอกตามจริง ตอบเฉพาะ markdown ไม่มี preamble
"@

    $userPrompt = @"
โปรเจกต์: $ProjectSlug
จำนวน log files: $($LogFiles.Count)

Log tails (24 ชั่วโมงล่าสุด, แต่ละไฟล์เอาบรรทัดท้าย ~200 บรรทัด):

$context
"@

    $body = @{
        model = $script:AI_MODEL
        messages = @(
            @{ role = 'system'; content = $systemPrompt }
            @{ role = 'user';   content = $userPrompt }
        )
        max_tokens = 1200
        temperature = 0.2
    } | ConvertTo-Json -Depth 6 -Compress

    $headers = @{
        Authorization = "Bearer $script:AI_KEY"
        'Content-Type' = 'application/json'
    }

    foreach ($modelTry in @($script:AI_MODEL, $script:AI_FALLBACK_MODEL)) {
        try {
            $bodyMod = $body -replace '"model":"[^"]+"', ('"model":"' + $modelTry + '"')
            $resp = Invoke-RestMethod -Uri $script:AI_ENDPOINT -Method POST -Headers $headers -Body $bodyMod -TimeoutSec 120
            $content = $resp.choices[0].message.content
            if ($content) {
                $content = [regex]::Replace($content, '(?s)<think>.*?</think>\s*', '')
                $content = $content.Trim()
                return @{ Text = $content; Model = $modelTry }
            }
        } catch {
            Write-Warning "AI call failed for $ProjectSlug with $modelTry : $($_.Exception.Message)"
        }
    }
    return $null
}

$Since = $Now.AddHours(-24)
$processedAny = $false

foreach ($entry in $projectLogPaths.GetEnumerator()) {
    $slug = $entry.Key
    $paths = $entry.Value

    if (-not $paths -or $paths.Count -eq 0) { continue }

    $found = Get-LogFilesModifiedSince -Paths $paths -Since $Since
    if (-not $found -or $found.Count -eq 0) { continue }

    $processedAny = $true
    Write-Host ("[LOGS] {0}: {1} log files modified in 24h" -f $slug, $found.Count)

    # Cap to top 5 most-recently-modified to keep token budget sane
    $topLogs = $found | Sort-Object LastWriteTime -Descending | Select-Object -First 5

    $logEntries = foreach ($f in $topLogs) {
        $tail = Get-LogTail -Path $f.FullName -Lines 200 -MaxChars 6000
        if ($tail) {
            [pscustomobject]@{ Path = $f.FullName; Tail = $tail; LastWriteTime = $f.LastWriteTime }
        }
    }
    if (-not $logEntries -or $logEntries.Count -eq 0) { continue }

    $ai = Invoke-AILogAnalysis -ProjectSlug $slug -LogFiles $logEntries

    # Build markdown
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine(("# Log analysis: {0}" -f $slug))
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine(("> Snapshot: {0}  ·  log files modified in last 24h: **{1}**" -f $DateStr, $found.Count))
    [void]$sb.AppendLine("")

    if ($ai) {
        [void]$sb.AppendLine("## AI Analysis")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine($ai.Text)
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine(("*(model: {0}, {1} log files analyzed)*" -f $ai.Model, $logEntries.Count))
        [void]$sb.AppendLine("")
    } else {
        [void]$sb.AppendLine("## AI Analysis")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("*(AI call failed - see raw log excerpts below)*")
        [void]$sb.AppendLine("")
    }

    # Files list
    [void]$sb.AppendLine("## Log files seen (24h)")
    [void]$sb.AppendLine("")
    foreach ($f in ($found | Sort-Object LastWriteTime -Descending)) {
        [void]$sb.AppendLine(("- ``{0}`` ({1:yyyy-MM-dd HH:mm}, {2:N0} bytes)" -f $f.FullName, $f.LastWriteTime, $f.Length))
    }
    [void]$sb.AppendLine("")

    # Raw excerpts (collapsed)
    [void]$sb.AppendLine("## Raw log excerpts")
    [void]$sb.AppendLine("")
    foreach ($le in $logEntries) {
        [void]$sb.AppendLine(("### ``{0}``" -f $le.Path))
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("```")
        [void]$sb.AppendLine($le.Tail)
        [void]$sb.AppendLine("```")
        [void]$sb.AppendLine("")
    }

    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine(("*Auto-generated {0} by ``server-b/refresh-server-b-logs.ps1``*" -f $DateStr))

    $outPath = Join-Path $LogsOutDir ("{0}.md" -f $slug)
    $sb.ToString() | Set-Content -Path $outPath -Encoding utf8
}

if (-not $processedAny) {
    # Still produce an index showing "no log activity"
    $idx = New-Object System.Text.StringBuilder
    [void]$idx.AppendLine("# server-b/logs - index")
    [void]$idx.AppendLine("")
    [void]$idx.AppendLine(("> Snapshot: {0}" -f $DateStr))
    [void]$idx.AppendLine("")
    [void]$idx.AppendLine("(ไม่มี project ใดที่มี log ถูกแก้ไขใน 24 ชั่วโมงล่าสุด)")
    [void]$idx.AppendLine("")
    [void]$idx.AppendLine("---")
    [void]$idx.AppendLine(("*Auto-generated {0} by ``server-b/refresh-server-b-logs.ps1``*" -f $DateStr))
    $sb.ToString() | Out-Null
    $idx.ToString() | Set-Content -Path (Join-Path $LogsOutDir 'README.md') -Encoding utf8
} else {
    # Build index of generated files
    $idx = New-Object System.Text.StringBuilder
    [void]$idx.AppendLine("# server-b/logs - index")
    [void]$idx.AppendLine("")
    [void]$idx.AppendLine(("> Snapshot: {0}" -f $DateStr))
    [void]$idx.AppendLine("")
    [void]$idx.AppendLine("Generated per-project log analysis (only projects with log activity in last 24h):")
    [void]$idx.AppendLine("")
    Get-ChildItem $LogsOutDir -Filter '*.md' -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne 'README.md' } |
        Sort-Object Name | ForEach-Object {
            [void]$idx.AppendLine(("- [{0}]({1})" -f $_.BaseName, $_.Name))
        }
    [void]$idx.AppendLine("")
    [void]$idx.AppendLine("---")
    [void]$idx.AppendLine(("*Auto-generated {0} by ``server-b/refresh-server-b-logs.ps1``*" -f $DateStr))
    $idx.ToString() | Set-Content -Path (Join-Path $LogsOutDir 'README.md') -Encoding utf8
}

# Git: commit + push (server-b/ only)
Set-Location $NotesRoot
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
    & git pull --ff-only origin main | Out-Null
    & git add server-b/ | Out-Null
    $dirty = & git status --porcelain server-b/
    if ($dirty) {
        $commitMsg = "auto: server-b logs analysis {0}" -f $Now.ToString('yyyy-MM-dd HH:mm')
        & git commit -m $commitMsg -- server-b/ | Out-Null
        & git push origin main | Out-Null
        Write-Host "[OK] Pushed: $commitMsg"
    } else {
        Write-Host "[OK] No log analysis changes"
    }
} finally {
    $ErrorActionPreference = $prevEAP
}
