[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$NoPush,
    [int]$WindowHours = 24
)

$ErrorActionPreference = 'Stop'

$script:Now            = Get-Date
$script:DateStamp      = $script:Now.ToString('yyyy-MM-dd')
$script:TimeStamp      = $script:Now.ToString('yyyy-MM-dd HH:mm:ss')
$script:NotesRoot      = 'C:\notes\server-a'
$script:RunLogsRoot    = Join-Path $script:NotesRoot 'run-logs'
$script:DailyRoot      = Join-Path $script:NotesRoot 'daily'
$script:DailyOutDir    = Join-Path $script:DailyRoot $script:DateStamp
$script:IndexPath      = Join-Path $script:NotesRoot 'index.md'
$script:BrainPath      = Join-Path $script:NotesRoot 'brain.json'
$script:WarningsPath   = Join-Path $script:NotesRoot 'discovery-warnings.md'
$script:UPath          = 'C:\inetpub\wwwroot\u'
$script:RunLines       = [System.Collections.Generic.List[string]]::new()
$script:DryRunMode     = $DryRun.IsPresent
$script:NoPushMode     = $NoPush.IsPresent -or $script:DryRunMode
$script:WindowStart    = (Get-Date).AddHours(-1 * [Math]::Abs($WindowHours))

$script:ScanRoots = @(
    'C:\inetpub\wwwroot',
    'C:\inetpub\apps',
    'C:\inetpub\vibe-ide'
)

$script:ExcludedDirNames = @(
    '.git', '.claude', '.obsidian', 'node_modules', 'vendor', '.venv', 'venv',
    '__pycache__', 'obj', 'bin', 'logs', 'log', 'sessions', 'uploads', 'upload',
    'cache', 'temp', 'tmp', 'history', 'backup', 'dist', 'build',
    'admin', 'api', 'assets', 'scripts', 'scriptsx', 'lib', 'libs', 'storage',
    'chatbot-data', 'vibe-ide-data', 'plan-data', 'secrets', 'custerr',
    'devicehealthattestation', 'aspnet_client', 'phpmailer', 'php_xlsxwriter',
    'tcpdf', 'ckeditor', 'plugins'
)

$script:StrongMarkers = @(
    '.git', 'composer.json', 'package.json', 'requirements.txt', 'pyproject.toml',
    '.csproj', 'appsettings.json', 'README.md', 'readme.md', 'AGENTS.md', 'CLAUDE.md'
)

$script:EntryMarkers = @(
    'index.php', 'index.html', 'app.py', 'main.py', 'server.js'
)

$script:ConfigCandidates = @(
    '.env', '.env.example', 'web.config', 'config.php', 'appsettings.json',
    'settings.json', 'database.php', 'docker-compose.yml', 'docker-compose.yaml',
    'schema.sql', 'README.md', 'AGENTS.md', 'CLAUDE.md'
)

$script:RecentExcludeRegex = '(?i)\\(node_modules|vendor|\.git|\.venv|venv|__pycache__|obj|bin|logs|sessions|uploads|upload|cache|temp|tmp|history|backup|dist|build)\\'

$script:AIBaseUrl      = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_BASE_URL', 'Machine'))
if ([string]::IsNullOrWhiteSpace($script:AIBaseUrl)) { $script:AIBaseUrl = 'http://100.99.107.27:8000/v1' }
$script:AIApiKey       = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_API_KEY', 'Machine'))
if ([string]::IsNullOrWhiteSpace($script:AIApiKey)) { $script:AIApiKey = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_API_KEY', 'User')) }
if ([string]::IsNullOrWhiteSpace($script:AIApiKey)) { $script:AIApiKey = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_API_KEY', 'Process')) }
$script:AIRequestedModel = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_MODEL', 'Machine'))
if ([string]::IsNullOrWhiteSpace($script:AIRequestedModel)) { $script:AIRequestedModel = 'Qwen/Qwen3-14B' }
$script:AIHighModel = [string]([Environment]::GetEnvironmentVariable('SERVER_A_AI_HIGH_MODEL', 'Machine'))
if ([string]::IsNullOrWhiteSpace($script:AIHighModel)) { $script:AIHighModel = 'Qwen/Qwen3.6-27B-FP8' }

$script:AIEnabled      = -not [string]::IsNullOrWhiteSpace($script:AIApiKey)
$script:AIResolvedModel = $script:AIRequestedModel
$script:AIModelCatalog = @()
$script:AIModelTry     = @()
$script:AISuccessCount = 0
$script:AIFailCount    = 0

function Write-RunLog {
    param(
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Level,
        [string]$Message
    )
    $line = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    $script:RunLines.Add($line)
    Write-Host $line
}

function Ensure-Directory {
    param([string]$Path)
    if ($script:DryRunMode) { return }
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )
    if ($script:DryRunMode) {
        Write-RunLog -Level INFO -Message ("[DRYRUN] write: {0}" -f $Path)
        return $false
    }

    $targetDir = Split-Path -Parent $Path
    Ensure-Directory -Path $targetDir

    $newText = $Content -replace "`r?`n", "`r`n"
    $oldText = $null
    if (Test-Path -LiteralPath $Path) {
        $oldText = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
        $oldText = $oldText -replace "`r?`n", "`r`n"
    }
    if ($oldText -eq $newText) {
        return $false
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $newText, $utf8NoBom)
    return $true
}

function Save-RunLogs {
    if ($script:DryRunMode) { return }
    Ensure-Directory -Path $script:RunLogsRoot
    $dailyLog = Join-Path $script:RunLogsRoot ("{0}.log" -f $script:DateStamp)
    $latestLog = Join-Path $script:RunLogsRoot 'latest.log'
    $text = ($script:RunLines -join "`n") + "`n"
    Add-Content -LiteralPath $dailyLog -Value $text -Encoding UTF8
    Set-Content -LiteralPath $latestLog -Value $text -Encoding UTF8
}

function Normalize-Path {
    param([string]$Path)
    try {
        return (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path.TrimEnd('\')
    } catch {
        return $Path.TrimEnd('\')
    }
}

function Test-SuspiciousName {
    param([string]$Name)
    if ([string]::IsNullOrWhiteSpace($Name)) { return $false }
    if ($Name.Length -gt 90) { return $true }
    if ($Name -match '[\[\]\{\}\$;`''"<>|]') { return $true }
    if ($Name -match '%[0-9a-fA-F]{2}') { return $true }
    if ($Name -match '\.\.') { return $true }
    if ($Name -match 'md5\(31337\)|assert\(|gethostbyname|nslookup|base64_decode') { return $true }
    return $false
}

function Redact-Text {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return '' }
    $x = $Text
    $x = [regex]::Replace($x, '(?im)(api[_-]?key|token|password|pass|secret|authorization)\s*[:=]\s*["'']?[^"'',\s`r`n]+', '$1=<REDACTED>')
    $x = [regex]::Replace($x, '(?i)\bghp_[A-Za-z0-9]{20,}\b', '<REDACTED_GITHUB_TOKEN>')
    $x = [regex]::Replace($x, '(?i)\bsk-[A-Za-z0-9]{20,}\b', '<REDACTED_API_KEY>')
    $x = [regex]::Replace($x, '(?i)\b[A-Za-z0-9_-]{24,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\b', '<REDACTED_JWT>')
    return $x
}

function ConvertTo-Slug {
    param([string]$Path)
    $raw = $Path.TrimEnd('\')
    if ($raw.StartsWith('C:\inetpub\wwwroot\exam\', [System.StringComparison]::OrdinalIgnoreCase)) {
        $raw = 'exam-' + $raw.Substring('C:\inetpub\wwwroot\exam\'.Length)
    } elseif ($raw.StartsWith('C:\inetpub\wwwroot\', [System.StringComparison]::OrdinalIgnoreCase)) {
        $raw = $raw.Substring('C:\inetpub\wwwroot\'.Length)
    } elseif ($raw.StartsWith('C:\inetpub\apps\', [System.StringComparison]::OrdinalIgnoreCase)) {
        $raw = 'apps-' + $raw.Substring('C:\inetpub\apps\'.Length)
    } elseif ($raw.StartsWith('C:\inetpub\', [System.StringComparison]::OrdinalIgnoreCase)) {
        $raw = $raw.Substring('C:\inetpub\'.Length)
    }

    $rawPathLike = $raw
    $raw = $raw.Replace('\', '-').Replace('/', '-')
    $slug = $raw.ToLowerInvariant() -replace '[^a-z0-9]+', '-'
    $slug = $slug.Trim('-')

    if ($rawPathLike.Contains('\')) {
        $first = ($rawPathLike -split '[\\/]' | Select-Object -First 1).ToLowerInvariant()
        $first = ($first -replace '[^a-z0-9]+', '-').Trim('-')
        if (-not [string]::IsNullOrWhiteSpace($first) -and $slug -eq $first) {
            $slug = "{0}-{1}" -f $slug, ([Math]::Abs($Path.GetHashCode()).ToString())
        }
    }

    if ([string]::IsNullOrWhiteSpace($slug)) {
        $hash = [Math]::Abs($Path.GetHashCode())
        return "proj-$hash"
    }
    return $slug
}

function Get-SeedProjects {
    $map = [ordered]@{}
    if (Test-Path -LiteralPath $script:NotesRoot) {
        Get-ChildItem -LiteralPath $script:NotesRoot -File -Filter '*.md' |
            Where-Object { $_.Name -notin @('index.md', 'todo.md', 'discovery-warnings.md') } |
            ForEach-Object {
                $slug = $_.BaseName
                try {
                    $txt = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
                    if ($txt -match '(?im)^\*\*Path:\*\*\s*`([^`]+)`') {
                        $map[$slug] = $Matches[1].Trim()
                    }
                } catch {}
            }
    }

    $legacy = [ordered]@{
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
        'u'            = 'C:\inetpub\wwwroot\u'
    }
    foreach ($k in $legacy.Keys) {
        if (-not $map.Contains($k)) { $map[$k] = $legacy[$k] }
    }
    return $map
}

function Get-Markers {
    param([string]$Dir)
    $found = [System.Collections.Generic.List[string]]::new()
    foreach ($m in ($script:StrongMarkers + $script:EntryMarkers | Select-Object -Unique)) {
        $candidate = Join-Path $Dir $m
        if (Test-Path -LiteralPath $candidate) { $null = $found.Add($m) }
    }
    return @($found)
}

function Test-IsExcludedDir {
    param([string]$Name)
    if ([string]::IsNullOrWhiteSpace($Name)) { return $true }
    $n = $Name.ToLowerInvariant()
    return $script:ExcludedDirNames -contains $n
}

function Get-DepthFromRoot {
    param([string]$Root, [string]$Path)
    $rel = $Path.Substring($Root.Length).TrimStart('\')
    if ([string]::IsNullOrWhiteSpace($rel)) { return 0 }
    return ($rel -split '\\').Count
}

function Discover-Projects {
    $warnings = [System.Collections.Generic.List[string]]::new()
    $candidates = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)

    $seed = Get-SeedProjects
    foreach ($slug in $seed.Keys) {
        $p = Normalize-Path -Path $seed[$slug]
        if (-not $candidates.ContainsKey($p)) {
            $candidates[$p] = [pscustomobject]@{
                slug    = $slug
                path    = $p
                source  = 'seed'
                markers = @()
            }
        }
    }

    foreach ($rootRaw in $script:ScanRoots) {
        if (-not (Test-Path -LiteralPath $rootRaw)) {
            $warnings.Add("root missing: $rootRaw")
            continue
        }

        $root = Normalize-Path -Path $rootRaw
        Write-RunLog -Level INFO -Message ("scan root: {0}" -f $root)

        $stack = New-Object System.Collections.Stack
        foreach ($d in (Get-ChildItem -LiteralPath $root -Directory -Force -ErrorAction SilentlyContinue)) {
            $stack.Push($d.FullName.TrimEnd('\'))
        }

        while ($stack.Count -gt 0) {
            $dir = [string]$stack.Pop()
            $name = Split-Path -Leaf $dir
            if (Test-IsExcludedDir -Name $name) { continue }

            if ($dir.StartsWith($script:UPath + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
                continue
            }

            if ($dir -ieq $script:UPath) {
                if (-not $candidates.ContainsKey($script:UPath)) {
                    $candidates[$script:UPath] = [pscustomobject]@{
                        slug    = 'u'
                        path    = $script:UPath
                        source  = 'discovery'
                        markers = @('aggregate-only')
                    }
                }
                continue
            }

            if (Test-SuspiciousName -Name $name) {
                $warnings.Add("suspicious directory name skipped: $dir")
                continue
            }

            $depth = Get-DepthFromRoot -Root $root -Path $dir
            $markers = Get-Markers -Dir $dir
            $hasStrong = @($markers | Where-Object { $_ -in $script:StrongMarkers }).Count -gt 0
            $hasEntry  = @($markers | Where-Object { $_ -in $script:EntryMarkers }).Count -gt 0

            if ($hasStrong -or ($hasEntry -and $depth -le 2)) {
                $normalized = Normalize-Path -Path $dir
                if (-not $candidates.ContainsKey($normalized)) {
                    $slug = ConvertTo-Slug -Path $normalized
                    $candidates[$normalized] = [pscustomobject]@{
                        slug    = $slug
                        path    = $normalized
                        source  = 'discovery'
                        markers = $markers
                    }
                } else {
                    $existing = $candidates[$normalized]
                    $existing.markers = @($existing.markers + $markers | Select-Object -Unique)
                }
            }

            if ($depth -lt 4) {
                foreach ($child in (Get-ChildItem -LiteralPath $dir -Directory -Force -ErrorAction SilentlyContinue)) {
                    $childName = $child.Name
                    if (Test-IsExcludedDir -Name $childName) { continue }
                    $stack.Push($child.FullName.TrimEnd('\'))
                }
            }
        }
    }

    if (Test-Path -LiteralPath $script:UPath) {
        $uChildren = Get-ChildItem -LiteralPath $script:UPath -Directory -Force -ErrorAction SilentlyContinue
        $suspicious = @($uChildren | Where-Object { Test-SuspiciousName -Name $_.Name })
        if ($suspicious.Count -gt 0) {
            $sample = $suspicious | Select-Object -First 15 | ForEach-Object { $_.Name }
            $warnings.Add(("u/ suspicious names: {0} sample={1}" -f $suspicious.Count, ($sample -join ', ')))
        }
    }

    return [pscustomobject]@{
        projects = @($candidates.Values)
        warnings = @($warnings)
    }
}

function Detect-Stack {
    param([string]$Path, [string[]]$Markers)
    $parts = [System.Collections.Generic.List[string]]::new()
    if ($Markers -contains '.csproj' -or $Markers -contains 'appsettings.json') { $null = $parts.Add('.NET') }
    if ($Markers -contains 'composer.json' -or (Test-Path -LiteralPath (Join-Path $Path 'index.php'))) { $null = $parts.Add('PHP') }
    if ($Markers -contains 'package.json' -or $Markers -contains 'server.js') { $null = $parts.Add('Node.js') }
    if ($Markers -contains 'requirements.txt' -or $Markers -contains 'pyproject.toml' -or $Markers -contains 'app.py') { $null = $parts.Add('Python') }
    if ($parts.Count -eq 0) { $null = $parts.Add('Unknown') }
    return ($parts | Select-Object -Unique) -join ' + '
}

function Get-EntryPoints {
    param([string]$Path)
    $hits = [System.Collections.Generic.List[string]]::new()
    foreach ($m in $script:EntryMarkers) {
        $f = Join-Path $Path $m
        if (Test-Path -LiteralPath $f) { $null = $hits.Add($m) }
    }
    return @($hits)
}

function Get-ConfigFiles {
    param([string]$Path)
    $hits = [System.Collections.Generic.List[string]]::new()
    foreach ($c in $script:ConfigCandidates) {
        $f = Join-Path $Path $c
        if (Test-Path -LiteralPath $f) { $null = $hits.Add($c) }
    }
    return @($hits)
}

function Get-RecentFiles {
    param(
        [string]$Path,
        [int]$Limit = 10
    )
    if (-not (Test-Path -LiteralPath $Path)) { return @() }
    if ($Path -ieq $script:UPath) {
        return @(Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First $Limit)
    }

    try {
        return @(Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch $script:RecentExcludeRegex } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First $Limit)
    } catch {
        return @()
    }
}

function Get-GitLines {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return @() }

    $localRepo = Join-Path $Path '.git'
    if (Test-Path -LiteralPath $localRepo) {
        try {
            $raw = & git -C $Path log --format="%ad %h %s" --date=short -8 2>$null
            if ($raw) { return @($raw -split "`r?`n" | Where-Object { $_.Trim() -ne '' }) }
        } catch {}
    }

    if ($Path.StartsWith('C:\inetpub', [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath 'C:\inetpub\.git')) {
        try {
            $rel = $Path.Substring('C:\inetpub'.Length).TrimStart('\').Replace('\', '/')
            if (-not [string]::IsNullOrWhiteSpace($rel)) {
                $raw = & git -C C:\inetpub log --format="%ad %h %s" --date=short -6 -- "$rel" 2>$null
                if ($raw) { return @($raw -split "`r?`n" | Where-Object { $_.Trim() -ne '' }) }
            }
        } catch {}
    }
    return @()
}

function Get-DbHints {
    param([string]$Path, [string[]]$ConfigFiles)
    $hints = [System.Collections.Generic.List[string]]::new()
    foreach ($cfg in $ConfigFiles) {
        $full = Join-Path $Path $cfg
        if (-not (Test-Path -LiteralPath $full)) { continue }
        try {
            $txt = Get-Content -LiteralPath $full -Raw -Encoding UTF8
            $txt = Redact-Text -Text $txt
            if ($txt -match '(?i)\b(mysql|mysqli|pdo)\b') { $null = $hints.Add('mysql/pdo') }
            if ($txt -match '(?i)\bpostgres|pgsql\b') { $null = $hints.Add('postgres') }
            if ($txt -match '(?i)\bsqlite\b') { $null = $hints.Add('sqlite') }
            if ($txt -match '(?i)\bsqlserver|mssql\b') { $null = $hints.Add('sqlserver') }
        } catch {}
    }
    if ($hints.Count -eq 0) { return @() }
    return @($hints | Select-Object -Unique)
}

function Resolve-AIModel {
    if (-not $script:AIEnabled) {
        Write-RunLog -Level WARN -Message 'AI disabled: SERVER_A_AI_API_KEY not found (Machine/User/Process)'
        $script:AIModelTry = @()
        return
    }

    $headers = @{ Authorization = "Bearer $($script:AIApiKey)" }
    try {
        $resp = Invoke-RestMethod -Uri ($script:AIBaseUrl.TrimEnd('/') + '/models') -Method Get -Headers $headers -TimeoutSec 12
        if ($resp -and $resp.data) {
            $script:AIModelCatalog = @($resp.data | ForEach-Object { $_.id } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        }
    } catch {
        Write-RunLog -Level WARN -Message ("AI model catalog unavailable: {0}" -f $_.Exception.Message)
    }

    if ($script:AIModelCatalog.Count -gt 0) {
        if ($script:AIModelCatalog -contains $script:AIRequestedModel) {
            $script:AIResolvedModel = $script:AIRequestedModel
        } elseif ($script:AIModelCatalog -contains $script:AIHighModel) {
            $script:AIResolvedModel = $script:AIHighModel
        } else {
            $qwen = $script:AIModelCatalog | Where-Object { $_ -match '^Qwen/' } | Select-Object -First 1
            if ($qwen) { $script:AIResolvedModel = $qwen }
        }
    }

    $tryList = [System.Collections.Generic.List[string]]::new()
    foreach ($m in @($script:AIRequestedModel, $script:AIHighModel, $script:AIResolvedModel)) {
        if (-not [string]::IsNullOrWhiteSpace($m) -and -not $tryList.Contains($m)) { $null = $tryList.Add($m) }
    }
    $script:AIModelTry = @($tryList)

    Write-RunLog -Level INFO -Message ("AI model requested={0} resolved={1}" -f $script:AIRequestedModel, $script:AIResolvedModel)
}

function Invoke-AISummary {
    param(
        [string]$ProjectSlug,
        [string]$ProjectPath,
        [string]$Stack,
        [string[]]$EntryPoints,
        [string[]]$ConfigFiles,
        [string[]]$GitLines,
        [object[]]$RecentFiles,
        [string]$PreviousNoteSnippet
    )
    if (-not $script:AIEnabled) { return '' }
    if ($RecentFiles.Count -eq 0) { return '' }
    if ($script:AIModelTry.Count -eq 0) { return '' }

    $recentText = ($RecentFiles | ForEach-Object {
        $relative = if ($_.PSObject.Properties['FullName']) { $_.FullName.Substring($ProjectPath.Length).TrimStart('\') } else { $_.Name }
        "{0:yyyy-MM-dd HH:mm} - {1}" -f $_.LastWriteTime, $relative
    }) -join "`n"

    $gitText = if ($GitLines.Count -gt 0) { ($GitLines | Select-Object -First 8) -join "`n" } else { '(no git lines)' }
    $entryText = if ($EntryPoints.Count -gt 0) { $EntryPoints -join ', ' } else { '(none)' }
    $cfgText = if ($ConfigFiles.Count -gt 0) { $ConfigFiles -join ', ' } else { '(none)' }

    $sys = @'
You are a senior software engineer creating reusable dev memory.
Write in Thai language, concise and practical.
Return markdown with exactly 3 sections:
1) **Summary**
2) **Risks**
3) **Next Step**
Each section must have 2-4 bullets.
Do not include secrets or credentials.
'@

    $user = @"
Project: $ProjectSlug
Path: $ProjectPath
Stack: $Stack
Entry points: $entryText
Config files: $cfgText

Recent files (window $WindowHours hours):
$recentText

Recent git lines:
$gitText

Previous note context:
$PreviousNoteSnippet
"@
    $user = Redact-Text -Text $user

    $headers = @{
        Authorization  = "Bearer $($script:AIApiKey)"
        'Content-Type' = 'application/json; charset=utf-8'
    }

    foreach ($modelTry in $script:AIModelTry) {
        try {
            $bodyObj = @{
                model                = $modelTry
                messages             = @(
                    @{ role = 'system'; content = $sys },
                    @{ role = 'user'; content = $user }
                )
                temperature          = 0.2
                max_tokens           = 500
                chat_template_kwargs = @{ enable_thinking = $false }
            }
            $json = $bodyObj | ConvertTo-Json -Depth 8 -Compress
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
            $resp = Invoke-WebRequest -Uri ($script:AIBaseUrl.TrimEnd('/') + '/chat/completions') -Method Post -Headers $headers -Body $bytes -UseBasicParsing -TimeoutSec 100
            $respBytes = $resp.RawContentStream.ToArray()
            $respText = [System.Text.Encoding]::UTF8.GetString($respBytes)
            $obj = $respText | ConvertFrom-Json
            $content = [string]$obj.choices[0].message.content
            if (-not [string]::IsNullOrWhiteSpace($content)) {
                $content = [regex]::Replace($content, '(?s)<think>.*?</think>\s*', '')
                $content = Redact-Text -Text $content
                $script:AISuccessCount++
                return ($content.Trim() + "`n`n*(model: $modelTry)*")
            }
        } catch {
            Write-RunLog -Level WARN -Message ("AI summary failed for {0} on model {1}: {2}" -f $ProjectSlug, $modelTry, $_.Exception.Message)
        }
    }

    $script:AIFailCount++
    return '(AI unavailable)'
}

function Get-NoteCore {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return '' }
    try {
        $txt = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
        $txt = [regex]::Replace($txt, '(?s)<!-- AUTO_SECTION_START -->.*?<!-- AUTO_SECTION_END -->', '')
        $txt = [regex]::Replace($txt, '(?s)\r?\n---\r?\n\r?\n## Recent Activity.*$', '')
        $txt = Redact-Text -Text $txt
        if ($txt.Length -gt 1800) { return $txt.Substring(0, 1800) }
        return $txt
    } catch {
        return ''
    }
}

function Build-AutoSection {
    param([pscustomobject]$Project)
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('## AI Dev Memory')
    $lines.Add('')
    $lines.Add(('_auto-updated {0}_' -f $script:TimeStamp))
    $lines.Add('')
    $lines.Add('### Snapshot')
    $lines.Add('')
    $lines.Add(('- Path: `{0}`' -f $Project.path))
    $lines.Add(('- Stack: {0}' -f $Project.stack))
    $lines.Add(('- Entry points: {0}' -f $(if ($Project.entrypoints.Count -gt 0) { ($Project.entrypoints -join ', ') } else { '(none)' })))
    $lines.Add(('- Config files: {0}' -f $(if ($Project.config_files.Count -gt 0) { ($Project.config_files -join ', ') } else { '(none)' })))
    $lines.Add(('- DB hints: {0}' -f $(if ($Project.db_hints.Count -gt 0) { ($Project.db_hints -join ', ') } else { '(none)' })))
    $lines.Add('')

    if (-not [string]::IsNullOrWhiteSpace($Project.ai_summary)) {
        $lines.Add(('### AI Summary ({0}h)' -f $WindowHours))
        $lines.Add('')
        $lines.Add($Project.ai_summary)
        $lines.Add('')
    }

    $lines.Add('### Recent Files')
    $lines.Add('')
    if ($Project.recent_files.Count -gt 0) {
        foreach ($rf in $Project.recent_files) {
            $lines.Add(('- `{0}` {1}' -f $rf.rel, $rf.time))
        }
    } else {
        $lines.Add('- (no recent files found)')
    }
    $lines.Add('')

    $lines.Add('### Git Commits')
    $lines.Add('')
    if ($Project.git_commits.Count -gt 0) {
        foreach ($gl in $Project.git_commits) { $lines.Add("- $gl") }
    } else {
        $lines.Add('- (no git commits found)')
    }
    $lines.Add('')

    if ($Project.risks.Count -gt 0) {
        $lines.Add('### Risks')
        $lines.Add('')
        foreach ($r in $Project.risks) { $lines.Add("- $r") }
        $lines.Add('')
    }

    return ($lines -join "`n").TrimEnd()
}

function Upsert-ProjectNote {
    param([pscustomobject]$Project)
    $notePath = Join-Path $script:NotesRoot ("{0}.md" -f $Project.slug)
    $existing = ''
    if (Test-Path -LiteralPath $notePath) {
        $existing = Get-Content -LiteralPath $notePath -Raw -Encoding UTF8
    } else {
        $existing = @"
# $($Project.slug)

**Path:** `$($Project.path)`
**Tool:** Claude Code / Codex

"@
    }

    $auto = Build-AutoSection -Project $Project
    $wrapped = "<!-- AUTO_SECTION_START -->`n`n$auto`n`n<!-- AUTO_SECTION_END -->"

    if ($existing -match '(?s)<!-- AUTO_SECTION_START -->.*?<!-- AUTO_SECTION_END -->') {
        $updated = [regex]::Replace($existing, '(?s)<!-- AUTO_SECTION_START -->.*?<!-- AUTO_SECTION_END -->', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $wrapped })
    } elseif ($existing -match '(?s)\r?\n---\r?\n\r?\n## Recent Activity.*$') {
        $base = [regex]::Replace($existing, '(?s)\r?\n---\r?\n\r?\n## Recent Activity.*$', '').TrimEnd()
        $updated = $base + "`n`n" + $wrapped + "`n"
    } else {
        $updated = $existing.TrimEnd() + "`n`n" + $wrapped + "`n"
    }

    return (Write-Utf8File -Path $notePath -Content $updated)
}

function Build-IndexMarkdown {
    param([pscustomobject[]]$Projects, [string[]]$Warnings)
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('# server-a dev brain')
    $lines.Add('')
    $lines.Add('Source of truth for Codex and Claude Code on this server.')
    $lines.Add('')
    $lines.Add(('- Updated: **{0}**' -f $script:TimeStamp))
    $lines.Add(('- Window: last **{0} hours**' -f $WindowHours))
    $lines.Add(('- Projects: **{0}**' -f $Projects.Count))
    $lines.Add(('- AI: **{0}** (requested `{1}`, resolved `{2}`)' -f $(if ($script:AIEnabled) { 'enabled' } else { 'disabled' }), $script:AIRequestedModel, $script:AIResolvedModel))
    $lines.Add(('- Run logs: `{0}`' -f (Join-Path $script:RunLogsRoot 'latest.log')))
    $lines.Add('')
    $lines.Add('## Projects')
    $lines.Add('')
    $lines.Add('| Project | Path | Stack | Recent |')
    $lines.Add('|---|---|---|---|')
    foreach ($p in ($Projects | Sort-Object slug)) {
        $recent = if ($p.recent_files.Count -gt 0) { $p.recent_files[0].time } else { '-' }
        $lines.Add(('| [{0}]({0}.md) | `{1}` | {2} | {3} |' -f $p.slug, $p.path, $p.stack, $recent))
    }
    if ($Warnings.Count -gt 0) {
        $lines.Add('')
        $lines.Add('## Discovery warnings')
        $lines.Add('')
        foreach ($w in $Warnings | Select-Object -First 40) {
            $lines.Add("- $w")
        }
    }
    $lines.Add('')
    $lines.Add('---')
    $lines.Add('')
    $lines.Add(('*Auto-generated by `server-a/update-projects.ps1` at {0}*' -f $script:TimeStamp))
    return ($lines -join "`n") + "`n"
}

function Build-DailyReportMarkdown {
    param([pscustomobject[]]$Projects, [string[]]$Warnings)
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# Brain Report - $($script:DateStamp)")
    $lines.Add('')
    $lines.Add(("- Generated: {0}" -f $script:TimeStamp))
    $lines.Add(("- Projects: {0}" -f $Projects.Count))
    $lines.Add(("- AI success/fail: {0}/{1}" -f $script:AISuccessCount, $script:AIFailCount))
    $lines.Add('')
    $lines.Add('## Project Activity')
    $lines.Add('')
    foreach ($p in ($Projects | Sort-Object slug)) {
        $lines.Add(("### {0}" -f $p.slug))
        $lines.Add(('- Path: `{0}`' -f $p.path))
        $lines.Add(("- Stack: {0}" -f $p.stack))
        $lines.Add(("- Recent files: {0}" -f $p.recent_files.Count))
        if ($p.ai_summary) {
            $lines.Add('- AI summary: available')
        } else {
            $lines.Add('- AI summary: none')
        }
        $lines.Add('')
    }
    if ($Warnings.Count -gt 0) {
        $lines.Add('## Warnings')
        $lines.Add('')
        foreach ($w in $Warnings | Select-Object -First 50) { $lines.Add("- $w") }
        $lines.Add('')
    }
    return ($lines -join "`n") + "`n"
}

function Write-DiscoveryWarnings {
    param([string[]]$Warnings)
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('# discovery warnings')
    $lines.Add('')
    $lines.Add(('- Updated: {0}' -f $script:TimeStamp))
    $lines.Add(('- Count: {0}' -f $Warnings.Count))
    $lines.Add('')
    if ($Warnings.Count -eq 0) {
        $lines.Add('- none')
    } else {
        foreach ($w in $Warnings) { $lines.Add("- $w") }
    }
    $lines.Add('')
    $content = ($lines -join "`n") + "`n"
    $null = Write-Utf8File -Path $script:WarningsPath -Content $content
}

function Write-BrainArtifacts {
    param([pscustomobject[]]$Projects, [string[]]$Warnings)

    $brainObj = [ordered]@{
        generated_at     = $script:TimeStamp
        date             = $script:DateStamp
        window_hours     = $WindowHours
        scan_roots       = $script:ScanRoots
        ai               = [ordered]@{
            enabled          = $script:AIEnabled
            requested_model  = $script:AIRequestedModel
            resolved_model   = $script:AIResolvedModel
            model_catalog    = $script:AIModelCatalog
            summaries_ok     = $script:AISuccessCount
            summaries_failed = $script:AIFailCount
        }
        stats            = [ordered]@{
            project_count  = $Projects.Count
            warnings_count = $Warnings.Count
        }
        projects         = $Projects
    }

    $brainJson = ($brainObj | ConvertTo-Json -Depth 12)
    $null = Write-Utf8File -Path $script:BrainPath -Content ($brainJson + "`n")

    $indexMd = Build-IndexMarkdown -Projects $Projects -Warnings $Warnings
    $null = Write-Utf8File -Path $script:IndexPath -Content $indexMd

    Write-DiscoveryWarnings -Warnings $Warnings

    $dailySummaryObj = [ordered]@{
        date             = $script:DateStamp
        generated_at     = $script:TimeStamp
        projects         = $Projects.Count
        warnings         = $Warnings.Count
        ai_enabled       = $script:AIEnabled
        requested_model  = $script:AIRequestedModel
        resolved_model   = $script:AIResolvedModel
        ai_success       = $script:AISuccessCount
        ai_failed        = $script:AIFailCount
        index_md         = $script:IndexPath
        brain_json       = $script:BrainPath
        run_log          = Join-Path $script:RunLogsRoot 'latest.log'
    }
    $dailySummaryJson = ($dailySummaryObj | ConvertTo-Json -Depth 8)

    Ensure-Directory -Path $script:DailyOutDir
    $null = Write-Utf8File -Path (Join-Path $script:DailyOutDir 'brain-summary.json') -Content ($dailySummaryJson + "`n")
    $dailyReport = Build-DailyReportMarkdown -Projects $Projects -Warnings $Warnings
    $null = Write-Utf8File -Path (Join-Path $script:DailyOutDir 'brain-report.md') -Content $dailyReport
}

function Invoke-GitPush {
    if ($script:NoPushMode) {
        Write-RunLog -Level INFO -Message 'NoPush enabled: skip git commit/push'
        return
    }
    if (-not (Test-Path -LiteralPath 'C:\notes\.git')) {
        Write-RunLog -Level WARN -Message 'git repo not found at C:\notes'
        return
    }

    Set-Location 'C:\notes'
    & git pull --rebase --autostash origin main | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-RunLog -Level WARN -Message ("git pull failed with exit code {0}; skip push" -f $LASTEXITCODE)
        return
    }

    & git add server-a/ | Out-Null
    $dirty = & git status --porcelain server-a/
    if (-not $dirty) {
        Write-RunLog -Level INFO -Message 'No staged changes in server-a/'
        return
    }

    $msg = "auto-update: server-a brain $($script:Now.ToString('yyyy-MM-dd HH:mm'))"
    & git commit -m $msg -- server-a/ | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-RunLog -Level WARN -Message ("git commit failed with exit code {0}" -f $LASTEXITCODE)
        return
    }
    & git push origin HEAD:main | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-RunLog -Level WARN -Message ("git push failed with exit code {0}" -f $LASTEXITCODE)
    } else {
        Write-RunLog -Level INFO -Message ("Pushed to origin/main: {0}" -f $msg)
    }
}

Write-RunLog -Level INFO -Message "update-projects started"
Write-RunLog -Level INFO -Message ("mode: DryRun={0}, NoPush={1}, WindowHours={2}" -f $script:DryRunMode, $script:NoPushMode, $WindowHours)

Resolve-AIModel

$discover = Discover-Projects
$warnings = @($discover.warnings)
$projectList = @($discover.projects)

$slugSeen = @{}
foreach ($proj in ($projectList | Sort-Object path -Unique)) {
    $baseSlug = [string]$proj.slug
    if ([string]::IsNullOrWhiteSpace($baseSlug)) {
        $baseSlug = ConvertTo-Slug -Path $proj.path
    }
    $candidate = $baseSlug
    $suffix = 1
    while ($slugSeen.ContainsKey($candidate.ToLowerInvariant())) {
        $candidate = "{0}-{1}" -f $baseSlug, $suffix
        $suffix++
    }
    $slugSeen[$candidate.ToLowerInvariant()] = $true
    Add-Member -InputObject $proj -NotePropertyName unique_slug -NotePropertyValue $candidate -Force
}

Write-RunLog -Level INFO -Message ("discovered projects: {0}" -f $projectList.Count)
if ($warnings.Count -gt 0) {
    Write-RunLog -Level WARN -Message ("discovery warnings: {0}" -f $warnings.Count)
}

$results = [System.Collections.Generic.List[pscustomobject]]::new()
$updatedCount = 0

foreach ($proj in ($projectList | Sort-Object unique_slug, path -Unique)) {
    $path = $proj.path
    $slug = [string]$proj.unique_slug
    $exists = Test-Path -LiteralPath $path
    $markers = if ($proj.markers) { @($proj.markers | Select-Object -Unique) } else { Get-Markers -Dir $path }
    if ($path -ieq $script:UPath) { $markers = @('aggregate-only') }

    $stack = if ($exists) { Detect-Stack -Path $path -Markers $markers } else { 'missing-path' }
    $entryPoints = if ($exists) { Get-EntryPoints -Path $path } else { @() }
    $configFiles = if ($exists) { Get-ConfigFiles -Path $path } else { @() }
    $dbHints = if ($exists) { Get-DbHints -Path $path -ConfigFiles $configFiles } else { @() }
    $recentRaw = if ($exists) { Get-RecentFiles -Path $path -Limit 10 } else { @() }
    $recentForAi = @($recentRaw | Where-Object { $_.LastWriteTime -gt $script:WindowStart })
    $gitLines = if ($exists) { Get-GitLines -Path $path } else { @() }
    $notePath = Join-Path $script:NotesRoot ("{0}.md" -f $slug)
    $prevCore = Get-NoteCore -Path $notePath

    $risks = [System.Collections.Generic.List[string]]::new()
    if (-not $exists) { $risks.Add('project path missing') }
    if ($path -ieq $script:UPath) { $risks.Add('u path is aggregate mode only (no subfolder scan)') }
    if ($recentRaw.Count -gt 0) {
        $futureTime = @($recentRaw | Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(12) })
        if ($futureTime.Count -gt 0) { $risks.Add('future timestamps detected in recent files') }
    }

    $aiSummary = ''
    if ($exists -and $path -ne $script:UPath -and $recentForAi.Count -gt 0) {
        $aiSummary = Invoke-AISummary -ProjectSlug $slug -ProjectPath $path -Stack $stack -EntryPoints $entryPoints -ConfigFiles $configFiles -GitLines $gitLines -RecentFiles $recentForAi -PreviousNoteSnippet $prevCore
    }

    $recentList = [System.Collections.Generic.List[pscustomobject]]::new()
    foreach ($rf in $recentRaw) {
        $rel = if ($path -ieq $script:UPath) { $rf.Name } else { $rf.FullName.Substring($path.Length).TrimStart('\') }
        $rel = Redact-Text -Text $rel
        $recentList.Add([pscustomobject]@{
            rel  = $rel
            time = $rf.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
        })
    }

    $projectObj = [pscustomobject]@{
        slug         = $slug
        path         = $path
        exists       = $exists
        source       = $proj.source
        markers      = @($markers | Select-Object -Unique)
        stack        = $stack
        entrypoints  = @($entryPoints)
        config_files = @($configFiles)
        db_hints     = @($dbHints)
        recent_files = @($recentList)
        git_commits  = @($gitLines)
        ai_summary   = $aiSummary
        risks        = @($risks)
    }

    $results.Add($projectObj)
    if (Upsert-ProjectNote -Project $projectObj) { $updatedCount++ }
}

Write-RunLog -Level INFO -Message ("project notes updated: {0}" -f $updatedCount)

Write-BrainArtifacts -Projects @($results) -Warnings $warnings
Invoke-GitPush
Save-RunLogs

Write-RunLog -Level INFO -Message 'update-projects finished'
