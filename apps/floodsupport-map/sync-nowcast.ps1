param(
    [string]$SourceUrl = 'https://nowcast.bangkok.go.th/api/zonal',
    [string]$OutputPath = 'C:\inetpub\wwwroot\now\nowcast-data.json',
    [string]$LogPath = 'C:\ProgramData\BMAFloodSupport\nowcast-sync.log'
)
$ErrorActionPreference = 'Stop'
$source = $SourceUrl
$output = $OutputPath
$log = $LogPath
$attemptAt = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
$download = Join-Path $env:TEMP ("nowcast-download-$([guid]::NewGuid().ToString('N')).json")

function Write-Snapshot($snapshot) {
    $temp = Join-Path (Split-Path $output) (".nowcast-$([guid]::NewGuid().ToString('N')).tmp")
    $backup = Join-Path (Split-Path $output) (".nowcast-backup-$([guid]::NewGuid().ToString('N')).tmp")
    try {
        $json = ConvertTo-Json -InputObject $snapshot -Depth 100 -Compress
        [System.IO.File]::WriteAllText($temp, $json, (New-Object System.Text.UTF8Encoding($false)))
        if (Test-Path -LiteralPath $output) {
            [System.IO.File]::Replace($temp, $output, $backup)
        } else {
            [System.IO.File]::Move($temp, $output)
        }
    } finally {
        Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue
    }
}

try {
    & C:\Windows\System32\curl.exe -f -sS --max-time 30 -o $download $source
    if ($LASTEXITCODE -ne 0) { throw "curl exit $LASTEXITCODE" }
    $payload = Get-Content -LiteralPath $download -Raw -Encoding UTF8 | ConvertFrom-Json
    $districtProperties = @($payload.districts.PSObject.Properties)
    if (-not $payload.run_id -or -not $payload.generated_at -or $districtProperties.Count -ne 50) {
        throw 'Invalid nowcast metadata or district count'
    }
    foreach ($district in $districtProperties) {
        if ($district.Value.district_i -ne $district.Name -or -not $district.Value.district_t) {
            throw "Invalid district $($district.Name)"
        }
    }
    Write-Snapshot @{ lastAttemptAt = $attemptAt; lastFetchedAt = $attemptAt; fetchFailed = $false; payload = $payload }
    Add-Content -LiteralPath $log -Value "$attemptAt INFO Nowcast run $($payload.run_id) fetched" -Encoding UTF8
    exit 0
} catch {
    Add-Content -LiteralPath $log -Value "$attemptAt ERROR $($_.Exception.Message); retaining last valid payload" -Encoding UTF8
    if (Test-Path -LiteralPath $output) {
        try {
            $old = Get-Content -LiteralPath $output -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($old.payload) {
                $old.lastAttemptAt = $attemptAt
                $old.fetchFailed = $true
                Write-Snapshot $old
            }
        } catch {
            Add-Content -LiteralPath $log -Value "$attemptAt ERROR Could not update failure flag: $($_.Exception.Message)" -Encoding UTF8
        }
    }
    exit 1
} finally {
    Remove-Item -LiteralPath $download -Force -ErrorAction SilentlyContinue
}
