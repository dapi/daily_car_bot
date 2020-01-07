# Дневник автомобилиста

[@DailyCarBot](https://t.me/DailyCarBot) – телеграм-бот для ведения журнала обслуживания авто. Написан на Ruby On Rails.

[![Build Status](https://travis-ci.org/dapi/daily_car_bot.svg?branch=master)](https://travis-ci.org/dapi/daily_car_bot)

Бот-дневник, помогает вести журнал обслуживания автомобиля. Так ты не пропустишь техобслуживание, осмотр, обновление страховки, будешь знать стоимость владения автомобилем и многое другое.

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
