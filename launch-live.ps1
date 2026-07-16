$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
Set-Location -LiteralPath $projectRoot

$serverScript = Join-Path $projectRoot 'static-server.ps1'
$cloudflared = Join-Path $projectRoot 'cloudflared.exe'
$outFile = Join-Path $projectRoot 'cloud-out.txt'
$errFile = Join-Path $projectRoot 'cloud-err.txt'

if (-not (Test-Path $serverScript)) {
    Write-Error "Missing server script: $serverScript"
    exit 1
}

if (-not (Test-Path $cloudflared)) {
    Write-Error "Missing cloudflared executable: $cloudflared"
    exit 1
}

if (Test-Path $outFile) { Remove-Item $outFile -Force }
if (Test-Path $errFile) { Remove-Item $errFile -Force }

Write-Output "Starting local server..."
$server = Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$serverScript -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 3

Write-Output "Starting Cloudflare tunnel..."
$cloud = Start-Process -FilePath $cloudflared -ArgumentList 'tunnel','--url','http://127.0.0.1:8080/' -RedirectStandardOutput $outFile -RedirectStandardError $errFile -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 8

Write-Output "Local server PID: $($server.Id)"
Write-Output "Cloudflare PID: $($cloud.Id)"
Write-Output "--- Cloudflared stdout ---"
if (Test-Path $outFile) { Get-Content $outFile -Tail 40 } else { Write-Output 'No cloudflared stdout yet.' }
Write-Output "--- Cloudflared stderr ---"
if (Test-Path $errFile) { Get-Content $errFile -Tail 40 } else { Write-Output 'No cloudflared stderr yet.' }

Write-Output "The site should now be available locally at http://127.0.0.1:8080"
Write-Output "If cloudflared succeeds it will print the public tunnel URL above."