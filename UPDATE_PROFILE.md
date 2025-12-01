# Обновление Provisioning Profile

## Шаг 1: Создать App Store Provisioning Profile

1. Перейдите: https://developer.apple.com/account/resources/profiles/list
2. Нажмите **"+"** (Create a new profile)
3. Выберите **"App Store"** → **Continue**
4. Выберите **App ID**: `com.collector.eggscollector.BirdEggs1`
5. Выберите ваш **Distribution сертификат** (который вы только что создали)
6. Введите **Profile Name**: "Bird Eggs App Store v1"
7. Нажмите **Generate**
8. Скачайте `.mobileprovision` файл

## Шаг 2: Обновить GitHub Secrets

После скачивания профиля выполните:

```bash
cd "/Users/useryou/IOS Prjts/BirdEggsIos/BirdEggs"

# Конвертировать профиль в base64
base64 -i ~/Downloads/ваш_профиль.mobileprovision -o certificates/profile_base64_new.txt

# Обновить GitHub Secrets
./scripts/update-certificates.sh certificates/certificate_base64_new.txt certificates/profile_base64_new.txt "ci-password-123"
```

Или если файл уже скачан:

```bash
# Найти файл профиля
PROFILE_FILE=$(find ~/Downloads -name "*.mobileprovision" -mtime -1 | head -1)

# Конвертировать и обновить
base64 -i "$PROFILE_FILE" -o certificates/profile_base64_new.txt
./scripts/update-certificates.sh certificates/certificate_base64_new.txt certificates/profile_base64_new.txt "ci-password-123"
```

## Шаг 3: Запустить сборку

После обновления секретов сборка должна пройти успешно!

