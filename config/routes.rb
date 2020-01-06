# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

Rails.application.routes.draw do
  telegram_webhook WebhookController
end
