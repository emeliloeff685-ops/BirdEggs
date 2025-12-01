# Создание нового Provisioning Profile для Bundle ID: com.collector.eggscollector.BirdEggs1

## Шаг 1: Создать App Store Provisioning Profile

1. Перейдите: https://developer.apple.com/account/resources/profiles/list
2. Нажмите **"+"** (Create a new profile)
3. Выберите **"App Store"** → **Continue**
4. Выберите **App ID**: `com.collector.eggscollector.BirdEggs1`
   - Если его нет в списке, значит нужно сначала создать App ID:
     - Перейдите: https://developer.apple.com/account/resources/identifiers/list
     - Нажмите **"+"** → **"App IDs"** → **Continue**
     - Bundle ID: `com.collector.eggscollector.BirdEggs1`
     - Capabilities: оставьте по умолчанию
     - **Register**
     - Вернитесь к созданию профиля
5. Выберите ваш **Distribution сертификат** (который вы создали сегодня)
6. Введите **Profile Name**: "Bird Eggs App Store v1"
7. Нажмите **Generate**
8. Скачайте `.mobileprovision` файл

## Шаг 2: Обновить GitHub Secrets

После скачивания выполните:

```bash
cd "/Users/useryou/IOS Prjts/BirdEggsIos/BirdEggs"

# Найти новый профиль (самый свежий .mobileprovision файл)
PROFILE_FILE=$(ls -t ~/Downloads/*.mobileprovision 2>/dev/null | head -1)

# Конвертировать в base64
base64 -i "$PROFILE_FILE" -o certificates/profile_base64_new.txt

# Обновить GitHub Secrets
./scripts/update-certificates.sh certificates/certificate_base64_new.txt certificates/profile_base64_new.txt "ci-password-123"
```

Или вручную:

```bash
# Если файл называется по-другому, укажите путь
base64 -i ~/Downloads/ваш_профиль.mobileprovision -o certificates/profile_base64_new.txt
./scripts/update-certificates.sh certificates/certificate_base64_new.txt certificates/profile_base64_new.txt "ci-password-123"
```

## Шаг 3: Проверить Bundle ID в профиле (опционально)

```bash
security cms -D -i ~/Downloads/ваш_профиль.mobileprovision | grep -A 1 "application-identifier"
```

Должно быть: `R6M4TW8QJB.com.collector.eggscollector.BirdEggs1`

## После обновления

Сборка должна пройти успешно! 🎉

