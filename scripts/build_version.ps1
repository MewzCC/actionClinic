param(
  [string]$AppName = ([string]::Concat([char[]](0x884C, 0x52A8, 0x6CBB, 0x7597, 0x6240))),
  [string]$VersionName = "",
  [int]$BuildNumber = 0,
  [ValidateSet("web", "apk", "all")]
  [string]$Target = "all"
)

$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $projectRoot

if (-not $VersionName -or $BuildNumber -le 0) {
  $versionLine = Select-String -Path "pubspec.yaml" -Pattern "^version:\s*(.+)$" | Select-Object -First 1
  if (-not $versionLine) {
    throw "Cannot find version in pubspec.yaml. Pass -VersionName and -BuildNumber explicitly."
  }

  $pubspecVersion = $versionLine.Matches[0].Groups[1].Value.Trim()
  $parts = $pubspecVersion.Split("+")
  if (-not $VersionName) {
    $VersionName = $parts[0]
  }
  if ($BuildNumber -le 0) {
    $BuildNumber = if ($parts.Length -gt 1) { [int]$parts[1] } else { 1 }
  }
}

$versionTag = "v$VersionName+$BuildNumber"
$releaseName = "$AppName`_$versionTag"
$releaseRoot = Join-Path $projectRoot "releases"
$releaseDir = Join-Path $releaseRoot $releaseName

New-Item -ItemType Directory -Force -Path $releaseDir | Out-Null

Write-Host "Building $AppName production version $versionTag ..."
Write-Host "Output directory: $releaseDir"

flutter pub get

if ($Target -eq "web" -or $Target -eq "all") {
  Write-Host "Building Web release..."
  flutter build web --release --build-name $VersionName --build-number $BuildNumber

  $webOut = Join-Path $releaseDir "web"
  if (Test-Path $webOut) {
    Remove-Item -LiteralPath $webOut -Recurse -Force
  }
  Copy-Item -Path "build\web" -Destination $webOut -Recurse

  $webZip = Join-Path $releaseDir "$releaseName`_web.zip"
  if (Test-Path $webZip) {
    Remove-Item -LiteralPath $webZip -Force
  }
  Compress-Archive -Path (Join-Path $webOut "*") -DestinationPath $webZip
}

if ($Target -eq "apk" -or $Target -eq "all") {
  Write-Host "Building Android APK release..."
  flutter build apk --release --build-name $VersionName --build-number $BuildNumber

  $apkSource = "build\app\outputs\flutter-apk\app-release.apk"
  if (Test-Path $apkSource) {
    Copy-Item -Path $apkSource -Destination (Join-Path $releaseDir "$releaseName.apk") -Force
  }
}

$manifest = @"
{
  "app": "$AppName",
  "versionName": "$VersionName",
  "buildNumber": $BuildNumber,
  "versionTag": "$versionTag",
  "target": "$Target",
  "builtAt": "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")"
}
"@

Set-Content -Path (Join-Path $releaseDir "manifest.json") -Value $manifest -Encoding UTF8

Write-Host "Done: $releaseDir"
