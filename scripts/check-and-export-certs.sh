#!/bin/bash

# Скрипт для проверки и экспорта сертификатов для CI/CD

set -e

echo "🔍 Проверка сертификатов..."

# Проверка сертификатов в Keychain
CERT_COUNT=$(security find-identity -v -p codesigning 2>/dev/null | grep -c "Distribution" || echo "0")

if [ "$CERT_COUNT" -eq "0" ]; then
    echo "❌ Distribution сертификаты не найдены в Keychain"
    echo ""
    echo "📋 Что делать:"
    echo "1. Откройте Xcode"
    echo "2. Xcode → Settings → Accounts"
    echo "3. Выберите ваш Apple ID → выберите Team"
    echo "4. Нажмите 'Manage Certificates...'"
    echo "5. Нажмите '+' → 'Apple Distribution'"
    echo "6. Xcode автоматически создаст и установит сертификат"
    echo ""
    echo "Или создайте сертификат вручную:"
    echo "https://developer.apple.com/account/resources/certificates/list"
    exit 1
fi

echo "✅ Найдено сертификатов: $CERT_COUNT"
echo ""

# Показываем найденные сертификаты
echo "📋 Найденные Distribution сертификаты:"
security find-identity -v -p codesigning 2>/dev/null | grep "Distribution" | head -5

echo ""
echo "💡 Для экспорта сертификата используйте Keychain Access:"
echo "1. Откройте Keychain Access"
echo "2. Выберите 'login' → 'My Certificates'"
echo "3. Найдите 'Apple Distribution'"
echo "4. Раскройте и выберите ключ"
echo "5. Правый клик → 'Export 2 items...'"
echo "6. Сохраните как .p12 с паролем"

echo ""
echo "📱 Для создания provisioning profile:"
echo "https://developer.apple.com/account/resources/profiles/list"
echo "Bundle ID: com.collector.eggscollector.BirdEggs1"
echo "Type: App Store"

