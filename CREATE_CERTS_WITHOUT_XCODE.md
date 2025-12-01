# Создание сертификатов без Xcode

## Шаг 1: Создать CSR (Certificate Signing Request)

Выполните в терминале:

```bash
cd "/Users/useryou/IOS Prjts/BirdEggsIos/BirdEggs"
./scripts/create-csr.sh
```

Это создаст:
- `certificates/private_key.key` - приватный ключ (⚠️ НЕ УДАЛЯЙТЕ!)
- `certificates/certificate_request.csr` - запрос на сертификат

## Шаг 2: Создать Distribution сертификат в Developer Portal

1. Перейдите: https://developer.apple.com/account/resources/certificates/list
2. Нажмите **"+"** (Create a new certificate)
3. Выберите **"Apple Distribution"** → **Continue**
4. Нажмите **"Choose File"** и выберите файл: `certificates/certificate_request.csr`
5. Нажмите **Continue** → **Register**
6. Скачайте сертификат (`.cer` файл)

## Шаг 3: Экспортировать сертификат в .p12

```bash
# Замените путь на путь к скачанному .cer файлу
./scripts/export-certificate.sh ~/Downloads/certificate.cer ваш_пароль
```

Это создаст:
- `certificates/certificate.p12` - сертификат для CI/CD
- `certificates/certificate_base64.txt` - base64 версия

## Шаг 4: Создать App Store Provisioning Profile

1. Перейдите: https://developer.apple.com/account/resources/profiles/list
2. Нажмите **"+"** (Create a new profile)
3. Выберите **"App Store"** → **Continue**
4. Выберите **App ID**: `com.collector.eggscollector.BirdEggs1`
   - Если его нет, создайте:
     - Перейдите: https://developer.apple.com/account/resources/identifiers/list
     - Нажмите **"+"** → **"App IDs"** → **Continue**
     - Bundle ID: `com.collector.eggscollector.BirdEggs1`
     - Capabilities: оставьте по умолчанию
     - **Register**
5. Выберите ваш **Distribution сертификат** (созданный в шаге 2)
6. Введите **Profile Name**: "Bird Eggs App Store v1"
7. Нажмите **Generate**
8. Скачайте `.mobileprovision` файл

## Шаг 5: Конвертировать профиль в base64

```bash
# Замените путь на путь к скачанному .mobileprovision файлу
base64 -i ~/Downloads/bird_eggs_appstore_v1.mobileprovision -o certificates/profile_base64_new.txt
```

## Шаг 6: Обновить GitHub Secrets

```bash
# Обновить сертификат и профиль
./scripts/update-certificates.sh certificates/certificate_base64.txt certificates/profile_base64_new.txt ваш_пароль
```

Или обновить вручную через GitHub UI:
- https://github.com/emeliloeff685-ops/BirdEggs/settings/secrets/actions
- Обновить:
  - `BUILD_CERTIFICATE_BASE64` - содержимое `certificates/certificate_base64.txt`
  - `BUILD_PROVISION_PROFILE_BASE64` - содержимое `certificates/profile_base64_new.txt`
  - `P12_PASSWORD` - пароль, который вы использовали при экспорте

---

## Быстрый способ (если есть старый CSR)

Если у вас уже есть CSR файл, можно использовать его:

```bash
# Проверить наличие CSR
ls -lh certificates/certificate_request.csr

# Если есть, переходите к шагу 2
# Если нет, запустите шаг 1
```

