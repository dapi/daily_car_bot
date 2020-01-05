Rails.application.routes.draw do
  telegram_webhook WebhookController unless Rails.env.test?
end
