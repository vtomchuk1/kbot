# Kbot

Kbot — це простий Telegram-бот, створений на мові Go з використанням бібліотеки [Cobra](https://github.com/spf13/cobra) для CLI та [telebot](https://github.com/yanzay/telebot) для взаємодії з API Telegram.

Бот вміє відповідати на повідомлення користувачів та обробляти команду `/start`.

### 🛠️ CI/CD & GitOps Workflow

```mermaid
graph TD
    %% Стилі для блоків
    classDef developer fill:#e1f5fe,stroke:#0288d1,stroke-width:2px;
    classDef github fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px;
    classDef action fill:#fff3e0,stroke:#f57c00,stroke-width:2px;
    classDef registry fill:#e8f5e9,stroke:#388e3c,stroke-width:2px;
    classDef cluster fill:#ffebee,stroke:#c62828,stroke-width:2px;

    %% Опис життєвого циклу
    Dev[💻 Розробник: Push у develop]:::developer -->|Trigger| GH(🐙 GitHub: KBOT-CICD):::github

    subgraph GitHub Actions: Job CI
        GH --> CI_Check[1. Checkout репозиторію]:::action
        CI_Check --> CI_Test[2. Run Tests: make test]:::action
        CI_Test --> CI_Auth[3. Login to GHCR.io]:::action
        CI_Auth --> CI_Build[4. Build & Push Image: make image push]:::action
    end

    CI_Build -->|Upload Image| GHCR(📦 GitHub Packages: ghcr.io):::registry

    subgraph GitHub Actions: Job CD (needs: CI)
        CI_Build -->|Success| CD_Check[1. Checkout репозиторію]:::action
        CD_Check --> CD_Ver[2. Генерація версії по SHA комміту]:::action
        CD_Ver --> CD_YQ[3. Оновлення helm/values.yaml через yq]:::action
        CD_YQ --> CD_Commit[4. Git Commit & Push від імені github.actor]:::action
    end

    CD_Commit -->|Push інфраструктурних змін| GH

    %% Блок GitOps (Argo CD)
    GH -.->|Webhook / Polling| Argo[🐙 Argo CD Controller]:::cluster
    
    subgraph К3d Локальний Кластер
        Argo -->|Порівняння стану| Sync{Маніфести збігаються?}:::cluster
        Sync -->|Ні: OutOfSync| Deploy[Застосування оновленого helm/values.yaml]:::cluster
        Sync -->|Так: Synced| Fine[Кластер в актуальному стані]:::cluster
        Deploy -->|Pull Image| GHCR
        Deploy --> Kbot[🤖 Оновлений Kbot Pod]:::cluster
    end
```

## Вимоги

Перед запуском переконайтеся, що у вас встановлено:
* **Go** (версії 1.20 або вище)
* **Git**
* Активний токен бота від **BotFather** у Telegram.


## Встановлення та запуск

1. **Клонуйте репозиторій** (або перейдіть у папку проекту):
    ```bash
    git clone https://github.com/vtomchuk1/kbot.git
    cd kbot

22. **Запустіть збірку**
    ```bash
    make build

## Встановлення та запуск (вручну)

1. **Клонуйте репозиторій** (або перейдіть у папку проекту):
    ```bash
    git clone https://github.com/vtomchuk1/kbot.git
    cd kbot

2. **Ініціалізуйте модулі**
    ```bash
    go mod init 
    go mod tidy

3. **Налаштуйте змінну оточення**
    ```bash
    export TELE_TOKEN="ваш_токен_тут"

4. **Запуск проекту**
    ```bash
    go run main.go kbot