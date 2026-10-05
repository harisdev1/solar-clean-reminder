<#
.SYNOPSIS
  Start free local Firebase Auth + Firestore emulators, then flutter run.
  No Console. No billing. Email + Google (emulator) work out of the box.
#>
$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

Write-Host "==> Starting Auth + Firestore emulators (free, local)" -ForegroundColor Cyan
$emu = Start-Process -FilePath "firebase" -ArgumentList @(
  "emulators:start", "--only", "auth,firestore", "--project", "solar-clean-app"
) -PassThru -WindowStyle Minimized

function Wait-Port([int]$Port, [int]$Seconds = 90) {
  $deadline = (Get-Date).AddSeconds($Seconds)
  while ((Get-Date) -lt $deadline) {
    try {
      $c = New-Object System.Net.Sockets.TcpClient
      $c.Connect("127.0.0.1", $Port)
      $c.Close()
      return $true
    } catch {
      Start-Sleep -Seconds 2
    }
  }
  return $false
}

try {
  if (-not (Wait-Port 9099)) { throw "Auth emulator port 9099 not up" }
  if (-not (Wait-Port 8080)) { throw "Firestore emulator port 8080 not up" }
  Write-Host "==> Emulators ready" -ForegroundColor Green
  Write-Host "==> flutter run (USE_FIREBASE_EMULATOR=true)" -ForegroundColor Cyan
  flutter run --dart-define=USE_FIREBASE_EMULATOR=true
} finally {
  if ($emu -and -not $emu.HasExited) {
    Write-Host "==> Stopping emulators" -ForegroundColor Yellow
    Stop-Process -Id $emu.Id -Force -ErrorAction SilentlyContinue
  }
}
