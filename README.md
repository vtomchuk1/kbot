# Kbot

Kbot — це простий Telegram-бот, створений на мові Go з використанням бібліотеки [Cobra](https://github.com/spf13/cobra) для CLI та [telebot](https://github.com/yanzay/telebot) для взаємодії з API Telegram.

Бот вміє відповідати на повідомлення користувачів та обробляти команду `/start`.

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