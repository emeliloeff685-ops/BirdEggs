# Устранение проблем с загрузкой в App Store Connect

## Проблема: Билд не появляется в App Store Connect после успешной сборки

### Шаг 1: Проверьте статус workflow в GitHub Actions

1. Перейдите в ваш репозиторий: https://github.com/i1qxa/BirdEggsIOS/actions
2. Откройте последний запущенный workflow
3. Проверьте шаг "Upload to App Store Connect"
4. Посмотрите логи на наличие ошибок

### Шаг 2: Проверьте, что приложение создано в App Store Connect

**ВАЖНО:** Приложение должно быть создано в App Store Connect ДО загрузки билда!

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите в **My Apps**
3. Проверьте, есть ли приложение с Bundle ID: `com.collector.eggscollector.BirdEggs`
4. Если приложения нет:
   - Нажмите **"+"** → **New App**
   - Заполните:
     - **Platform**: iOS
     - **Name**: Bird Eggs (или любое другое имя)
     - **Primary Language**: English
     - **Bundle ID**: com.collector.eggscollector.BirdEggs
     - **SKU**: bird-eggs-001 (уникальный идентификатор)
   - Нажмите **Create**

### Шаг 3: Проверьте API ключ App Store Connect

1. Перейдите в [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Keys** → **App Store Connect API**
2. Убедитесь, что ключ существует и имеет статус **Active**
3. Проверьте права доступа:
   - Должен быть **App Manager** или **Admin**
   - Должен иметь доступ к вашему приложению
4. Проверьте GitHub Secrets:
   - `APP_STORE_CONNECT_API_KEY_ID` - должен совпадать с Key ID
   - `APP_STORE_CONNECT_ISSUER_ID` - должен совпадать с Issuer ID
   - `APP_STORE_CONNECT_API_KEY_CONTENT` - должен содержать полный текст .p8 файла (включая строки `-----BEGIN PRIVATE KEY-----` и `-----END PRIVATE KEY-----`)

### Шаг 4: Проверьте логи загрузки

В логах GitHub Actions ищите следующие ошибки:

#### Ошибка: "App with identifier 'com.collector.eggscollector.BirdEggs' not found"
**Решение:** Создайте приложение в App Store Connect (см. Шаг 2)

#### Ошибка: "Invalid API Key" или "Authentication failed"
**Решение:** 
- Проверьте, что содержимое .p8 файла скопировано полностью
- Убедитесь, что Key ID и Issuer ID правильные
- Проверьте, что ключ не истек

#### Ошибка: "No accounts found"
**Решение:**
- Проверьте, что `DEVELOPMENT_TEAM` установлен в GitHub Secrets
- Убедитесь, что Team ID правильный (10 символов)

#### Ошибка: "The bundle identifier is already in use"
**Решение:** 
- Это нормально, если приложение уже существует
- Убедитесь, что вы используете правильный Bundle ID

### Шаг 5: Где искать загруженный билд

После успешной загрузки билд может появиться в разных местах:

1. **TestFlight** (обычно здесь):
   - App Store Connect → My Apps → Bird Eggs → **TestFlight**
   - Билд появится в разделе **iOS Builds**
   - Может занять 5-15 минут для обработки

2. **App Store** → **Versions**:
   - App Store Connect → My Apps → Bird Eggs → **App Store** → **Versions**
   - Если версия уже создана, билд появится там

3. **Activity**:
   - App Store Connect → My Apps → Bird Eggs → **Activity**
   - Здесь видны все действия, включая загрузки билдов

### Шаг 6: Проверка статуса обработки билда

После загрузки билд проходит обработку:

1. **Processing** - билд загружен, но еще обрабатывается (может занять 10-30 минут)
2. **Ready to Submit** - билд готов к использованию
3. **Invalid** - билд имеет проблемы (проверьте ошибки)

### Шаг 7: Альтернативный метод загрузки (вручную)

Если автоматическая загрузка не работает:

1. Скачайте IPA файл из артефактов GitHub Actions (если доступен)
2. Или соберите локально в Xcode:
   ```bash
   xcodebuild -exportArchive \
     -archivePath BirdEggs.xcarchive \
     -exportPath ./export \
     -exportOptionsPlist exportOptions.plist
   ```
3. Загрузите вручную через:
   - **Xcode**: Window → Organizer → Archives → Distribute App
   - **Transporter app**: Скачайте из App Store и используйте для загрузки IPA

### Шаг 8: Проверка версии билда

Убедитесь, что версия билда увеличивается:

1. В Xcode откройте проект
2. Выберите проект в навигаторе
3. В разделе **General** проверьте:
   - **Version**: 1.0 (MARKETING_VERSION)
   - **Build**: 1 (CURRENT_PROJECT_VERSION)
4. Для каждого нового билда увеличьте **Build** номер

### Частые проблемы и решения

| Проблема | Решение |
|----------|---------|
| Билд не появляется | Проверьте, что приложение создано в App Store Connect |
| Ошибка аутентификации | Проверьте API ключ и его права доступа |
| "App not found" | Создайте приложение в App Store Connect |
| Билд в обработке долго | Подождите 30-60 минут, это нормально |
| Ошибка подписи | Проверьте сертификаты и provisioning profiles |

### Полезные ссылки

- [App Store Connect](https://appstoreconnect.apple.com)
- [GitHub Actions](https://github.com/i1qxa/BirdEggsIOS/actions)
- [App Store Connect API Documentation](https://developer.apple.com/documentation/appstoreconnectapi)

### Контакты для поддержки

Если проблема не решается:
1. Проверьте логи GitHub Actions полностью
2. Проверьте статус в App Store Connect → Activity
3. Обратитесь в поддержку Apple Developer: https://developer.apple.com/contact/

