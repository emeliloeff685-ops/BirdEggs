#!/bin/bash

# Скрипт для создания сертификата через App Store Connect API
# Использование: ./scripts/create-certificate.sh

set -e

echo "🔐 Создание сертификата через App Store Connect API..."

# Проверка переменных окружения
if [ -z "$APP_STORE_CONNECT_API_KEY_ID" ] || [ -z "$APP_STORE_CONNECT_ISSUER_ID" ] || [ -z "$APP_STORE_CONNECT_API_KEY_CONTENT" ]; then
    echo "❌ Необходимо установить переменные окружения:"
    echo "   - APP_STORE_CONNECT_API_KEY_ID"
    echo "   - APP_STORE_CONNECT_ISSUER_ID"
    echo "   - APP_STORE_CONNECT_API_KEY_CONTENT"
    exit 1
fi

# Сохранение API ключа
mkdir -p ~/.appstoreconnect/private_keys
echo "$APP_STORE_CONNECT_API_KEY_CONTENT" > ~/.appstoreconnect/private_keys/AuthKey.p8
chmod 600 ~/.appstoreconnect/private_keys/AuthKey.p8

echo "✅ API ключ сохранён"

# Генерация CSR (Certificate Signing Request)
echo "📝 Генерация CSR..."
CSR_FILE=$(mktemp)
openssl genrsa -out "${CSR_FILE}.key" 2048
openssl req -new -key "${CSR_FILE}.key" -out "${CSR_FILE}.csr" -subj "/CN=BirdEggs CI/CD/O=BirdEggs/C=US"

echo "✅ CSR создан"

# Создание сертификата через API (требует Python и библиотеки)
echo "⚠️  Создание сертификата через API требует дополнительных библиотек"
echo ""
echo "Альтернативный способ:"
echo "1. Откройте https://developer.apple.com/account/resources/certificates/list"
echo "2. Нажмите '+' → 'Apple Distribution'"
echo "3. Загрузите CSR файл: ${CSR_FILE}.csr"
echo "4. Скачайте созданный сертификат"
echo "5. Дважды кликните на сертификат для импорта в Keychain"
echo "6. Экспортируйте сертификат как .p12 файл"
echo ""
echo "CSR файл сохранён в: ${CSR_FILE}.csr"

