#!/bin/bash

# Скрипт для добавления сертификатов в GitHub Secrets
# Использование: ./scripts/add-certificates.sh

set -e

GITHUB_TOKEN="${GITHUB_TOKEN:-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}"
REPO="emeliloeff685-ops/BirdEggs"

echo "📦 Репозиторий: $REPO"
echo ""

# Проверка наличия pynacl
if ! python3 -c "import nacl" 2>/dev/null; then
    echo "📦 Устанавливаю pynacl..."
    pip3 install pynacl --quiet
fi

# Функция для добавления секрета через GitHub API
add_secret() {
    local secret_name=$1
    local secret_value=$2
    
    echo -n "Добавляю $secret_name... "
    
    # Получение публичного ключа репозитория
    local response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO/actions/secrets/public-key")
    
    local key_id=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['key_id'])" 2>/dev/null)
    local public_key=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['key'])" 2>/dev/null)
    
    if [ -z "$key_id" ] || [ -z "$public_key" ]; then
        echo "❌ Не удалось получить публичный ключ"
        echo "Response: $response"
        return 1
    fi
    
    # Шифрование секрета
    local encrypted_value=$(python3 << EOF
import base64
import json
import sys
from nacl import encoding, public

def encrypt(public_key: str, secret_value: str) -> str:
    """Encrypt a Unicode string using the public key."""
    public_key_obj = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key_obj)
    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    return base64.b64encode(encrypted).decode("utf-8")

try:
    print(encrypt("$public_key", """$secret_value"""))
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
)
    
    if [ -z "$encrypted_value" ] || [[ "$encrypted_value" == Error* ]]; then
        echo "❌ Не удалось зашифровать секрет: $encrypted_value"
        return 1
    fi
    
    # Отправка зашифрованного секрета
    local http_response=$(curl -s -w "\n%{http_code}" -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        "https://api.github.com/repos/$REPO/actions/secrets/$secret_name" \
        -d "{\"encrypted_value\":\"$encrypted_value\",\"key_id\":\"$key_id\"}")
    
    local http_code=$(echo "$http_response" | tail -n1)
    local response_body=$(echo "$http_response" | head -n -1)
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "204" ]; then
        echo "✅"
        return 0
    else
        echo "❌ HTTP $http_code"
        echo "Response: $response_body"
        return 1
    fi
}

# Чтение сертификатов
if [ ! -f "certificates/certificate_base64.txt" ]; then
    echo "❌ Файл certificates/certificate_base64.txt не найден"
    exit 1
fi

if [ ! -f "certificates/profile_base64.txt" ]; then
    echo "❌ Файл certificates/profile_base64.txt не найден"
    exit 1
fi

CERT_BASE64=$(cat certificates/certificate_base64.txt | tr -d '\n')
PROFILE_BASE64=$(cat certificates/profile_base64.txt | tr -d '\n')

# Пароли (можно изменить)
P12_PASSWORD="${P12_PASSWORD:-temp123}"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-temp_keychain_123}"

echo "⚠️ ВАЖНО: Provisioning profile для старого Bundle ID (com.collector.eggscollector.BirdEggs)"
echo "   Нужно создать новый профиль для: com.collector.eggscollector.BirdEggs1"
echo ""
echo "🔐 Добавляю сертификаты в GitHub Secrets..."
echo ""

add_secret "BUILD_CERTIFICATE_BASE64" "$CERT_BASE64"
add_secret "BUILD_PROVISION_PROFILE_BASE64" "$PROFILE_BASE64"
add_secret "P12_PASSWORD" "$P12_PASSWORD"
add_secret "KEYCHAIN_PASSWORD" "$KEYCHAIN_PASSWORD"

echo ""
echo "✅ Сертификаты добавлены!"
echo ""
echo "⚠️ ВАЖНО: Нужно создать новый provisioning profile для Bundle ID: com.collector.eggscollector.BirdEggs1"
echo "   https://developer.apple.com/account/resources/profiles/list"
echo ""
echo "Проверьте секреты в GitHub:"
echo "https://github.com/$REPO/settings/secrets/actions"

