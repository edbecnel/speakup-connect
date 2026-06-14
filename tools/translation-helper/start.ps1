# Start Translation Helper and print LAN + localhost URLs.
$lanIp = (
  Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
  Where-Object {
    $_.IPAddress -notlike '127.*' -and
    $_.IPAddress -match '^(192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.)'
  } |
  Select-Object -First 1 -ExpandProperty IPAddress
)

if (-not $lanIp) {
  $lanIp = (
    Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notlike '127.*' } |
    Select-Object -First 1 -ExpandProperty IPAddress
  )
}

Write-Host ''
Write-Host 'Translation Helper — open in a browser:'
if ($lanIp) {
  Write-Host "  LAN (phone, tablet, other PC): http://${lanIp}:5050"
} else {
  Write-Host '  LAN: run ipconfig and use http://<IPv4-Address>:5050'
}
Write-Host '  This PC only:                  http://localhost:5050'
Write-Host ''
Write-Host 'For LAN access, set USE_FUNCTIONS_EMULATOR = false in firebase-config.js.'
Write-Host 'Leave this window open while you use the tool (Ctrl+C to stop).'
Write-Host ''

Set-Location $PSScriptRoot
npx --yes serve -p 5050
