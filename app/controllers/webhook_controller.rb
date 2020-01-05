class WebhookController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include CurrentUser
  include TelegramHelpers
  include HandleErrors

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

  def set_next_maintenance!(mileage)
    current_car.update! next_maintenance_mileage: mileage
    save_context :set_next_maintenance!
    respond_with :message, text: maintenance_message, parse_mode: :Markdown
  end

  def set_mileage!(mileage)
    current_user.messages.create!(
      value: mileage,
      kind: :mileage,
      telegram_message_id: payload['message_id'],
      telegram_date: Time.at(payload['date']).to_datetime
    )
    current_car.update! current_mileage: mileage
    save_context :set_next_maintenance!
    respond_with :message, text: mileage_message, parse_mode: :Markdown
  end

  def set_insurance_date!(date)
    current_car.update! insurance_end_date: date == '0' ? nil : Date.parse(date)
    save_context :set_mileage!
    respond_with :message, text: insurance_message, parse_mode: :Markdown
  end

  def set_number!(number = nil)
    current_car.update! number: number == '0' ? nil : number
    save_context :set_insurance_date!
    respond_with :message, text: number_message, parse_mode: :Markdown
  end

  def set_model!(model = nil, mark = nil, year = nil)
    if model.present? && mark.present? && year.present?
      if current_car.present?
        current_car.update model: model, mark: mark, year: year
      else
        current_user.create_car! model: model, mark: mark, year: year
      end

      save_context :set_number!
      respond_with :message, text: car_message, parse_mode: :Markdown
    else
      save_context :set_model!
      respond_with :message,
        text: 'Что-то вы не то мне говорите. Напишите марку, модель и год производства вашего автомобиля. Например: Nissan X-Trail 2010'
    end
  end

  def start!(*)
    # if current_car.present?
    save_context :set_model!
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

Сначала я задам тебе 5 вопросов о твоём авто, а затем расскажу подробнее как со мной общаться.

Поехали, вопрос N1: Напиши через пробел марку, модель и год выпуска твоего авто.

Например:

```
Nissan X-Trail 2010
```
}
  end

  def car_message
    %{
Я запомнил, что ваш автомобиль: #{current_car.humanized}.

Вопрос N2. Напишите регистрационный номер вашего авто без пробелов, так мы сможем сообщать вам о поступащюих штрафах. Например: А123БВ21.
Введите 0, если вы не хотите говорить.
}
  end

  def number_message
    %{
    Я запомнил, что регистрационный номер вашего авто: #{current_car.number}.

    Вопрос N3. Напишите дату окончания действия страховки в формате ЧИСЛО-МЕСЯЦ-ГОД. Например: 31-12-2010. Введите 0, если ее у вас нет или она закончилась.
    }
  end

  def insurance_message
    %{
Понятно, страховка заканчивается #{current_car.insurance_end_date}.

Вопрос N4. Напишите текущий пробег авто в километрах. Например: `65000`
    }
  end

  def mileage_message
    %{
Ага, текущий пробег авто #{current_car.current_mileage} км. Так и запишем.

Последний вопрос, на каком пробеге планируете делать следующее техническое обслуживание? Напишите в километрах. Например: `80000`
    }
  end

  def maintenance_message
    %{
Спасибо, значит следующее ТО будет через #{current_car.next_maintenance_mileage_distance} км. Будем ждать!
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
