$ErrorActionPreference = 'Stop'
$log = 'C:\ProgramData\BMAFloodSupport\scheduler-wrapper.log'
$python = 'C:\inetpub\apps\floodsupport-map\.venv\Scripts\python.exe'
$script = 'C:\inetpub\apps\floodsupport-map\bootstrap.py'

Add-Content -LiteralPath $log -Value "$(Get-Date -Format o) START"
& $python $script
$code = $LASTEXITCODE
Add-Content -LiteralPath $log -Value "$(Get-Date -Format o) EXIT $code"
exit $code
