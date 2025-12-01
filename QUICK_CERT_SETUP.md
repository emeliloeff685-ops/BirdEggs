# Быстрое создание сертификатов без Xcode

## ✅ У вас уже есть CSR файл!

Файлы готовы:
- ✅ `certificates/certificate_request.csr` - запрос на сертификат
- ✅ `certificates/private_key.key` - приватный ключ

## Шаг 1: Создать Distribution сертификат в Developer Portal

1. Перейдите: https://developer.apple.com/account/resources/certificates/list
2. Нажмите **"+"** (Create a new certificate)
3. Выберите **"Apple Distribution"** → **Continue**
4. Нажмите **"Choose File"** и выберите файл:
   ```
   /Users/useryou/IOS Prjts/BirdEggsIos/BirdEggs/certificates/certificate_request.csr
   ```
5. Нажмите **Continue** → **Register**
6. Скачайте сертификат (`.cer` файл) - сохраните его в Downloads

## Шаг 2: Экспортировать сертификат в .p12

После скачивания .cer файла выполните:

```bash
cd "/Users/useryou/IOS Prjts/BirdEggsIos/BirdEggs"
./scripts/export-certificate.sh ~/Downloads/certificate.cer ваш_пароль
```

Это создаст:
- `certificates/certificate.p12`
- `certificates/certificate_base64.txt`

## Шаг 3: Создать App Store Provisioning Profile

1. Перейдите: https://developer.apple.com/account/resources/profiles/list
2. Нажмите **"+"** (Create a new profile)
3. Выберите **"App Store"** → **Continue**
4. Выберите **App ID**: `com.collector.eggscollector.BirdEggs1`
   - Если его нет, создайте:
     - Перейдите: https://developer.apple.com/account/resources/identifiers/list
     - Нажмите **"+"** → **"App IDs"** → **Continue**
     - Bundle ID: `com.collector.eggscollector.BirdEggs1`
     - **Register**
5. Выберите ваш **новый Distribution сертификат** (из шага 1)
6. Введите **Profile Name**: "Bird Eggs App Store v1"
7. Нажмите **Generate**
8. Скачайте `.mobileprovision` файл

## Шаг 4: Конвертировать профиль в base64

```bash
base64 -i ~/Downloads/bird_eggs_appstore_v1.mobileprovision -o certificates/profile_base64_new.txt
```

## Шаг 5: Обновить GitHub Secrets

```bash
# Обновить сертификат и профиль
./scripts/update-certificates.sh certificates/certificate_base64.txt certificates/profile_base64_new.txt ваш_пароль
```

Или обновить вручную через GitHub UI:
- https://github.com/emeliloeff685-ops/BirdEggs/settings/secrets/actions
- Обновить:
  - `BUILD_CERTIFICATE_BASE64` - содержимое `certificates/certificate_base64.txt`
  - `BUILD_PROVISION_PROFILE_BASE64` - содержимое `certificates/profile_base64_new.txt`
  - `P12_PASSWORD` - пароль от .p12

---

## После обновления секретов

Запустите сборку через GitHub UI:
- Перейдите: https://github.com/emeliloeff685-ops/BirdEggs/actions
- Выберите workflow "Build and Publish iOS App (Simple)"
- Нажмите "Run workflow"

