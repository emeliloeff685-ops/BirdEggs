#!/bin/bash

# Скрипт для добавления сертификатов в GitHub Secrets
# Использование: GITHUB_TOKEN=your_token ./scripts/add-certificate-secrets.sh

set -e

GITHUB_TOKEN="${GITHUB_TOKEN:-}"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Необходимо установить переменную GITHUB_TOKEN"
    echo "   Использование: GITHUB_TOKEN=your_token ./scripts/add-certificate-secrets.sh"
    exit 1
fi

# Проверка наличия файлов
if [ ! -f "certificates/certificate_base64.txt" ]; then
    echo "❌ Файл certificates/certificate_base64.txt не найден"
    echo "   Сначала запустите: ./scripts/export-certificate.sh"
    exit 1
fi

# Получение имени репозитория
REPO=$(git remote get-url origin 2>/dev/null | sed -E 's/.*github.com[:/](.*)\.git/\1/' || echo "")

if [ -z "$REPO" ]; then
    echo "❌ Не удалось определить репозиторий"
    exit 1
fi

echo "📦 Репозиторий: $REPO"
echo ""

# Функция для добавления секрета
add_secret() {
    local secret_name=$1
    local secret_value=$2
    
    echo -n "Добавляю $secret_name... "
    
    local temp_file=$(mktemp)
    local http_code=$(curl -s -w "%{http_code}" -o "$temp_file" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO/actions/secrets/public-key")
    
    local body=$(cat "$temp_file")
    rm "$temp_file"
    
    if [ "$http_code" != "200" ]; then
        echo "❌ Не удалось получить публичный ключ (HTTP $http_code)"
        return 1
    fi
    
    local key_id=$(echo "$body" | python3 -c "import sys, json; print(json.load(sys.stdin)['key_id'])" 2>/dev/null)
    local public_key=$(echo "$body" | python3 -c "import sys, json; print(json.load(sys.stdin)['key'])" 2>/dev/null)
    
    if [ -z "$key_id" ] || [ -z "$public_key" ]; then
        echo "❌ Не удалось извлечь публичный ключ"
        return 1
    fi
    
    # Шифрование секрета
    local encrypted_value=$(python3 << EOF
import base64
import json
import sys

try:
    from nacl import encoding, public
    
    def encrypt(public_key: str, secret_value: str) -> str:
        public_key_obj = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
        sealed_box = public.SealedBox(public_key_obj)
        encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
        return base64.b64encode(encrypted).decode("utf-8")
    
    print(encrypt("$public_key", """$secret_value"""))
except ImportError:
    print("ERROR: pynacl not installed", file=sys.stderr)
    sys.exit(1)
EOF
)
    
    if [ -z "$encrypted_value" ] || [[ "$encrypted_value" == ERROR* ]]; then
        echo "❌ Не удалось зашифровать секрет"
        return 1
    fi
    
    # Отправка зашифрованного секрета
    local put_temp_file=$(mktemp)
    local put_http_code=$(curl -s -w "%{http_code}" -o "$put_temp_file" -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        "https://api.github.com/repos/$REPO/actions/secrets/$secret_name" \
        -d "{\"encrypted_value\":\"$encrypted_value\",\"key_id\":\"$key_id\"}")
    
    local put_response=$(cat "$put_temp_file")
    rm "$put_temp_file"
    
    if [ "$put_http_code" = "201" ] || [ "$put_http_code" = "204" ]; then
        echo "✅"
        return 0
    else
        echo "❌ HTTP $put_http_code"
        return 1
    fi
}

# Читаем base64 сертификата
CERT_BASE64=$(cat certificates/certificate_base64.txt)

# Добавление секретов
echo "🔐 Добавление секретов сертификата в GitHub..."
echo ""

add_secret "BUILD_CERTIFICATE_BASE64" "$CERT_BASE64"
add_secret "P12_PASSWORD" "ci-password-123"
add_secret "KEYCHAIN_PASSWORD" "ci-keychain-password-123"

echo ""
echo "✅ Все секреты сертификата добавлены!"
echo ""
echo "⚠️  ВАЖНО: У вас iOS Development сертификат!"
echo "   Для публикации в App Store нужен Apple Distribution сертификат."
echo "   Создайте новый сертификат типа 'Apple Distribution' в Apple Developer Portal."
echo ""
echo "Проверьте секреты в GitHub:"
echo "https://github.com/$REPO/settings/secrets/actions"

