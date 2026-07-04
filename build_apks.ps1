Write-Host "Membangun APK versi DEV..." -ForegroundColor Cyan
flutter build apk --release --dart-define=FLAVOR=dev --dart-define=APP_NAME="DEV - Sandi" --dart-define=DEV_NAME="Sandi Pranata"
if ($LASTEXITCODE -ne 0) { Write-Host "Build DEV gagal" -ForegroundColor Red; exit }

# Buat folder khusus
New-Item -ItemType Directory -Force -Path "Release_APKs" | Out-Null
Copy-Item "build\app\outputs\flutter-apk\app-release.apk" -Destination "Release_APKs\DigiNews_DEV.apk" -Force

Write-Host "Membangun APK versi PROD..." -ForegroundColor Cyan
flutter build apk --release --dart-define=FLAVOR=prod --dart-define=APP_NAME="UTD - 20123067" --dart-define=PROD_NIM=20123067
if ($LASTEXITCODE -ne 0) { Write-Host "Build PROD gagal" -ForegroundColor Red; exit }

Copy-Item "build\app\outputs\flutter-apk\app-release.apk" -Destination "Release_APKs\DigiNews_PROD.apk" -Force

Write-Host "✅ Selesai! Kedua APK telah dibuat dan disimpan di folder 'Release_APKs'" -ForegroundColor Green
