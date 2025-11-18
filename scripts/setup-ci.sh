#!/bin/bash

# Скрипт для проверки настроек CI/CD

set -e

echo "🔍 Проверка настроек CI/CD..."

# Проверка наличия необходимых файлов
echo "📁 Проверка файлов..."
[ -f "exportOptions.plist" ] && echo "✅ exportOptions.plist найден" || echo "❌ exportOptions.plist не найден"
[ -f ".github/workflows/ios-publish-simple.yml" ] && echo "✅ GitHub Actions workflow найден" || echo "❌ GitHub Actions workflow не найден"
[ -f "fastlane/Fastfile" ] && echo "✅ Fastfile найден" || echo "❌ Fastfile не найден"

# Проверка Team ID в exportOptions.plist
echo ""
echo "🔑 Проверка Team ID..."
TEAM_ID=$(grep -A 1 "teamID" exportOptions.plist | grep -o '<string>.*</string>' | sed 's/<string>//;s/<\/string>//')
if [ "$TEAM_ID" = "R6M4TW8QJB" ]; then
    echo "✅ Team ID настроен правильно: $TEAM_ID"
else
    echo "⚠️ Team ID: $TEAM_ID (ожидается: R6M4TW8QJB)"
fi

# Проверка Bundle ID
echo ""
echo "📦 Проверка Bundle ID..."
BUNDLE_ID=$(grep -A 1 "PRODUCT_BUNDLE_IDENTIFIER" BirdEggs.xcodeproj/project.pbxproj | grep -o 'com\.[^;]*' | head -1)
echo "Bundle ID: $BUNDLE_ID"

# Информация о секретах GitHub
echo ""
echo "🔐 GitHub Secrets (добавьте в Settings → Secrets and variables → Actions):"
echo ""
echo "APP_STORE_CONNECT_API_KEY_ID = XR6Q7S88HZ"
echo "APP_STORE_CONNECT_ISSUER_ID = c16a20f8-2d44-4c56-a7bf-d4ef1d92c4cb"
echo "APP_STORE_CONNECT_API_KEY_CONTENT = [содержимое .p8 файла]"
echo "DEVELOPMENT_TEAM = R6M4TW8QJB"
echo ""
echo "📖 Подробные инструкции: см. GITHUB_SECRETS.md"

echo ""
echo "✅ Проверка завершена!"

