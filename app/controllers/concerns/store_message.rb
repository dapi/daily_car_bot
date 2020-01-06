module StoreMessage
  private

  def store_message(message)
    attrs = {
      telegram_message_id: telegram_message_id,
      telegram_date: telegram_date
    }

    message_text = message['text']

    # Сохраняем только текстовые сообщения не нужно нам базу забивать картинками всякими,
    # пусть лежат в истории чата
    #
    return if message_text.blank?

    splitted_message = message_text.split
    value = splitted_message.first.presence
    extra_text = splitted_message.drop(1).join ' '

    if value_numeric? value
      if extra_text.present?
        attrs.merge! value: value, text: extra_text, kind: :spending
      else
        attrs.merge! value: value, kind: :mileage
      end
    else
      attrs.merge! text: message_text
    end

    current_user.messages.create! attrs
  end

  # rubocop:disable Style/MultipleComparison
  def value_numeric?(value)
    value.present? && (value.to_f.to_s == value || value.to_i.to_s == value)
  end
  # rubocop:enable Style/MultipleComparison
end
