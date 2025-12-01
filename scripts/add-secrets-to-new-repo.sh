#!/bin/bash

# Скрипт для добавления секретов в новый репозиторий через GitHub API
# Использование: GITHUB_TOKEN=your_token ./scripts/add-secrets-to-new-repo.sh

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

# Чтение содержимого .p8 файла
P8_CONTENT=$(cat << 'EOF'
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgXKEY7UOEEK138SYc
xSEUluXcadAju2KY7+tH0oQiGfegCgYIKoZIzj0DAQehRANCAASH/P+W27ml2VGt
s6+M34ZgYXjacvCGIxyTdVfgeuqQGGbxLflGJHIK1Nd3Q+sn2rwgRnCER4VHKS5o
FPy/vGJS
-----END PRIVATE KEY-----
EOF
)

# Добавление секретов
echo "🔐 Добавляю секреты в GitHub..."
echo ""

add_secret "APP_STORE_CONNECT_API_KEY_ID" "XR6Q7S88HZ"
add_secret "APP_STORE_CONNECT_ISSUER_ID" "c16a20f8-2d44-4c56-a7bf-d4ef1d92c4cb"
add_secret "APP_STORE_CONNECT_API_KEY_CONTENT" "$P8_CONTENT"
add_secret "DEVELOPMENT_TEAM" "R6M4TW8QJB"

echo ""
echo "✅ Все секреты добавлены!"
echo ""
echo "Проверьте секреты в GitHub:"
echo "https://github.com/$REPO/settings/secrets/actions"

