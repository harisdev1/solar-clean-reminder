<#
.SYNOPSIS
  Build/install for a physical Android phone (USB). Uses real Firebase (no Android emulator).
#>
$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

Write-Host "==> Devices:" -ForegroundColor Cyan
flutter devices

Write-Host "==> flutter run (production Firebase, USE_FIREBASE_EMULATOR=false)" -ForegroundColor Cyan
flutter run --dart-define=USE_FIREBASE_EMULATOR=false
