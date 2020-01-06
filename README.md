# Дневник автомобилиста

[@CarDayBot](https://t.me/CarDayBot) – телеграм-бот для ведения журнала обслуживания авто. Написан на Ruby On Rails.

[![Build Status](https://travis-ci.org/dapi/car_day_bot.svg?branch=master)](https://travis-ci.org/dapi/car_day_bot)

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
