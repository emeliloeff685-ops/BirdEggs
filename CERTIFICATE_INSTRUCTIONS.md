# Инструкция по созданию сертификата

## ✅ Шаг 1: CSR файл создан

CSR файл уже создан и находится здесь:
- **CSR файл:** `certificates/certificate_request.csr`
- **Приватный ключ:** `certificates/private_key.key` (⚠️ НЕ УДАЛЯЙТЕ!)

## 📋 Шаг 2: Загрузка CSR в Apple Developer Portal

1. Откройте в браузере: https://developer.apple.com/account/resources/certificates/list
2. Нажмите кнопку **"+"** (Create a new certificate)
3. Выберите **"Apple Distribution"**
4. Нажмите **"Continue"**
5. Нажмите **"Choose File"** и выберите файл: `certificates/certificate_request.csr`
6. Нажмите **"Continue"**
7. Скачайте созданный сертификат (`.cer` файл)

## 📥 Шаг 3: Экспорт сертификата в .p12

После скачивания `.cer` файла, запустите:

```bash
./scripts/export-certificate.sh ~/Downloads/certificate.cer
```

(Замените путь на реальный путь к скачанному файлу)

Скрипт попросит ввести пароль для `.p12` файла - **запомните его**, он понадобится для GitHub Secrets.

## 🔐 Шаг 4: Подготовка для GitHub Secrets

После создания `.p12` файла:

```bash
# Конвертируйте .p12 в base64
base64 -i certificates/certificate.p12 -o certificates/certificate_base64.txt
```

## 📝 Шаг 5: Добавление в GitHub Secrets

Перейдите в **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Добавьте следующие секреты:

1. **BUILD_CERTIFICATE_BASE64**
   - Значение: содержимое файла `certificates/certificate_base64.txt`
   - Скопируйте весь текст из файла

2. **P12_PASSWORD**
   - Значение: пароль, который вы ввели при создании `.p12` файла

3. **KEYCHAIN_PASSWORD**
   - Значение: любой случайный пароль (например: `ci-keychain-password-123`)

4. **BUILD_PROVISION_PROFILE_BASE64**
   - См. инструкции ниже для получения provisioning profile

## 📱 Шаг 6: Создание Provisioning Profile

1. Откройте: https://developer.apple.com/account/resources/profiles/list
2. Нажмите **"+"** (Create a new profile)
3. Выберите **"App Store"** под **Distribution**
4. Нажмите **"Continue"**
5. Выберите ваш App ID: `com.collector.eggscollector.BirdEggs`
   - Если его нет, создайте новый App ID
6. Нажмите **"Continue"**
7. Выберите созданный сертификат (Apple Distribution)
8. Нажмите **"Continue"**
9. Введите имя профиля (например: "BirdEggs App Store")
10. Нажмите **"Generate"**
11. Скачайте `.mobileprovision` файл

## 📦 Шаг 7: Конвертация Provisioning Profile

```bash
# Конвертируйте .mobileprovision в base64
base64 -i ~/Downloads/profile.mobileprovision -o certificates/profile_base64.txt
```

Добавьте содержимое `certificates/profile_base64.txt` в GitHub Secret **BUILD_PROVISION_PROFILE_BASE64**.

## ✅ Готово!

После добавления всех секретов, следующая сборка в GitHub Actions будет использовать ручную подпись с вашими сертификатами.

