# Настройка сертификатов для CI/CD

Для автоматической сборки в GitHub Actions нужны сертификаты и provisioning profiles, так как автоматическая подпись не работает без авторизованного аккаунта.

## Шаг 1: Экспорт сертификата

1. Откройте **Keychain Access** на вашем Mac
2. Найдите ваш **Apple Distribution** сертификат
3. Выберите сертификат и приватный ключ (они должны быть вместе)
4. Правый клик → **Export 2 items...**
5. Сохраните как `.p12` файл (например, `certificate.p12`)
6. Установите пароль для `.p12` файла

## Шаг 2: Получение Provisioning Profile

1. Откройте [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list)
2. Найдите или создайте **App Store** provisioning profile для вашего приложения
3. Скачайте `.mobileprovision` файл

## Шаг 3: Конвертация в Base64

### Сертификат (.p12):
```bash
base64 -i certificate.p12 -o certificate_base64.txt
```

### Provisioning Profile (.mobileprovision):
```bash
base64 -i profile.mobileprovision -o profile_base64.txt
```

## Шаг 4: Добавление в GitHub Secrets

Перейдите в **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Добавьте следующие секреты:

1. **BUILD_CERTIFICATE_BASE64**
   - Значение: содержимое `certificate_base64.txt`

2. **P12_PASSWORD**
   - Значение: пароль, который вы установили для `.p12` файла

3. **KEYCHAIN_PASSWORD**
   - Значение: любой случайный пароль (например, `ci-keychain-password-123`)

4. **BUILD_PROVISION_PROFILE_BASE64**
   - Значение: содержимое `profile_base64.txt`

## Альтернативный вариант: Использование Fastlane Match

Если у вас настроен Fastlane Match, можно использовать его:

```yaml
- name: Setup Fastlane Match
  run: |
    fastlane match appstore --readonly
```

Но для этого нужна настройка Fastlane Match в проекте.

## После добавления секретов

После добавления всех секретов, workflow автоматически будет использовать ручную подпись вместо автоматической.

