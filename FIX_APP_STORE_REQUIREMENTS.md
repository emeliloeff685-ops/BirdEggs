# Исправление требований App Store Connect

## Проблемы, которые нужно исправить:

1. ❌ Export compliance information (отсутствует информация о экспорте)
2. ❌ App Privacy practices (не заполнена секция приватности)
3. ❌ Contact Information (не заполнена контактная информация)
4. ❌ Copyright information (не указана информация об авторских правах)

---

## 1. Export Compliance Information

### Где заполнить:
**App Store Connect** → **My Apps** → **Bird Eggs** → **App Store** → **Versions** → выберите версию → **Export Compliance**

### Что нужно сделать:

1. Перейдите в раздел **Export Compliance**
2. Ответьте на вопрос: **"Does your app use encryption?"**
   
   **Для большинства игр ответ: NO**
   - iOS использует стандартное шифрование (HTTPS, App Transport Security)
   - Если ваше приложение не использует собственное шифрование, выберите **NO**
   
   **Если ответ NO:**
   - Нажмите **Save**
   - Готово!

   **Если ответ YES:**
   - Нужно будет заполнить форму экспорта (обычно не требуется для простых игр)

### Рекомендация:
Выберите **NO** (приложение не использует собственное шифрование, только стандартное iOS шифрование)

---

## 2. App Privacy Practices

### Где заполнить:
**App Store Connect** → **My Apps** → **Bird Eggs** → **App Privacy**

### Что нужно сделать:

1. Перейдите в раздел **App Privacy**
2. Нажмите **"Get Started"** или **"Edit"**
3. Ответьте на вопросы о сборе данных:

   **Для игры Bird Eggs (без аналитики, рекламы, покупок):**
   
   - **Do you collect data?** → **NO**
     - Если не собираете данные пользователей, выберите NO
     - Нажмите **Save**
     - Готово!

   **Если собираете данные:**
   - Укажите какие типы данных собираете
   - Укажите цели сбора
   - Укажите используется ли для отслеживания

### Рекомендация:
Выберите **NO** (если приложение не собирает данные пользователей)

---

## 3. Contact Information

### Где заполнить:
**App Store Connect** → **My Apps** → **Bird Eggs** → **App Information** → **Contact Information**

### Что нужно сделать:

1. Перейдите в раздел **App Information**
2. Найдите секцию **Contact Information**
3. Заполните поля:

   **Contact Email:**
   - Email для связи с вами
   - Будет виден пользователям в App Store
   - Пример: `support@youremail.com` или ваш личный email

   **Contact Phone:**
   - Телефон для связи (опционально)
   - Формат: +1 (555) 123-4567

   **Contact URL:**
   - URL вашего сайта (опционально)
   - Пример: `https://yourwebsite.com`

4. Нажмите **Save**

### Минимально требуется:
- **Contact Email** (обязательно)

---

## 4. Copyright Information

### Где заполнить:
**App Store Connect** → **My Apps** → **Bird Eggs** → **App Information** → **Copyright**

### Что нужно сделать:

1. Перейдите в раздел **App Information**
2. Найдите поле **Copyright**
3. Введите copyright информацию:

   **Формат:**
   ```
   Copyright © 2025 Gautham Hariharan. All rights reserved.
   ```

   Или:
   ```
   © 2025 Gautham Hariharan
   ```

   Или если у вас компания:
   ```
   Copyright © 2025 Your Company Name. All rights reserved.
   ```

4. Нажмите **Save**

### Текущий copyright из файла:
```
Copyright © 2025 Gautham Hariharan. All rights reserved.
```

---

## Быстрая проверка всех пунктов:

### ✅ Checklist:

- [ ] **Export Compliance** - заполнен (обычно NO)
- [ ] **App Privacy** - заполнен (обычно NO, если не собираете данные)
- [ ] **Contact Information** - заполнен (минимум email)
- [ ] **Copyright** - заполнен

---

## Порядок действий:

1. **Сначала:** Copyright и Contact Information (быстро)
2. **Затем:** Export Compliance (быстро)
3. **В конце:** App Privacy (может занять больше времени)

---

## После заполнения:

1. Сохраните все изменения
2. Вернитесь в раздел **Versions**
3. Попробуйте снова отправить на ревью
4. Все ошибки должны исчезнуть

---

## Полезные ссылки:

- App Store Connect: https://appstoreconnect.apple.com
- My Apps: https://appstoreconnect.apple.com/apps
- App Privacy: https://appstoreconnect.apple.com/apps/[APP_ID]/app-privacy
- Export Compliance: https://appstoreconnect.apple.com/apps/[APP_ID]/versions/[VERSION_ID]/export-compliance

---

## Примечания:

- Все изменения нужно сохранять кнопкой **Save**
- Некоторые разделы могут обновляться с задержкой (до 24 часов)
- Если ошибки не исчезают, подождите несколько минут и обновите страницу

