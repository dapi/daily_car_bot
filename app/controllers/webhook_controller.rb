class WebhookController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include CurrentUser
  include TelegramHelpers
  include HandleErrors

  # after_action вызывается уже после того как в телеграм ушет ответ от action.
  # Это хороший способ послать еще одно сообщение, например с вопросом после ответа.
  after_action do
    SendMessageJob.set(wait: @later_wait || 2.seconds).perform_later from['id'], text: @later_message, parse_mode: :Markdown if @later_message.present?
  end

  def message(message)
    stored_message = store_message message
    respond_with :message, text: "Понятно, так и запишем: #{stored_message.humanized}"
  end

  def set_next_maintenance!(mileage)
    current_car.update! next_maintenance_mileage: mileage
    @later_message = "Вопросы закончились. Дай команду /info чтобы посмотреть что я знаю о твоём авто"
    respond_with :message, text: maintenance_message, parse_mode: :Markdown
  end

  def info!(*)
    respond_with :message, text: info_message, parse_mode: :Markdown
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
    @later_message = next_maintenance_question
    respond_with :message, text: mileage_message, parse_mode: :Markdown
  end

  def set_insurance_date!(date)
    current_car.update! insurance_end_date: date == '0' ? nil : Date.parse(date)
    save_context :set_mileage!
    @later_message = mileage_question
    respond_with :message, text: insurance_message, parse_mode: :Markdown
  end

  def set_number!(number = nil)
    current_car.update! number: number == '0' ? nil : number
    save_context :set_insurance_date!
    @later_message = insurance_question
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
      @later_message = number_question
      respond_with :message, text: car_message, parse_mode: :Markdown
    else
      save_context :set_model!
      respond_with :message,
        text: 'Что-то вы не то мне говорите. Напишите марку, модель и год производства вашего автомобиля. Например: `Nissan X-Trail 2010`'
    end
  end

  def start!(*)
    # if current_car.present?
    save_context :set_model!
    @later_wait = 5.seconds
    @later_message = car_question
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

Для начала я задам тебе 5 вопросов о твоём авто: марку, модель и год производства, регистрационный номер, текущий пробег, следующее ТО и дату окончания страховки. Поехали!
}
  end

  def car_question
    "Напиши через пробел марку, модель и год выпуска твоего авто. Например: `Nissan X-Trail 2010`"
  end

  def car_message
   "Отлично! Теперь я знаю что у тебя #{current_car.humanized}."
  end

  def number_question
    "Вопрос 2 из 5. Напиши регистрационный номер авто без пробелов, так я смогу сообщать о поступащюих штрафах. Например: `А123БВ21`"
  end

  def number_message
    "Регистрационный номер автомобиля: #{current_car.number}."
  end

  def insurance_question
    "Вопрос 3 из 5. Напиши дату окончания действия текущей страховки в формате ЧИСЛО-МЕСЯЦ-ГОД. Например: `31-12-2010`. Введи 0, если её нет или она закончилась."
  end

  def insurance_message
    "Понятно, страховка заканчивается #{l current_car.insurance_end_date}."
  end

  def mileage_question
    "Вопрос 4 из 5 (предпоследний). Напишите текущий пробег авто в километрах. Например: `65000`"
  end

  def mileage_message
    "Ага, текущий пробег авто #{current_car.current_mileage} км. Так и запишем."
  end

  def next_maintenance_question
    "Последний вопрос, на каком пробеге планируется делать следующее Техническое Обслуживание? Напиши в километрах. Например: `80000`"
  end

  def maintenance_message
    "Спасибо, значит следующее ТО будет через #{current_car.next_maintenance_mileage_distance} км. Будем ждать!"
  end

  def info_message
    return 'Я пока ничего не знаю о твоём автомобиле' unless current_car.present?
    %{
Марка: #{current_car.mark}
Модель: #{current_car.model}
Год выпуска: #{current_car.year}
---
Текущий пробег: #{current_car.current_mileage || '???'} км
Следующее ТО: #{current_car.next_maintenance_mileage || '???'} км (#{current_car.next_maintenance_mileage_distance || '???'} км)
Страховка заканчивается: #{current_car.insurance_end_date || '???'}
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
