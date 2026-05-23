param(
  [int]$Port = 3000,
  [string]$HostName = "127.0.0.1"
)

$ErrorActionPreference = "Stop"

function Stop-PortOwner {
  param([int]$Port)

  $connections = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
  if (-not $connections) {
    Write-Host "Port $Port is free."
    return
  }

  $processIds = $connections |
    Select-Object -ExpandProperty OwningProcess -Unique |
    Where-Object { $_ -and $_ -gt 0 }

  foreach ($processId in $processIds) {
    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
    if ($process) {
      Write-Host "Stopping process $($process.ProcessName) (PID $processId) on port $Port..."
      Stop-Process -Id $processId -Force
    }
  }

  Start-Sleep -Milliseconds 600
}

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $projectRoot

Stop-PortOwner -Port $Port

Write-Host "Starting Flutter Web on http://$HostName`:$Port ..."
flutter run -d chrome --web-hostname $HostName --web-port $Port
