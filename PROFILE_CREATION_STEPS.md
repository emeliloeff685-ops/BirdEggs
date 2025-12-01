# Пошаговая инструкция создания Provisioning Profile

## Шаг 1: Выбор типа профиля

1. Перейдите: https://developer.apple.com/account/resources/profiles/list
2. Нажмите **"+"** (Create a new profile)
3. Выберите **"App Store"** → **Continue**
   - ⚠️ НЕ выбирайте "iOS App Development" или "Ad Hoc"
   - ✅ Выберите именно **"App Store"**

## Шаг 2: Выбор App ID

1. В списке App IDs найдите: **`com.collector.eggscollector.BirdEggs1`**
2. Выберите его (отметьте галочкой)
3. Нажмите **Continue**

   - Если его нет в списке:
     - Нажмите **"+"** рядом с App IDs
     - Или перейдите: https://developer.apple.com/account/resources/identifiers/list
     - Нажмите **"+"** → **"App IDs"** → **Continue**
     - Bundle ID: `com.collector.eggscollector.BirdEggs1`
     - Capabilities: оставьте по умолчанию (можно ничего не выбирать)
     - Нажмите **Continue** → **Register**
     - Вернитесь к созданию профиля

## Шаг 3: Выбор сертификата

1. В списке сертификатов найдите ваш **Distribution сертификат**
2. Обычно он называется: **"Apple Distribution: [Ваше имя]"**
3. Выберите его (отметьте галочкой)
4. Нажмите **Continue**

   - ⚠️ НЕ выбирайте "Apple Development" сертификаты
   - ✅ Выберите именно **"Apple Distribution"**

## Шаг 4: Имя профиля

1. Введите **Profile Name**: `Bird Eggs App Store v1`
   - Или любое другое понятное имя
2. Нажмите **Generate**

## Шаг 5: Скачивание

1. После генерации нажмите **Download**
2. Сохраните файл `.mobileprovision` в Downloads

---

## Визуальная схема:

```
Create Profile
    ↓
[ ] iOS App Development
[✓] App Store          ← ВЫБЕРИТЕ ЭТО
[ ] Ad Hoc
[ ] Enterprise
    ↓
App ID:
[✓] com.collector.eggscollector.BirdEggs1  ← ВЫБЕРИТЕ ЭТО
    ↓
Certificates:
[✓] Apple Distribution: [Ваше имя]  ← ВЫБЕРИТЕ ЭТО
    ↓
Profile Name: Bird Eggs App Store v1
    ↓
Generate → Download
```

---

## Важные моменты:

- ✅ Тип: **App Store**
- ✅ App ID: **com.collector.eggscollector.BirdEggs1**
- ✅ Certificate: **Apple Distribution** (не Development!)
- ✅ Profile Name: любое понятное имя

