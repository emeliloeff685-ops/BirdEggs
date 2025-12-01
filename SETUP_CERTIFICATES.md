# Настройка сертификатов для CI/CD

## Текущая ситуация

- ❌ В Keychain нет сертификатов
- ❌ Provisioning profile для старого Bundle ID
- ✅ Нужен новый App Store provisioning profile для: `com.collector.eggscollector.BirdEggs1`

## Решение: Создать сертификаты и профиль

### Шаг 1: Создать/Скачать Distribution сертификат

#### Вариант A: Если сертификат уже есть в Developer Portal

1. Перейдите: https://developer.apple.com/account/resources/certificates/list
2. Найдите **Apple Distribution** сертификат
3. Если его нет - создайте:
   - Нажмите **+**
   - Выберите **Apple Distribution**
   - Следуйте инструкциям (нужен CSR файл)

#### Вариант B: Экспорт из Keychain (если установлен в Xcode)

1. Откройте Xcode
2. Xcode → Settings → Accounts
3. Выберите ваш Apple ID
4. Выберите команду (Team)
5. Нажмите **Manage Certificates...**
6. Найдите **Apple Distribution**
7. Правый клик → **Export Certificate...**
8. Сохраните как `.p12` с паролем

### Шаг 2: Создать App Store provisioning profile

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
5. Выберите ваш **Distribution сертификат**
6. Введите **Profile Name**: "Bird Eggs App Store"
7. Нажмите **Generate**
8. Скачайте `.mobileprovision` файл

### Шаг 3: Конвертация в base64

```bash
# Сертификат
base64 -i distribution_cert.p12 -o certificate_base64.txt

# Provisioning profile
base64 -i bird_eggs_appstore.mobileprovision -o profile_base64.txt
```

### Шаг 4: Добавить в GitHub Secrets

https://github.com/emeliloeff685-ops/BirdEggs/settings/secrets/actions

**Секреты:**
1. `BUILD_CERTIFICATE_BASE64` - содержимое certificate_base64.txt
2. `P12_PASSWORD` - пароль от .p12 файла
3. `KEYCHAIN_PASSWORD` - любой пароль (например: `temp123`)
4. `BUILD_PROVISION_PROFILE_BASE64` - содержимое profile_base64.txt

## Быстрый способ через скрипт

Если у вас есть сертификат, я могу помочь добавить его в GitHub Secrets автоматически.

---

## Альтернатива: Использовать старый Bundle ID

Если создание нового профиля занимает время, можно временно:
1. Вернуть Bundle ID на `com.collector.eggscollector.BirdEggs`
2. Использовать существующий provisioning profile
3. Позже перейти на новый Bundle ID

Но это не рекомендуется, так как приложение уже создано с новым Bundle ID.

