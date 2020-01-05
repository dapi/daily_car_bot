class WebhookController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::Session
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include CurrentUser
  include TelegramHelpers
  include HandleErrors

  use_session!

  def message(message)
    stored_message = store_message message
    respond_with :message, text: "Понятно, так и запишем: #{stored_message.humanized}"
  end

  def chosen_inline_result(result_id, query)
    respond_with :message, text: 'Неизвестный тип сообщение chosen_inline_result'
  end

  def inline_query(query, offset)
    respond_with :message, text: 'Неизвестный тип сообщение inline_query'
  end

  def callback_query(data)
    edit_message :text, text: "Вы выбрали #{data}"
  end

  def start!(data = nil, *)
    respond_with :message, text: start_message, parse_mode: :Markdown
  end

  private

  def logger
    Rails.application.config.telegram_updates_controller.logger
  end

  def store_message(message)
    attrs = {
      telegram_message_id: message['message_id'],
      telegram_date: Time.at(message['date']).to_datetime
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

  def value_numeric? value
    value.present? && (value.to_f.to_s == value || value.to_i.to_s == value)
  end

  def start_message
  %{
Привет, #{current_user.first_name}!

Я – бот-дневник, помогаю вести журнал обслуживания твоего авто. Со мной ты не пропустишь техобслуживание, осмотр, обновление страховки, будешь знать стоимость владения автомобилем и многое другое.

Сначала я задам тебе 5 вопросов о твоём авто, затем расскажу подробнее как со мной общаться. Погнали!
}
  end

  def help_message
  %{Принцип работы простой: сначала я задам тебе пару вопросов о твоём авто, затем буду периодически напоминать о необходимых мероприятиях. А ты, периодически, не забывай скидывать в этот чат пробег своего авто, а также стоимость и название запчастей и услуг. Скидывай сюда все, что считаешь имеет отношение к твоему авто: текстовые сообщения, звуковые записи, фото (например чеки) и видео. Таким образом ты будешь знать где хранится информация о твоем авто.

Если ты решил отметить пробег, просто пришли цифру в километрах, например:
```142400```

Я пойму твой авто проехал 142 тыс километров и запишу в журнал на текущую дату.

Если ты решил внести траты, то через пробел напиши за что, например:
```
12700 замена шаровой
```
Так я пойму что ты поменял шаровую и это тебе обошлось в 12700 рублей.

Погнали!
}
  end

end
