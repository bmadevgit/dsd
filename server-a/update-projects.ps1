# update-projects.ps1
# Survey git history + file dates of all projects, update .md files
# Scheduled: daily 02:00 AM

$notesDir  = "C:\notes\server-a"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$bt        = [char]96  # backtick for markdown inline code

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

foreach ($name in $projects.Keys) {
    $path   = $projects[$name]
    $mdFile = Join-Path $notesDir "$name.md"

    if (-not (Test-Path $path))   { Write-Host "SKIP $name - path not found"; continue }
    if (-not (Test-Path $mdFile)) { Write-Host "SKIP $name - .md not found";  continue }

    # Recently modified files (top 8, exclude build artifacts)
    $recentFiles = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch 'node_modules' -and
            $_.FullName -notmatch '\.venv'       -and
            $_.FullName -notmatch '\\vendor\\'   -and
            $_.FullName -notmatch '\\obj\\'      -and
            $_.FullName -notmatch '\\bin\\'      -and
            $_.FullName -notmatch '__pycache__'  -and
            $_.FullName -notmatch '\\\.git\\'
        } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 8

    # Git log if project has its own .git
    $gitLines = @()
    if (Test-Path (Join-Path $path ".git")) {
        $raw = & git -C $path log --format="%ad %s" --date=short -10 2>$null
        if ($raw) { $gitLines = ($raw -split "`n") | Where-Object { $_.Trim() -ne "" } }
    }

    # Build Recent Activity section
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("")
    $lines.Add("---")
    $lines.Add("")
    $lines.Add("## Recent Activity")
    $lines.Add("")
    $lines.Add("_auto-updated $timestamp_")
    $lines.Add("")
    $lines.Add("### Files changed recently")
    $lines.Add("")

    foreach ($f in $recentFiles) {
        $rel  = $f.FullName.Substring($path.Length).TrimStart('\')
        $date = $f.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
        $lines.Add("- $($bt)$rel$($bt) $date")
    }

    if ($gitLines.Count -gt 0) {
        $lines.Add("")
        $lines.Add("### Git commits")
        $lines.Add("")
        foreach ($gl in $gitLines) {
            $lines.Add("- $gl")
        }
    }

    # Read existing .md, strip old Recent Activity section, append new
    $existing = [System.IO.File]::ReadAllText($mdFile, [System.Text.Encoding]::UTF8)
    $existing = ($existing -replace "(?s)\r?\n---\r?\n\r?\n## Recent Activity.*$", "").TrimEnd()

    $newSection = $lines -join "`n"
    $final = $existing + "`n" + $newSection + "`n"

    [System.IO.File]::WriteAllText($mdFile, $final, [System.Text.Encoding]::UTF8)
    Write-Host "Updated: $name.md"
}

# Commit and push C:\notes
Set-Location "C:\notes"
& git add server-a/

$dirty = & git status --porcelain
if ($dirty) {
    & git commit -m "auto-update: project scan $timestamp"
    & git pull origin main --rebase --autostash
    & git push origin
    Write-Host "Pushed to GitHub: $timestamp"
} else {
    Write-Host "No changes - nothing to push"
}
