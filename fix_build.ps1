$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

Write-Host "Setting JAVA_HOME to $env:JAVA_HOME"

if (Test-Path ".\android\gradlew.bat") {
    Write-Host "Stopping existing Gradle daemons..."
    .\android\gradlew.bat --stop
}

Write-Host "Killing any lingering Java processes..."
Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

if (Test-Path ".\android\.gradle") {
    Write-Host "Deleting android/.gradle cache..."
    Remove-Item -Path ".\android\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Running Flutter Clean..."
flutter clean

Write-Host "Running Flutter Pub Get..."
flutter pub get

Write-Host "Building Android APK (Release)..."
flutter build apk --release

Write-Host "Build process completed. Check for any errors above."
# Read-Host -Prompt "Press Enter to exit"
