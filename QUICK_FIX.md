# Быстрое решение проблемы с подписью

## Проблема
Автоматическая подпись не работает в GitHub Actions без Apple ID. Нужны сертификаты.

## Решение (2 варианта)

### Вариант 1: Добавить сертификаты (рекомендуется)

**Шаг 1:** Создайте/скачайте Distribution сертификат
- Xcode → Settings → Accounts → Manage Certificates → + → Apple Distribution
- Или: https://developer.apple.com/account/resources/certificates/list

**Шаг 2:** Экспортируйте сертификат (.p12)
- Keychain Access → login → My Certificates → Apple Distribution
- Раскройте → выберите ключ → Export 2 items → сохраните с паролем

**Шаг 3:** Создайте App Store provisioning profile
- https://developer.apple.com/account/resources/profiles/list
- + → App Store → Bundle ID: `com.collector.eggscollector.BirdEggs1`
- Скачайте .mobileprovision

**Шаг 4:** Конвертируйте в base64
```bash
base64 -i certificate.p12 -o cert.txt
base64 -i profile.mobileprovision -o profile.txt
```

**Шаг 5:** Добавьте в GitHub Secrets
- https://github.com/emeliloeff685-ops/BirdEggs/settings/secrets/actions
- `BUILD_CERTIFICATE_BASE64` = содержимое cert.txt
- `P12_PASSWORD` = пароль от .p12
- `KEYCHAIN_PASSWORD` = любой пароль (например: `temp123`)
- `BUILD_PROVISION_PROFILE_BASE64` = содержимое profile.txt

### Вариант 2: Использовать старый Bundle ID (временно)

Если создание профиля занимает время, можно временно:
1. Вернуть Bundle ID на `com.collector.eggscollector.BirdEggs`
2. Использовать существующий provisioning profile
3. Позже перейти на новый Bundle ID

**Но это не рекомендуется**, так как приложение уже создано с новым Bundle ID.

---

## После добавления сертификатов

Сборка будет работать автоматически. Workflow уже настроен для использования сертификатов из Secrets.

