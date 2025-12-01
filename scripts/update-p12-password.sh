#!/bin/bash

# Скрипт для обновления пароля от .p12 в GitHub Secrets
# Использование: P12_PASSWORD=your_password ./scripts/update-p12-password.sh

set -e

GITHUB_TOKEN="${GITHUB_TOKEN:-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}"
REPO="emeliloeff685-ops/BirdEggs"

# Проверка наличия pynacl
if ! python3 -c "import nacl" 2>/dev/null; then
    echo "📦 Устанавливаю pynacl..."
    pip3 install pynacl --quiet
fi

# Функция для добавления секрета через GitHub API
add_secret() {
    local secret_name=$1
    local secret_value=$2
    
    echo -n "Обновляю $secret_name... "
    
    # Получение публичного ключа репозитория
    local response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO/actions/secrets/public-key")
    
    local key_id=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['key_id'])" 2>/dev/null)
    local public_key=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['key'])" 2>/dev/null)
    
    if [ -z "$key_id" ] || [ -z "$public_key" ]; then
        echo "❌ Не удалось получить публичный ключ"
        return 1
    fi
    
    # Шифрование секрета
    local encrypted_value=$(python3 << EOF
import base64
import sys
from nacl import encoding, public

def encrypt(public_key: str, secret_value: str) -> str:
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
        echo "❌ Не удалось зашифровать секрет"
        return 1
    fi
    
    # Отправка зашифрованного секрета
    local http_response=$(curl -s -w "\n%{http_code}" -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        "https://api.github.com/repos/$REPO/actions/secrets/$secret_name" \
        -d "{\"encrypted_value\":\"$encrypted_value\",\"key_id\":\"$key_id\"}")
    
    local http_code=$(echo "$http_response" | tail -n1)
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "204" ]; then
        echo "✅"
        return 0
    else
        echo "❌ HTTP $http_code"
        return 1
    fi
}

# Запрашиваем пароль
if [ -z "$P12_PASSWORD" ]; then
    echo "Введите пароль от .p12 файла:"
    read -s P12_PASSWORD
    echo ""
fi

if [ -z "$P12_PASSWORD" ]; then
    echo "❌ Пароль не может быть пустым"
    exit 1
fi

echo "🔐 Обновляю пароль в GitHub Secrets..."
echo ""

add_secret "P12_PASSWORD" "$P12_PASSWORD"

echo ""
echo "✅ Пароль обновлен!"
echo ""
echo "Проверьте секреты в GitHub:"
echo "https://github.com/$REPO/settings/secrets/actions"

