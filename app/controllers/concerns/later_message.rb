# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

module LaterMessage
  extend ActiveSupport::Concern

  included do
    # after_action вызывается уже после того как в телеграм ушет ответ от action.
    # Это хороший способ послать еще одно сообщение, например с вопросом после ответа.
    after_action do
      if @later_message.present?
        SendMessageJob
          .set(wait: @later_wait)
          .perform_later from['id'], text: @later_message, parse_mode: :Markdown
      end
    end
  end

  private

  def later_message(message, wait = 2.seconds)
    @later_message = message
    @later_wait = wait
  end
end
