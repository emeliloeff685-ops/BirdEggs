#!/bin/bash

# Скрипт для экспорта сертификата в .p12 формат
# Использование: ./scripts/export-certificate.sh <path_to_cer_file> [password]

set -e

if [ -z "$1" ]; then
    echo "❌ Использование: ./scripts/export-certificate.sh <path_to_cer_file> [password]"
    echo "   Пример: ./scripts/export-certificate.sh ~/Downloads/certificate.cer mypassword"
    exit 1
fi

CER_FILE="$1"
P12_PASSWORD="$2"
PRIVATE_KEY="certificates/private_key.key"
P12_FILE="certificates/certificate.p12"

if [ ! -f "$CER_FILE" ]; then
    echo "❌ Файл сертификата не найден: $CER_FILE"
    exit 1
fi

if [ ! -f "$PRIVATE_KEY" ]; then
    echo "❌ Приватный ключ не найден: $PRIVATE_KEY"
    echo "   Сначала запустите: ./scripts/create-csr.sh"
    exit 1
fi

echo "🔐 Экспорт сертификата в .p12 формат..."

# Конвертируем .cer в .pem
CER_PEM="certificates/certificate.pem"
openssl x509 -inform DER -in "$CER_FILE" -out "$CER_PEM" 2>/dev/null || \
openssl x509 -inform PEM -in "$CER_FILE" -out "$CER_PEM" 2>/dev/null

# Создаём .p12 файл
if [ -z "$P12_PASSWORD" ]; then
    echo "Введите пароль для .p12 файла (запомните его - понадобится для GitHub Secrets):"
    read -s P12_PASSWORD
    echo ""
fi

openssl pkcs12 -export \
    -out "$P12_FILE" \
    -inkey "$PRIVATE_KEY" \
    -in "$CER_PEM" \
    -name "BirdEggs Distribution" \
    -passout pass:"$P12_PASSWORD"

chmod 600 "$P12_FILE"

echo ""
echo "✅ Сертификат экспортирован: $P12_FILE"
echo ""
echo "📋 Следующие шаги:"
echo "1. Конвертируйте .p12 в base64:"
echo "   base64 -i $P12_FILE -o certificates/certificate_base64.txt"
echo ""
echo "2. Добавьте в GitHub Secrets:"
echo "   - BUILD_CERTIFICATE_BASE64: содержимое certificates/certificate_base64.txt"
if [ -n "$P12_PASSWORD" ]; then
    echo "   - P12_PASSWORD: $P12_PASSWORD"
else
    echo "   - P12_PASSWORD: пароль, который вы ввели выше"
fi
echo "   - KEYCHAIN_PASSWORD: любой случайный пароль"

