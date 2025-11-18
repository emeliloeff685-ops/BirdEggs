# Быстрый старт CI/CD

## Минимальная настройка (5 минут)

### 1. Создайте App Store Connect API ключ

1. [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Keys** → **App Store Connect API**
2. **Generate API Key** → Сохраните Key ID, Issuer ID и скачайте `.p8` файл

### 2. Добавьте секреты в GitHub

**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Добавьте:
- `APP_STORE_CONNECT_API_KEY_ID` = ваш Key ID
- `APP_STORE_CONNECT_ISSUER_ID` = ваш Issuer ID  
- `APP_STORE_CONNECT_API_KEY_CONTENT` = содержимое `.p8` файла (весь текст)
- `DEVELOPMENT_TEAM` = ваш Team ID (10 символов)

### 3. Обновите exportOptions.plist

Замените `YOUR_TEAM_ID` на ваш Team ID

### 4. Запустите публикацию

```bash
git tag v1.0.0
git push origin v1.0.0
```

Или через GitHub UI: **Actions** → **Run workflow**

## Готово! 🎉

Приложение автоматически соберётся и загрузится в App Store Connect.

Подробная документация: [CI_SETUP.md](./CI_SETUP.md)

