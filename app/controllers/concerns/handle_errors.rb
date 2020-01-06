# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

module HandleErrors
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_error
  end

  def handle_error(error)
    case error
    when Telegram::Bot::Forbidden
      logger.error(error)
    else # ActiveRecord::ActiveRecordError for example
      logger.error error
      respond_with :message, text: "Error: #{error.message}"
    end
  end
end
