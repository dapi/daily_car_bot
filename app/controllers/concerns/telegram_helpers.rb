# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

module TelegramHelpers
  private

  def telegram_message_id
    return 0 if Rails.env.test?
    payload['message_id'] || raise('No message_id')
  end

  def telegram_date
    return Date.today if Rails.env.test?
    raise 'No date' unless payload.key? 'date'
    Time.zone.at(payload['date']).to_datetime
  end

  def multiline(*args)
    args.flatten.map(&:to_s).join("\n")
  end

  def code(text)
    multiline '```', text, '```'
  end
end
