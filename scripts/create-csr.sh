#!/bin/bash

# Скрипт для создания Certificate Signing Request (CSR)
# Использование: ./scripts/create-csr.sh

set -e

echo "🔐 Создание Certificate Signing Request (CSR)..."

# Создаём директорию для сертификатов
mkdir -p certificates

# Имена файлов
PRIVATE_KEY="certificates/private_key.key"
CSR_FILE="certificates/certificate_request.csr"

# Генерация приватного ключа (если его ещё нет)
if [ ! -f "$PRIVATE_KEY" ]; then
    echo "📝 Генерация приватного ключа..."
    openssl genrsa -out "$PRIVATE_KEY" 2048
    chmod 600 "$PRIVATE_KEY"
    echo "✅ Приватный ключ создан: $PRIVATE_KEY"
else
    echo "✅ Используется существующий приватный ключ: $PRIVATE_KEY"
fi

# Генерация CSR
echo "📝 Генерация Certificate Signing Request..."
openssl req -new -key "$PRIVATE_KEY" -out "$CSR_FILE" -subj "/CN=BirdEggs CI/CD/O=BirdEggs/C=US"

echo ""
echo "✅ CSR создан успешно!"
echo ""
echo "📄 Файлы:"
echo "   - Приватный ключ: $PRIVATE_KEY"
echo "   - CSR запрос: $CSR_FILE"
echo ""
echo "📋 Следующие шаги:"
echo "1. Откройте https://developer.apple.com/account/resources/certificates/list"
echo "2. Нажмите кнопку '+' (Create a new certificate)"
echo "3. Выберите 'Apple Distribution'"
echo "4. Нажмите 'Continue'"
echo "5. Загрузите файл: $CSR_FILE"
echo "6. Скачайте созданный сертификат (.cer файл)"
echo "7. Сохраните приватный ключ ($PRIVATE_KEY) - он понадобится для экспорта .p12"
echo ""
echo "⚠️  ВАЖНО: Сохраните приватный ключ ($PRIVATE_KEY) в безопасном месте!"
echo "   Он понадобится для создания .p12 файла после получения сертификата."

