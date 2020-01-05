Rails.application.routes.draw do
  telegram_webhook Telegram::WebhookController unless Rails.env.test?
end
