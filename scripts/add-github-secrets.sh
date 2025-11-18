#!/bin/bash

# Скрипт для автоматического добавления секретов в GitHub
# Использование: ./scripts/add-github-secrets.sh

set -e

echo "🔐 Добавление секретов в GitHub..."

# Проверка наличия GitHub CLI
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI найден"
    
    # Проверка авторизации
    if gh auth status &> /dev/null; then
        echo "✅ Авторизован в GitHub CLI"
    else
        echo "❌ Необходимо авторизоваться в GitHub CLI"
        echo "   Запустите: gh auth login"
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
    
    # Добавление секретов
    echo "Добавляю секреты..."
    
    # API Key ID
    echo -n "APP_STORE_CONNECT_API_KEY_ID... "
    echo "XR6Q7S88HZ" | gh secret set APP_STORE_CONNECT_API_KEY_ID --repo "$REPO" && echo "✅" || echo "❌"
    
    # Issuer ID
    echo -n "APP_STORE_CONNECT_ISSUER_ID... "
    echo "c16a20f8-2d44-4c56-a7bf-d4ef1d92c4cb" | gh secret set APP_STORE_CONNECT_ISSUER_ID --repo "$REPO" && echo "✅" || echo "❌"
    
    # API Key Content
    echo -n "APP_STORE_CONNECT_API_KEY_CONTENT... "
    cat << 'EOF' | gh secret set APP_STORE_CONNECT_API_KEY_CONTENT --repo "$REPO" && echo "✅" || echo "❌"
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgXKEY7UOEEK138SYc
xSEUluXcadAju2KY7+tH0oQiGfegCgYIKoZIzj0DAQehRANCAASH/P+W27ml2VGt
s6+M34ZgYXjacvCGIxyTdVfgeuqQGGbxLflGJHIK1Nd3Q+sn2rwgRnCER4VHKS5o
FPy/vGJS
-----END PRIVATE KEY-----
EOF
    
    # Development Team
    echo -n "DEVELOPMENT_TEAM... "
    echo "R6M4TW8QJB" | gh secret set DEVELOPMENT_TEAM --repo "$REPO" && echo "✅" || echo "❌"
    
    echo ""
    echo "✅ Все секреты добавлены!"
    echo ""
    echo "Проверьте секреты в GitHub:"
    echo "https://github.com/$REPO/settings/secrets/actions"
    
else
    echo "❌ GitHub CLI не установлен"
    echo ""
    echo "Установите GitHub CLI:"
    echo "  macOS: brew install gh"
    echo "  Или скачайте с https://cli.github.com"
    echo ""
    echo "После установки:"
    echo "  1. gh auth login"
    echo "  2. Запустите этот скрипт снова"
    echo ""
    echo "Альтернативно, добавьте секреты вручную:"
    echo "  https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
    echo ""
    echo "Все необходимые значения находятся в файле GITHUB_SECRETS.md"
fi

