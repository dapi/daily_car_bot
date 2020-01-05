class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(chat_id, text:, parse_mode: nil)
    Telegram.bot.send_message(chat_id: chat_id, text: text, parse_mode: parse_mode)
  end
end
