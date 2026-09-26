#!/bin/bash
set -e

VERSION="1.1.1"
OUTPUT_DIR="build/app/outputs/flutter-apk"

echo "=== 1. BERSIHKAN CACHE & AMBIL DEPENDENSI ==="
flutter clean
flutter pub get

echo "=== 2. KOMPILASI SPLIT ABI (KENTANG & MEDIUM) ==="
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols --split-per-abi

echo "=== MENGGANTI NAMA BERKAS SPLIT APK ==="
mv "$OUTPUT_DIR/app-armeabi-v7a-release.apk" "$OUTPUT_DIR/Kirana-Tanjung-Kentang-v$VERSION.apk"
mv "$OUTPUT_DIR/app-arm64-v8a-release.apk" "$OUTPUT_DIR/Kirana-Tanjung-Medium-v$VERSION.apk"

echo "=== 3. KOMPILASI UNIVERSAL FAT APK (SUPER) ==="
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

echo "=== MENGGANTI NAMA BERKAS UNIVERSAL APK ==="
mv "$OUTPUT_DIR/app-release.apk" "$OUTPUT_DIR/Kirana-Tanjung-Super-Universal-v$VERSION.apk"

echo "=== PROSES BUILD SELESAI DENGAN SUKSES ==="
ls -lh "$OUTPUT_DIR"/Kirana-Tanjung-*.apk