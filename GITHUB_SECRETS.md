# GitHub Secrets для CI/CD

## Добавьте следующие секреты в GitHub

Перейдите в ваш репозиторий:
**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### 1. APP_STORE_CONNECT_API_KEY_ID
```
XR6Q7S88HZ
```

### 2. APP_STORE_CONNECT_ISSUER_ID
```
c16a20f8-2d44-4c56-a7bf-d4ef1d92c4cb
```

### 3. APP_STORE_CONNECT_API_KEY_CONTENT
```
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgXKEY7UOEEK138SYc
xSEUluXcadAju2KY7+tH0oQiGfegCgYIKoZIzj0DAQehRANCAASH/P+W27ml2VGt
s6+M34ZgYXjacvCGIxyTdVfgeuqQGGbxLflGJHIK1Nd3Q+sn2rwgRnCER4VHKS5o
FPy/vGJS
-----END PRIVATE KEY-----
```

**ВАЖНО:** Скопируйте ВСЁ содержимое, включая строки `-----BEGIN PRIVATE KEY-----` и `-----END PRIVATE KEY-----`

### 4. DEVELOPMENT_TEAM
```
R6M4TW8QJB
```

## Проверка

После добавления всех секретов:
1. Убедитесь, что все 4 секрета добавлены
2. Проверьте, что значения скопированы полностью (особенно для API_KEY_CONTENT)
3. Запустите workflow через тег или вручную

## Готово!

После добавления секретов вы можете запустить публикацию:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Или через GitHub UI: **Actions** → **Build and Publish iOS App** → **Run workflow**

