<#
.SYNOPSIS
  Opens Firebase Console so you can enable Email/Password + Google Sign-In.
  Auth cannot be fully enabled via CLI without Identity Platform billing.
#>
$Project = "solar-clean-app"
Write-Host @"
Open Authentication → Get started, then enable:

  1) Email/Password  → Enable → Save
  2) Google          → Enable → choose support email → Save

Project: $Project
"@
Start-Process "https://console.firebase.google.com/project/$Project/authentication/providers"
Write-Host "After enabling Google, re-download google-services.json:"
Write-Host "  firebase apps:sdkconfig ANDROID 1:668072490463:android:04dfad192ab9b981f4806a --out=android/app/google-services.json --project $Project"
Write-Host "  (delete the old file first if CLI refuses to overwrite)"
