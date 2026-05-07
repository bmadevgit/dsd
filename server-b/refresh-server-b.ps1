# refresh-server-b.ps1
# Regenerate C:\notes\server-b\*.md from disk scan, then commit+push (server-b/ only).
# Run daily at 02:00 via Windows Task Scheduler.

$ErrorActionPreference = 'Stop'

$NotesRoot   = 'C:\notes'
$ServerBDir  = Join-Path $NotesRoot 'server-b'
$AppsDir     = Join-Path $NotesRoot 'apps'
$Now         = Get-Date
$DateStr     = $Now.ToString('yyyy-MM-dd HH:mm')
$Today       = $Now.Date

$ExcludePattern = '\\(node_modules|\.next|\.venv|__pycache__|logs|\.git|tmp_)\\'

function Get-ProjectFiles {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return @() }
    Get-ChildItem $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch $ExcludePattern }
}

function Get-RelPath {
    param([string]$Full, [string]$Base)
    $b = $Base.TrimEnd('\') + '\'
    if ($Full.StartsWith($b)) { return $Full.Substring($b.Length).Replace('\','/') }
    return $Full
}

function Format-FileLine {
    param($f, [string]$ProjectPath)
    $rel = Get-RelPath -Full $f.FullName -Base $ProjectPath
    return "  - {0:HH:mm} ``{1}``" -f $f.LastWriteTime, $rel
}

function Get-RelatedAppsNotes {
    param([string]$AppsSubdir)
    $dir = Join-Path $AppsDir $AppsSubdir
    if (-not (Test-Path $dir)) { return $null }
    $files = Get-ChildItem $dir -Filter '*.md' -ErrorAction SilentlyContinue
    if (-not $files) { return $null }
    return $files
}

# Project definitions
$projects = @(
    [pscustomobject]@{
        Slug='lake'; Title='BMA Data Lake Portal'
        Path='C:\inetpub\wwwroot\lake'
        Url='https://172.27.15.6/lake/'
        Stack='Next.js 14 + React 18 + TypeScript + Tailwind'
        Process='PM2 (bma-lake :3000) -> IIS ARR'
        Db='CKAN PostgreSQL (read) + lake MySQL (write)'
        SourceDocs=@('RUNBOOK.md','package.json','ecosystem.config.js','web.config','next.config.js')
        AppsRef=$null
    },
    [pscustomobject]@{
        Slug='chatbot'; Title='BMA Chatbot Platform'
        Path='C:\inetpub\wwwroot\chatbot'
        Url='https://exam.bangkok.go.th/chatbot'
        Stack='PHP 8.5 (no framework) + MySQL 8'
        Process='IIS PHP'
        Db='MySQL `chatbot` (RAG via FULLTEXT ngram)'
        SourceDocs=@('CLAUDE.md','config.php','schema.sql','composer.json','web.config')
        AppsRef='bma-chatbot'
    },
    [pscustomobject]@{
        Slug='link'; Title='BMA Early-Childhood Data Hub / API Gateway'
        Path='C:\inetpub\wwwroot\link'
        Url='/link/ (redirect -> /admin/login.php)'
        Stack='PHP (custom OOP, no framework) + MySQL + Bootstrap 5'
        Process='IIS PHP'
        Db='MySQL (core_fields, agencies, child_records, audit_logs, ...)'
        SourceDocs=@('web.config','src/bootstrap.php')
        AppsRef=$null
    },
    [pscustomobject]@{
        Slug='open'; Title='OPEN - Hospital Case Status Tracker'
        Path='C:\inetpub\wwwroot\open'
        Url='https://exam.bangkok.go.th/open/'
        Stack='PHP (no framework, mysqli) + MariaDB/MySQL'
        Process='IIS PHP'
        Db='MySQL `open`'
        SourceDocs=@('PROJECT_HANDOFF.md','UAT_TEST_DOCUMENT.md','config/config.php','sql/schema.sql','web.config','install.php')
        AppsRef=$null
    },
    [pscustomobject]@{
        Slug='realtime-frontend'; Title='Realtime Thai Meeting Transcription - Frontend'
        Path='C:\inetpub\wwwroot\realtime'
        Url='http://172.27.15.6/realtime'
        Stack='Static HTML + vanilla JS (no build)'
        Process='IIS static'
        Db='-'
        SourceDocs=@('README.md','app.js','audio-utils.js','styles.css','index.html')
        AppsRef=$null
    },
    [pscustomobject]@{
        Slug='realtime-backend'; Title='Realtime Thai Transcribe - Backend'
        Path='C:\apps\realtime-thai-transcribe'
        Url='wss://172.27.15.6:9120/ws/audio'
        Stack='Python (FastAPI + uvicorn, .venv)'
        Process='uvicorn :9120 (TLS WSS)'
        Db='-'
        SourceDocs=@('README.md','.env.example','requirements.txt')
        AppsRef=$null
    },
    [pscustomobject]@{
        Slug='bma-houseid-proxy'; Title='BMA HouseID Reverse Proxy'
        Path='C:\inetpub\bma-houseid-proxy'
        Url='/bma-houseid -> https://gidapp.bangkok.go.th/bma-houseid/{R:1}'
        Stack='IIS URL Rewrite (no app code)'
        Process='IIS rewrite'
        Db='-'
        SourceDocs=@('web.config')
        AppsRef=$null
    }
)

# Snapshot common state
$iisSites = @()
try {
    Import-Module WebAdministration -ErrorAction SilentlyContinue
    $iisSites = Get-Website -ErrorAction SilentlyContinue | ForEach-Object {
        "{0} ({1}) -> ``{2}``" -f $_.Name, $_.State, $_.PhysicalPath
    }
} catch {}

$pm2Lines = @()
try {
    $env:PM2_HOME = 'C:\Users\Administrator\.pm2'
    $env:Path = 'C:\Program Files\nodejs;C:\Users\Administrator\AppData\Roaming\npm;' + $env:Path
    $pm2json = & pm2 jlist 2>$null
    if ($pm2json) {
        $apps = $pm2json | ConvertFrom-Json
        foreach ($a in $apps) {
            $uptimeMs = [int64]$Now.ToUniversalTime().Subtract([datetime]'1970-01-01').TotalMilliseconds - [int64]$a.pm2_env.pm_uptime
            $uptimeMin = [math]::Round($uptimeMs / 1000 / 60, 0)
            $pm2Lines += "{0} (id={1}, status={2}, uptime={3}m, restarts={4})" -f $a.name, $a.pm_id, $a.pm2_env.status, $uptimeMin, $a.pm2_env.restart_time
        }
    }
} catch {}

# Generate per-project .md files
foreach ($p in $projects) {
    $exists = Test-Path $p.Path
    $sb = New-Object System.Text.StringBuilder

    [void]$sb.AppendLine(("# {0}" -f $p.Title))
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine(("- **Slug:** ``{0}``" -f $p.Slug))
    [void]$sb.AppendLine(("- **Path:** ``{0}``{1}" -f $p.Path, $(if(-not $exists){' :warning: MISSING'} else {''})))
    [void]$sb.AppendLine(("- **URL:** {0}" -f $p.Url))
    [void]$sb.AppendLine(("- **Stack:** {0}" -f $p.Stack))
    [void]$sb.AppendLine(("- **Process:** {0}" -f $p.Process))
    [void]$sb.AppendLine(("- **DB:** {0}" -f $p.Db))
    [void]$sb.AppendLine("")

    if (-not $exists) {
        [void]$sb.AppendLine(":warning: Path ไม่มีอยู่บนดิสก์ของเครื่องนี้ ณ {0}" -f $DateStr)
    }
    else {
        $files = Get-ProjectFiles -Path $p.Path
        $totalCount = ($files | Measure-Object).Count
        $totalSizeMB = if ($files) { [math]::Round((($files | Measure-Object Length -Sum).Sum / 1MB), 1) } else { 0 }

        [void]$sb.AppendLine(("- **Files (excl node_modules/.next/.venv/logs/.git/tmp_):** {0:N0} files, {1} MB" -f $totalCount, $totalSizeMB))
        [void]$sb.AppendLine("")

        # ---- Activity sections ----
        [void]$sb.AppendLine("## Activity (จากการสแกน file mtime)")
        [void]$sb.AppendLine("")

        $todayFiles  = @($files | Where-Object { $_.LastWriteTime.Date -eq $Today })
        $last7Files  = @($files | Where-Object { $_.LastWriteTime -gt $Now.AddDays(-7)  -and $_.LastWriteTime.Date -ne $Today })
        $last30Files = @($files | Where-Object { $_.LastWriteTime -gt $Now.AddDays(-30) -and $_.LastWriteTime -le $Now.AddDays(-7) })

        [void]$sb.AppendLine(("### วันนี้ ({0}): {1} ไฟล์" -f $Today.ToString('yyyy-MM-dd'), $todayFiles.Count))
        [void]$sb.AppendLine("")
        if ($todayFiles.Count -gt 0) {
            $todayFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 30 | ForEach-Object {
                [void]$sb.AppendLine((Format-FileLine -f $_ -ProjectPath $p.Path))
            }
            if ($todayFiles.Count -gt 30) { [void]$sb.AppendLine("  - ... (+{0} more)" -f ($todayFiles.Count - 30)) }
            [void]$sb.AppendLine("")
        } else {
            [void]$sb.AppendLine("  (ไม่มีไฟล์แก้ไขวันนี้)")
            [void]$sb.AppendLine("")
        }

        [void]$sb.AppendLine(("### 7 วันล่าสุด (ไม่รวมวันนี้): {0} ไฟล์" -f $last7Files.Count))
        [void]$sb.AppendLine("")
        if ($last7Files.Count -gt 0) {
            $byDay = $last7Files | Group-Object { $_.LastWriteTime.ToString('yyyy-MM-dd') } | Sort-Object Name -Descending
            foreach ($g in $byDay) {
                [void]$sb.AppendLine(("- **{0}** ({1} ไฟล์):" -f $g.Name, $g.Count))
                $g.Group | Sort-Object LastWriteTime -Descending | Select-Object -First 8 | ForEach-Object {
                    $rel = Get-RelPath -Full $_.FullName -Base $p.Path
                    [void]$sb.AppendLine(("  - {0:HH:mm} ``{1}``" -f $_.LastWriteTime, $rel))
                }
                if ($g.Count -gt 8) { [void]$sb.AppendLine("  - ... (+{0} more)" -f ($g.Count - 8)) }
            }
            [void]$sb.AppendLine("")
        } else {
            [void]$sb.AppendLine("  (ไม่มีไฟล์แก้ไขในช่วง 7 วัน)")
            [void]$sb.AppendLine("")
        }

        [void]$sb.AppendLine(("### 8-30 วันก่อน: {0} ไฟล์ (ดูสรุป)" -f $last30Files.Count))
        [void]$sb.AppendLine("")
        if ($last30Files.Count -gt 0) {
            $byDay30 = $last30Files | Group-Object { $_.LastWriteTime.ToString('yyyy-MM-dd') } | Sort-Object Name -Descending
            foreach ($g in $byDay30) {
                [void]$sb.AppendLine(("- **{0}**: {1} ไฟล์" -f $g.Name, $g.Count))
            }
            [void]$sb.AppendLine("")
        }

        # Backup/recent .bak files
        $bakFiles = $files | Where-Object { $_.Name -match '\.bak$|\.\d{8}_\d{6}\.bak$|_\d{8}_\d{6}\.' }
        if ($bakFiles) {
            [void]$sb.AppendLine("## Backup files ที่พบ (บ่งบอกว่ามีการแก้ไขย้อนหลัง)")
            [void]$sb.AppendLine("")
            $bakFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 15 | ForEach-Object {
                $rel = Get-RelPath -Full $_.FullName -Base $p.Path
                [void]$sb.AppendLine(("- ``{0}`` ({1:yyyy-MM-dd HH:mm})" -f $rel, $_.LastWriteTime))
            }
            [void]$sb.AppendLine("")
        }

        # ---- Source docs ----
        [void]$sb.AppendLine("## Source docs / config (อยู่ใน project)")
        [void]$sb.AppendLine("")
        $foundDocs = 0
        foreach ($doc in $p.SourceDocs) {
            $docPath = Join-Path $p.Path $doc
            if (Test-Path $docPath) {
                $mt = (Get-Item $docPath).LastWriteTime.ToString('yyyy-MM-dd HH:mm')
                $linkPath = ($docPath -replace '\\','/')
                [void]$sb.AppendLine(("- [{0}]({1}) - last modified {2}" -f $doc, $linkPath, $mt))
                $foundDocs++
            }
        }
        if ($foundDocs -eq 0) { [void]$sb.AppendLine("  (ไม่พบ doc มาตรฐาน)") }
        [void]$sb.AppendLine("")
    }

    # ---- Vault notes (apps/<ref>/) ----
    if ($p.AppsRef) {
        $appsNotes = Get-RelatedAppsNotes -AppsSubdir $p.AppsRef
        if ($appsNotes) {
            [void]$sb.AppendLine(("## Vault notes (apps/{0}/)" -f $p.AppsRef))
            [void]$sb.AppendLine("")
            foreach ($n in $appsNotes) {
                $relNote = "../apps/{0}/{1}" -f $p.AppsRef, $n.Name
                $mt = $n.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
                [void]$sb.AppendLine(("- [{0}]({1}) - last modified {2}" -f $n.Name, $relNote, $mt))
            }
            [void]$sb.AppendLine("")
        }
    }

    # Footer
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine(("*Auto-generated {0} by ``server-b/refresh-server-b.ps1`` (disk scan)*" -f $DateStr))

    $outPath = Join-Path $ServerBDir ("{0}.md" -f $p.Slug)
    $sb.ToString() | Set-Content -Path $outPath -Encoding utf8
}

# Generate todo.md (overview/index)
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# todo - server-b")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("> Auto-generated overview of web apps on this machine (172.27.15.6)")
[void]$sb.AppendLine(("> Snapshot: **{0}**" -f $DateStr))
[void]$sb.AppendLine("> Refresh: daily at 02:00 via Task Scheduler")
[void]$sb.AppendLine("")

[void]$sb.AppendLine("## IIS Sites")
[void]$sb.AppendLine("")
if ($iisSites.Count -gt 0) {
    foreach ($s in $iisSites) { [void]$sb.AppendLine("- $s") }
} else {
    [void]$sb.AppendLine("(ดึงข้อมูล IIS ไม่ได้)")
}
[void]$sb.AppendLine("")

[void]$sb.AppendLine("## PM2 Processes")
[void]$sb.AppendLine("")
if ($pm2Lines.Count -gt 0) {
    foreach ($s in $pm2Lines) { [void]$sb.AppendLine("- $s") }
} else {
    [void]$sb.AppendLine("(ไม่พบ PM2 process หรือ pm2 ไม่ติดตั้ง)")
}
[void]$sb.AppendLine("")

[void]$sb.AppendLine("## Projects")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| # | Project | URL | Stack | Path |")
[void]$sb.AppendLine("|---|---------|-----|-------|------|")
$i = 1
foreach ($p in $projects) {
    $existsMark = if (Test-Path $p.Path) { "" } else { " :warning:" }
    [void]$sb.AppendLine(("| {0} | [{1}]({1}.md){2} | {3} | {4} | ``{5}`` |" -f $i, $p.Slug, $existsMark, $p.Url, $p.Stack, $p.Path))
    $i++
}
[void]$sb.AppendLine("")

# Activity summary across all projects (last 24h)
[void]$sb.AppendLine("## Activity (24 ชั่วโมงล่าสุด)")
[void]$sb.AppendLine("")
$totalToday = 0
foreach ($p in $projects) {
    if (-not (Test-Path $p.Path)) { continue }
    $files = Get-ProjectFiles -Path $p.Path
    $todayCount = ($files | Where-Object { $_.LastWriteTime -gt $Now.AddHours(-24) }).Count
    $totalToday += $todayCount
    if ($todayCount -gt 0) {
        [void]$sb.AppendLine(("- **{0}**: {1} ไฟล์" -f $p.Slug, $todayCount))
    }
}
if ($totalToday -eq 0) {
    [void]$sb.AppendLine("(ไม่มีไฟล์ใน project ใดถูกแก้ไขใน 24 ชั่วโมงล่าสุด)")
}
[void]$sb.AppendLine("")

[void]$sb.AppendLine("---")
[void]$sb.AppendLine(("*Auto-generated {0} by ``server-b/refresh-server-b.ps1``*" -f $DateStr))

$todoPath = Join-Path $ServerBDir 'todo.md'
$sb.ToString() | Set-Content -Path $todoPath -Encoding utf8

# Git: stage server-b/ only, commit, push.
# IMPORTANT: do NOT redirect git stderr (2>&1) in PS 5.1 — it wraps each line
# as a NativeCommandError and trips $ErrorActionPreference='Stop' on benign
# warnings (e.g., LF->CRLF). Just let stderr go to the host.
Set-Location $NotesRoot
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
    & git pull --ff-only origin main | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Warning "git pull --ff-only failed (exit $LASTEXITCODE)" }

    & git add server-b/ | Out-Null

    $dirty = & git status --porcelain server-b/
    if ($dirty) {
        $commitMsg = "auto: server-b refresh {0}" -f $Now.ToString('yyyy-MM-dd HH:mm')
        & git commit -m $commitMsg -- server-b/ | Out-Null
        & git push origin main | Out-Null
        if ($LASTEXITCODE -ne 0) { Write-Warning "git push failed (exit $LASTEXITCODE)" }
        else { Write-Host "[OK] Pushed: $commitMsg" }
    } else {
        Write-Host "[OK] No changes in server-b/"
    }
} finally {
    $ErrorActionPreference = $prevEAP
}
