#!/bin/bash

# Скрипт для публикации iOS приложения через App Store Connect API
# Использование: ./scripts/publish.sh

set -e

echo "🚀 Начинаем публикацию приложения..."

# Проверка наличия необходимых переменных окружения
if [ -z "$APP_STORE_CONNECT_API_KEY_ID" ] || [ -z "$APP_STORE_CONNECT_ISSUER_ID" ] || [ -z "$APP_STORE_CONNECT_API_KEY_CONTENT" ]; then
    echo "❌ Ошибка: Необходимо установить переменные окружения:"
    echo "   - APP_STORE_CONNECT_API_KEY_ID"
    echo "   - APP_STORE_CONNECT_ISSUER_ID"
    echo "   - APP_STORE_CONNECT_API_KEY_CONTENT"
    exit 1
fi

# Создание директории для API ключа
mkdir -p ~/.appstoreconnect/private_keys

# Сохранение API ключа
echo "$APP_STORE_CONNECT_API_KEY_CONTENT" > ~/.appstoreconnect/private_keys/AuthKey.p8
chmod 600 ~/.appstoreconnect/private_keys/AuthKey.p8

echo "✅ API ключ сохранён"

# Сборка архива
echo "📦 Собираем архив..."
xcodebuild clean archive \
    -project BirdEggs.xcodeproj \
    -scheme BirdEggs \
    -archivePath ./build/BirdEggs.xcarchive \
    -configuration Release \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:-}" \
    | xcpretty || xcodebuild clean archive \
    -project BirdEggs.xcodeproj \
    -scheme BirdEggs \
    -archivePath ./build/BirdEggs.xcarchive \
    -configuration Release \
    CODE_SIGN_STYLE=Automatic

echo "✅ Архив собран"

# Экспорт IPA
echo "📤 Экспортируем IPA..."
xcodebuild -exportArchive \
    -archivePath ./build/BirdEggs.xcarchive \
    -exportPath ./build/export \
    -exportOptionsPlist exportOptions.plist \
    | xcpretty || xcodebuild -exportArchive \
    -archivePath ./build/BirdEggs.xcarchive \
    -exportPath ./build/export \
    -exportOptionsPlist exportOptions.plist

echo "✅ IPA экспортирован"

# Загрузка в App Store Connect через fastlane
echo "☁️ Загружаем в App Store Connect..."
if command -v fastlane &> /dev/null; then
    fastlane deliver \
        --ipa "./build/export/BirdEggs.ipa" \
        --api_key_path ~/.appstoreconnect/private_keys/AuthKey.p8 \
        --api_key_id "$APP_STORE_CONNECT_API_KEY_ID" \
        --api_issuer "$APP_STORE_CONNECT_ISSUER_ID" \
        --skip_screenshots \
        --skip_metadata \
        --force \
        --submit_for_review false
    echo "✅ Приложение успешно загружено в App Store Connect!"
else
    echo "⚠️ Fastlane не установлен. Установите: gem install fastlane"
    echo "📦 IPA файл находится в: ./build/export/BirdEggs.ipa"
    echo "   Вы можете загрузить его вручную через Transporter или Xcode"
fi

