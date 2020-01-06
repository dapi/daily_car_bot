# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

module HandleErrors
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_error
  end

  def handle_error(error)
    raise error if Rails.env.test?

    Rails.logger.error error
    Rails.logger.error error.backtrace
    respond_with :message, text: "Error: #{error.message}" unless error.is_a? Telegram::Bot::Forbidden
  end
end
