# Инструкция по экспорту сертификатов для CI/CD

## Проблема

Автоматическая подпись не работает в GitHub Actions без Apple ID. Нужна ручная подпись с сертификатами.

## Что нужно

1. **Distribution сертификат** (.p12 файл)
2. **App Store provisioning profile** для Bundle ID: `com.collector.eggscollector.BirdEggs1`

## Шаг 1: Экспорт Distribution сертификата

### Вариант 1: Через Keychain Access (GUI)

1. Откройте **Keychain Access** (Поиск → Keychain Access)
2. В левом меню выберите **login** → **My Certificates**
3. Найдите сертификат **Apple Distribution** (или **iPhone Distribution**)
4. Раскройте сертификат и выберите **ключ** (обычно называется так же)
5. Правый клик → **Export 2 items...**
6. Сохраните как `.p12` файл (например: `distribution_cert.p12`)
7. Введите пароль для экспорта (запомните его!)

### Вариант 2: Через терминал

```bash
# Найти сертификат
security find-identity -v -p codesigning | grep "Distribution"

# Экспортировать (замените "YOUR_CERT_NAME" на имя сертификата)
security find-identity -v -p codesigning | grep "Distribution" | head -1 | sed 's/.*"\(.*\)".*/\1/'
```

## Шаг 2: Скачать App Store provisioning profile

1. Перейдите: https://developer.apple.com/account/resources/profiles/list
2. Нажмите **+** (создать новый профиль)
3. Выберите **App Store** → **Continue**
4. Выберите **App ID**: `com.collector.eggscollector.BirdEggs1`
5. Выберите ваш **Distribution сертификат**
6. Введите **Profile Name** (например: "Bird Eggs App Store")
7. Нажмите **Generate**
8. Скачайте `.mobileprovision` файл

## Шаг 3: Конвертация в base64

### Сертификат (.p12)

```bash
base64 -i distribution_cert.p12 -o certificate_base64.txt
```

### Provisioning profile (.mobileprovision)

```bash
base64 -i bird_eggs_appstore.mobileprovision -o profile_base64.txt
```

## Шаг 4: Добавить в GitHub Secrets

Перейдите: https://github.com/emeliloeff685-ops/BirdEggs/settings/secrets/actions

Добавьте следующие секреты:

1. **BUILD_CERTIFICATE_BASE64**
   - Значение: содержимое файла `certificate_base64.txt`

2. **P12_PASSWORD**
   - Значение: пароль, который вы использовали при экспорте .p12

3. **KEYCHAIN_PASSWORD**
   - Значение: любой случайный пароль (например: `temp_keychain_pass_123`)

4. **BUILD_PROVISION_PROFILE_BASE64**
   - Значение: содержимое файла `profile_base64.txt`

## Шаг 5: Проверка

После добавления секретов:
1. Запустите сборку снова
2. Workflow автоматически использует сертификаты для подписи

## Альтернатива: Использование скрипта

Если у вас есть скрипт для экспорта, используйте его:

```bash
cd "/Users/useryou/IOS Prjts/BirdEggsIos/BirdEggs"
./scripts/export-certificate.sh
```

---

## Важные замечания

- **Не делитесь** .p12 файлами и паролями
- Сертификаты имеют срок действия (обычно 1 год)
- После истечения срока нужно обновить сертификаты
- Provisioning profile должен соответствовать Bundle ID: `com.collector.eggscollector.BirdEggs1`

