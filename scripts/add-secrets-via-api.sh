#!/bin/bash

# Скрипт для добавления секретов через GitHub API
# Требует GitHub Personal Access Token с правами repo и admin:repo
# Использование: GITHUB_TOKEN=your_token ./scripts/add-secrets-via-api.sh

set -e

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Необходимо установить переменную GITHUB_TOKEN"
    echo ""
    echo "Создайте Personal Access Token:"
    echo "  1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)"
    echo "  2. Generate new token (classic)"
    echo "  3. Выберите права: repo (все), admin:repo (все)"
    echo "  4. Скопируйте токен"
    echo ""
    echo "Затем запустите:"
    echo "  GITHUB_TOKEN=your_token ./scripts/add-secrets-via-api.sh"
    exit 1
fi

# Получение имени репозитория
REPO=$(git remote get-url origin 2>/dev/null | sed -E 's/.*github.com[:/](.*)\.git/\1/' || echo "")

if [ -z "$REPO" ]; then
    echo "❌ Не удалось определить репозиторий"
    echo "   Убедитесь, что вы находитесь в git репозитории с настроенным remote origin"
    exit 1
fi

echo "📦 Репозиторий: $REPO"
echo ""

# Функция для добавления секрета через GitHub API
add_secret() {
    local secret_name=$1
    local secret_value=$2
    
    echo -n "Добавляю $secret_name... "
    
    # Получение публичного ключа репозитория
    local key_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO/actions/secrets/public-key" | \
        grep -o '"key_id":"[^"]*"' | cut -d'"' -f4)
    
    local public_key=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO/actions/secrets/public-key" | \
        grep -o '"key":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$key_id" ] || [ -z "$public_key" ]; then
        echo "❌ Не удалось получить публичный ключ"
        return 1
    fi
    
    # Шифрование секрета (требует библиотеку libsodium)
    if command -v python3 &> /dev/null; then
        local encrypted_value=$(python3 << EOF
import base64
import json
from nacl import encoding, public

def encrypt(public_key: str, secret_value: str) -> str:
    """Encrypt a Unicode string using the public key."""
    public_key = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key)
    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    return base64.b64encode(encrypted).decode("utf-8")

print(encrypt("$public_key", "$secret_value"))
EOF
)
        
        if [ -z "$encrypted_value" ]; then
            echo "❌ Не удалось зашифровать секрет"
            echo "   Установите: pip3 install pynacl"
            return 1
        fi
        
        # Отправка зашифрованного секрета
        local response=$(curl -s -w "\n%{http_code}" -X PUT \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/json" \
            "https://api.github.com/repos/$REPO/actions/secrets/$secret_name" \
            -d "{\"encrypted_value\":\"$encrypted_value\",\"key_id\":\"$key_id\"}")
        
        local http_code=$(echo "$response" | tail -n1)
        
        if [ "$http_code" = "201" ] || [ "$http_code" = "204" ]; then
            echo "✅"
            return 0
        else
            echo "❌ HTTP $http_code"
            return 1
        fi
    else
        echo "❌ Python3 не найден (требуется для шифрования)"
        return 1
    fi
}

# Добавление секретов
add_secret "APP_STORE_CONNECT_API_KEY_ID" "XR6Q7S88HZ"
add_secret "APP_STORE_CONNECT_ISSUER_ID" "c16a20f8-2d44-4c56-a7bf-d4ef1d92c4cb"
add_secret "APP_STORE_CONNECT_API_KEY_CONTENT" "-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgXKEY7UOEEK138SYc
xSEUluXcadAju2KY7+tH0oQiGfegCgYIKoZIzj0DAQehRANCAASH/P+W27ml2VGt
s6+M34ZgYXjacvCGIxyTdVfgeuqQGGbxLflGJHIK1Nd3Q+sn2rwgRnCER4VHKS5o
FPy/vGJS
-----END PRIVATE KEY-----"
add_secret "DEVELOPMENT_TEAM" "R6M4TW8QJB"

echo ""
echo "✅ Готово!"
echo ""
echo "Проверьте секреты в GitHub:"
echo "https://github.com/$REPO/settings/secrets/actions"

