# Исправление проблем с сертификатами

## Проблемы

1. ❌ **Сертификат недействителен** - истек или отозван
2. ❌ **Provisioning profile для старого Bundle ID** - нужен для `com.collector.eggscollector.BirdEggs1`

## Решение

### Шаг 1: Создать новый Distribution сертификат

#### Вариант A: Через Xcode (рекомендуется)

1. Откройте **Xcode**
2. **Xcode** → **Settings** (Preferences) → **Accounts**
3. Выберите ваш **Apple ID** → выберите **Team**
4. Нажмите **"Manage Certificates..."**
5. Нажмите **"+"** → **"Apple Distribution"**
6. Xcode автоматически создаст и установит новый сертификат

#### Вариант B: Через Developer Portal

1. Перейдите: https://developer.apple.com/account/resources/certificates/list
2. Нажмите **"+"**
3. Выберите **"Apple Distribution"**
4. Следуйте инструкциям (нужен CSR файл)

### Шаг 2: Экспортировать новый сертификат (.p12)

1. Откройте **Keychain Access**
2. Выберите **"login"** → **"My Certificates"**
3. Найдите новый **"Apple Distribution"** сертификат
4. Раскройте сертификат и выберите **ключ**
5. Правый клик → **"Export 2 items..."**
6. Сохраните как `.p12` файл с паролем (запомните пароль!)

### Шаг 3: Конвертировать в base64

```bash
cd "/Users/useryou/IOS Prjts/BirdEggsIos/BirdEggs"
base64 -i ~/Downloads/new_certificate.p12 -o certificates/certificate_base64_new.txt
```

### Шаг 4: Создать новый App Store provisioning profile

1. Перейдите: https://developer.apple.com/account/resources/profiles/list
2. Нажмите **"+"** (создать новый)
3. Выберите **"App Store"** → **Continue**
4. Выберите **App ID**: `com.collector.eggscollector.BirdEggs1`
   - Если его нет, создайте:
     - Перейдите: https://developer.apple.com/account/resources/identifiers/list
     - Нажмите **"+"** → **"App IDs"** → **Continue**
     - Bundle ID: `com.collector.eggscollector.BirdEggs1`
     - Capabilities: оставьте по умолчанию
     - **Register**
5. Выберите ваш **новый Distribution сертификат**
6. Введите **Profile Name**: "Bird Eggs App Store v1"
7. Нажмите **Generate**
8. Скачайте `.mobileprovision` файл

### Шаг 5: Конвертировать профиль в base64

```bash
base64 -i ~/Downloads/bird_eggs_appstore_v1.mobileprovision -o certificates/profile_base64_new.txt
```

### Шаг 6: Обновить GitHub Secrets

```bash
cd "/Users/useryou/IOS Prjts/BirdEggsIos/BirdEggs"

# Обновить сертификат
CERT_BASE64=$(cat certificates/certificate_base64_new.txt | tr -d '\n')
# Используйте скрипт для обновления или обновите вручную через GitHub UI

# Обновить профиль
PROFILE_BASE64=$(cat certificates/profile_base64_new.txt | tr -d '\n')

# Обновить пароль (если изменился)
P12_PASSWORD="ваш_новый_пароль"
```

Или обновить через GitHub UI:
- https://github.com/emeliloeff685-ops/BirdEggs/settings/secrets/actions
- Обновить:
  - `BUILD_CERTIFICATE_BASE64`
  - `BUILD_PROVISION_PROFILE_BASE64`
  - `P12_PASSWORD` (если изменился)

---

## Быстрый способ через скрипт

После создания нового сертификата и профиля:

```bash
# Обновить сертификат
./scripts/add-certificates.sh

# Или обновить только пароль
P12_PASSWORD=ваш_пароль ./scripts/update-p12-password.sh
```

