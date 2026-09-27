param(
    [string]$SourceUrl = 'https://bmaapi.bangkok.go.th/gw-api/fetch-and-save-data/sensor-flood-latest-record',
    [string]$OutputPath = 'C:\inetpub\wwwroot\now\road-flood-data.json',
    [string]$LogPath = 'C:\ProgramData\BMANowMap\road-flood-sync.log',
    [string]$KeyPath = 'C:\ProgramData\BMANowMap\road-flood-key.txt'
)
$ErrorActionPreference = 'Stop'
$attemptAt = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
$download = Join-Path $env:TEMP ("road-flood-$([guid]::NewGuid().ToString('N')).json")

function Write-Snapshot($snapshot) {
    $temp = Join-Path (Split-Path $OutputPath) (".road-flood-$([guid]::NewGuid().ToString('N')).tmp")
    $backup = Join-Path (Split-Path $OutputPath) (".road-flood-backup-$([guid]::NewGuid().ToString('N')).tmp")
    try {
        $json = ConvertTo-Json -InputObject $snapshot -Depth 20 -Compress
        [System.IO.File]::WriteAllText($temp, $json, (New-Object System.Text.UTF8Encoding($false)))
        if (Test-Path -LiteralPath $OutputPath) {
            [System.IO.File]::Replace($temp, $OutputPath, $backup)
        } else {
            [System.IO.File]::Move($temp, $OutputPath)
        }
    } finally {
        Remove-Item -LiteralPath $temp,$backup -Force -ErrorAction SilentlyContinue
    }
}

try {
    $key = (Get-Content -LiteralPath $KeyPath -Raw -Encoding UTF8).Trim()
    if (-not $key) { throw 'Road flood API key is empty' }
    & C:\Windows\System32\curl.exe -f -sS --max-time 35 -H "KeyId: $key" -o $download $SourceUrl
    if ($LASTEXITCODE -ne 0) { throw "curl exit $LASTEXITCODE" }
    $payload = Get-Content -LiteralPath $download -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($payload.data -isnot [array] -or $payload.data.Count -eq 0 -or
        [int]$payload.meta.total -ne $payload.data.Count) { throw 'Incomplete sensor response' }

    $sensors = @()
    $ids = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($row in $payload.data) {
        $profile = $row.sensor_profile
        $id = [string]$row.sensor_profile_id
        if (-not $id -or -not $ids.Add($id)) { throw "Duplicate or missing sensor ID $id" }
        $lat = [double]$profile.lat
        $lon = [double]$profile.long
        if ($lat -lt 13.3 -or $lat -gt 14.2 -or $lon -lt 100.1 -or $lon -gt 101.2) { throw "Invalid coordinates for sensor $id" }
        $readingTime = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$row.timestamp).UtcDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
        $value = $null
        if ([string]$row.value -match '^\d+(\.\d+)?$') {
            $value = [double]::Parse([string]$row.value, [Globalization.CultureInfo]::InvariantCulture)
        }
        $sensors += @{
            id = $id; code = [string]$row.sensor_name; name = [string]$row.name;
            road = [string]$profile.road; district = [string]$row.district;
            lat = $lat; lon = $lon; status = [string]$row.device_status;
            valueCm = $value; observedAt = $readingTime
        }
    }
    Write-Snapshot @{ lastAttemptAt = $attemptAt; lastFetchedAt = $attemptAt;
                      fetchFailed = $false; total = $sensors.Count; sensors = $sensors }
    Add-Content -LiteralPath $LogPath -Value "$attemptAt INFO $($sensors.Count) road sensors fetched" -Encoding UTF8
    exit 0
} catch {
    Add-Content -LiteralPath $LogPath -Value "$attemptAt ERROR $($_.Exception.Message); retaining last valid payload" -Encoding UTF8
    if (Test-Path -LiteralPath $OutputPath) {
        try {
            $old = Get-Content -LiteralPath $OutputPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($old.sensors) {
                $old.lastAttemptAt = $attemptAt
                $old.fetchFailed = $true
                Write-Snapshot $old
            }
        } catch {
            Add-Content -LiteralPath $LogPath -Value "$attemptAt ERROR Could not update failure flag: $($_.Exception.Message)" -Encoding UTF8
        }
    }
    exit 1
} finally {
    Remove-Item -LiteralPath $download -Force -ErrorAction SilentlyContinue
}
