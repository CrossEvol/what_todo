# A PowerShell script for building and renaming a Flutter APK file.
# It reads the version information from pubspec.yaml and appends it to the APK filename.

# Define the base name of the APK file. You can modify this as needed.
$appName = "what-todo"

# --- Step 1: Build the APK file ---
# Use the --release flag to build a production-ready APK.
Write-Host "--- Building Flutter APK ---" -ForegroundColor Green
fvm flutter build apk --release

# Check if the build was successful
if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter build failed. Please check the errors." -ForegroundColor Red
    exit
}

# --- Step 2: Read the version number from pubspec.yaml ---
$pubspecPath = "pubspec.yaml"
Write-Host "--- Reading version information... ---" -ForegroundColor Green

# Check if pubspec.yaml file exists
if (-not (Test-Path $pubspecPath)) {
    Write-Host "Could not find pubspec.yaml file! Please ensure you are running this script from the project root directory." -ForegroundColor Red
    exit
}

# Use a regular expression to extract the version string from the file.
# The new regex can match build numbers that include digits, letters, dots, and hyphens.
$versionLine = Get-Content $pubspecPath | Select-String -Pattern "^version:"
if (-not $versionLine) {
    Write-Host "Could not find version information in pubspec.yaml." -ForegroundColor Red
    exit
}

# Extract the version number (e.g., "1.5.2") and build info (e.g., "fix-notification.1")
$versionMatch = [regex]::Match($versionLine.ToString(), "version:\s*([\d\.]+)\+([a-zA-Z0-9\.\-]+)")
if ($versionMatch.Success) {
    $version = $versionMatch.Groups[1].Value
    $buildInfo = $versionMatch.Groups[2].Value
    Write-Host "Found version: $version, Build info: $buildInfo" -ForegroundColor Yellow
} else {
    Write-Host "Failed to parse version information. Please check the 'version' format in pubspec.yaml." -ForegroundColor Red
    exit
}

# --- Step 3: Rename the APK file ---
# Define the path to the original APK file
$originalApkPath = "build\app\outputs\flutter-apk\app-release.apk"

# Check if the original file exists
if (-not (Test-Path $originalApkPath)) {
    Write-Host "Could not find the generated APK file: $originalApkPath. The build may have failed." -ForegroundColor Red
    exit
}

# Define the new APK filename with the format AppName-vVersionNumber-BuildInfo.apk
$newApkName = "$appName-v$version-$buildInfo.apk"
$newApkPath = Join-Path (Split-Path $originalApkPath) $newApkName

# Rename the file
Rename-Item -Path $originalApkPath -NewName $newApkName -Force

Write-Host "--- APK renamed successfully! ---" -ForegroundColor Green
Write-Host "New file path: $newApkPath" -ForegroundColor Cyan
