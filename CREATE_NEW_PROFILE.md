# Создание нового Provisioning Profile

## Проблема

Текущий provisioning profile для старого Bundle ID: `com.collector.eggscollector.BirdEggs`
Нужен для нового Bundle ID: `com.collector.eggscollector.BirdEggs1`

## Решение

### Шаг 1: Создать App Store Provisioning Profile

1. Перейдите: https://developer.apple.com/account/resources/profiles/list
2. Нажмите **+** (создать новый)
3. Выберите **App Store** → **Continue**
4. Выберите **App ID**: `com.collector.eggscollector.BirdEggs1`
   - Если его нет, создайте:
     - Перейдите: https://developer.apple.com/account/resources/identifiers/list
     - Нажмите **+** → **App IDs** → **Continue**
     - Bundle ID: `com.collector.eggscollector.BirdEggs1`
     - Capabilities: оставьте по умолчанию
     - **Register**
5. Выберите ваш **Distribution сертификат** (тот же, что использовался ранее)
6. Введите **Profile Name**: "Bird Eggs App Store v1"
7. Нажмите **Generate**
8. Скачайте `.mobileprovision` файл

### Шаг 2: Конвертировать в base64

```bash
base64 -i bird_eggs_appstore_v1.mobileprovision -o profile_base64_new.txt
```

### Шаг 3: Обновить GitHub Secret

```bash
cd "/Users/useryou/IOS Prjts/BirdEggsIos/BirdEggs"
cat profile_base64_new.txt | tr -d '\n' > profile_base64_new_single_line.txt

# Обновить секрет через скрипт или вручную в GitHub
```

Или обновить через GitHub UI:
- https://github.com/emeliloeff685-ops/BirdEggs/settings/secrets/actions
- Обновить `BUILD_PROVISION_PROFILE_BASE64`

---

## Альтернатива: Использовать существующий профиль временно

Можно попробовать использовать существующий профиль, но это может не сработать, так как Bundle ID не совпадает.

