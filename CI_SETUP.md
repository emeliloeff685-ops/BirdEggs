# Настройка CI/CD для автоматической публикации iOS приложения

Этот документ описывает настройку автоматической публикации приложения в App Store через GitHub Actions без необходимости авторизации на устройстве.

## Преимущества использования App Store Connect API

- ✅ Не требует авторизации на устройстве
- ✅ Полностью автоматизированный процесс
- ✅ Безопасное хранение ключей в GitHub Secrets
- ✅ Работает на любом Mac runner в GitHub Actions

## Шаг 1: Создание App Store Connect API ключа

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите в **Users and Access** → **Keys** → **App Store Connect API**
3. Нажмите **Generate API Key**
4. Заполните:
   - **Name**: `CI/CD Key` (или любое другое имя)
   - **Access**: **App Manager** или **Admin**
5. Нажмите **Generate**
6. **ВАЖНО**: Скачайте файл `.p8` (можно скачать только один раз!)
7. Сохраните:
   - **Key ID** (например: `ABC123DEFG`)
   - **Issuer ID** (например: `12345678-1234-1234-1234-123456789012`)

## Шаг 2: Настройка GitHub Secrets

Перейдите в ваш репозиторий на GitHub:
**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Добавьте следующие секреты:

### Обязательные секреты:

1. **APP_STORE_CONNECT_API_KEY_ID**
   - Значение: Key ID из шага 1 (например: `ABC123DEFG`)

2. **APP_STORE_CONNECT_ISSUER_ID**
   - Значение: Issuer ID из шага 1 (например: `12345678-1234-1234-1234-123456789012`)

3. **APP_STORE_CONNECT_API_KEY_CONTENT**
   - Значение: Содержимое файла `.p8` (откройте файл в текстовом редакторе и скопируйте всё содержимое)
   - Формат:
     ```
     -----BEGIN PRIVATE KEY-----
     MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
     -----END PRIVATE KEY-----
     ```

4. **DEVELOPMENT_TEAM**
   - Значение: Ваш Team ID (можно найти в Xcode → Settings → Accounts → выберите команду)
   - Формат: `ABC123DEFG` (10 символов)

### Опциональные секреты (для автоматической подписи):

5. **APPLE_ID**
   - Ваш Apple ID email (если используете автоматическую подпись)

6. **APPLE_APP_SPECIFIC_PASSWORD**
   - App-specific password для вашего Apple ID
   - Создайте на [appleid.apple.com](https://appleid.apple.com) → **Sign-In and Security** → **App-Specific Passwords**

## Шаг 3: Обновление exportOptions.plist

Откройте файл `exportOptions.plist` и замените:

- `YOUR_TEAM_ID` на ваш Team ID
- `YOUR_PROVISIONING_PROFILE_NAME` на имя вашего provisioning profile (или оставьте пустым для автоматической подписи)

## Шаг 4: Запуск публикации

### Способ 1: Через тег (рекомендуется)

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Способ 2: Вручную через GitHub UI

1. Перейдите в **Actions** → **Build and Publish iOS App**
2. Нажмите **Run workflow**
3. Выберите ветку и нажмите **Run workflow**

## Шаг 5: Проверка статуса

После запуска workflow:
1. Перейдите в **Actions** в вашем репозитории
2. Выберите запущенный workflow
3. Следите за прогрессом выполнения

После успешной загрузки:
1. Перейдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Выберите ваше приложение
3. Перейдите в **TestFlight** или **App Store** → **Versions**
4. Вы увидите новую версию, загруженную через CI/CD

## Альтернативный вариант: Использование сертификатов

Если вы предпочитаете использовать сертификаты напрямую (файл `ios-publish.yml`):

1. Экспортируйте сертификат из Keychain:
   ```bash
   security find-identity -v -p codesigning
   # Найдите ваш сертификат и экспортируйте его
   ```

2. Конвертируйте в base64:
   ```bash
   base64 -i certificate.p12 -o certificate_base64.txt
   ```

3. Добавьте в GitHub Secrets:
   - `BUILD_CERTIFICATE_BASE64`: содержимое certificate_base64.txt
   - `P12_PASSWORD`: пароль от .p12 файла
   - `KEYCHAIN_PASSWORD`: пароль для временного keychain
   - `BUILD_PROVISION_PROFILE_BASE64`: base64 вашего provisioning profile
   - `PROVISIONING_PROFILE_SPECIFIER`: имя provisioning profile

## Устранение проблем

### Ошибка: "No accounts"
- Убедитесь, что `DEVELOPMENT_TEAM` правильно установлен
- Проверьте, что Team ID корректен

### Ошибка: "Invalid API Key"
- Проверьте, что содержимое `.p8` файла скопировано полностью (включая BEGIN/END строки)
- Убедитесь, что Key ID и Issuer ID правильные

### Ошибка: "Provisioning profile not found"
- Для автоматической подписи: убедитесь, что `DEVELOPMENT_TEAM` установлен
- Для ручной подписи: проверьте `PROVISIONING_PROFILE_SPECIFIER`

## Дополнительные ресурсы

- [App Store Connect API Documentation](https://developer.apple.com/documentation/appstoreconnectapi)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [GitHub Actions for iOS](https://github.com/actions/virtual-environments/blob/main/images/macos/macos-14-Readme.md)

