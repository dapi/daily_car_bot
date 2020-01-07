# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

Rails.application.routes.draw do
  default_url_options host: 'dailycar.brandymint.ru', protocol: 'https'
  telegram_webhook TelegramWebhooksController
end
