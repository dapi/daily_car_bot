# Дневник автомобилиста

Телеграм-бот для ведения журнала обслуживания авто. Написан на Ruby On Rails.

[@car_logger_bot](https://t.me/car_logger_bot)

## Зависимости

* Postgresql >= 9.0
* Redis >= 3.0

## Установка

* Получите telegram token в bot father
* Пропишите token через `rails credentials:edit` в `telegram.bot`

## Запуск

```bash
bundle
bundle exec rake db:setup
bundle exec rake telegram:bot:poller
```
