$ErrorActionPreference = "Stop"
$Version = "1.1.1"
$OutputDir = "build\app\outputs\flutter-apk"

Write-Host "=== 1. BERSIHKAN CACHE & AMBIL DEPENDENSI ===" -ForegroundColor Cyan
flutter clean
flutter pub get

Write-Host "=== 2. KOMPILASI SPLIT ABI (KENTANG & MEDIUM) ===" -ForegroundColor Cyan
flutter build apk --release --obfuscate --split-debug-info=build\app\outputs\symbols --split-per-abi

Write-Host "=== MENGGANTI NAMA BERKAS SPLIT APK ===" -ForegroundColor Yellow
Move-Item -Path "$OutputDir\app-armeabi-v7a-release.apk" -Destination "$OutputDir\Kirana-Tanjung-Kentang-v$Version.apk" -Force
Move-Item -Path "$OutputDir\app-arm64-v8a-release.apk" -Destination "$OutputDir\Kirana-Tanjung-Medium-v$Version.apk" -Force

Write-Host "=== 3. KOMPILASI UNIVERSAL FAT APK (SUPER) ===" -ForegroundColor Cyan
flutter build apk --release --obfuscate --split-debug-info=build\app\outputs\symbols

Write-Host "=== MENGGANTI NAMA BERKAS UNIVERSAL APK ===" -ForegroundColor Yellow
Move-Item -Path "$OutputDir\app-release.apk" -Destination "$OutputDir\Kirana-Tanjung-Super-Universal-v$Version.apk" -Force

Write-Host "=== PROSES BUILD SELESAI DENGAN SUKSES ===" -ForegroundColor Green
Get-ChildItem -Path "$OutputDir\Kirana-Tanjung-*.apk" | Select-Object Name, Length