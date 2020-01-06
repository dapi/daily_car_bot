# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include CurrentUser
  include TelegramHelpers
  include HandleErrors

  # after_action вызывается уже после того как в телеграм ушет ответ от action.
  # Это хороший способ послать еще одно сообщение, например с вопросом после ответа.
  after_action do
    if @later_message.present?
      SendMessageJob
        .set(wait: @later_wait || 2.seconds)
        .perform_later from['id'], text: @later_message, parse_mode: :Markdown
    end
  end

  def message(message)
    stored_message = store_message message
    respond_with :message, text: "Понятно, так и запишем: #{stored_message.humanized}"
  end

  def set_next_maintenance!(mileage)
    current_car.update! next_maintenance_mileage: mileage
    @later_message = 'Вопросы закончились. Дай команду /info чтобы посмотреть что я знаю о твоём авто'
    respond_with :message, text: maintenance_message, parse_mode: :Markdown
  end

  def info!(*)
    respond_with :message, text: info_message, parse_mode: :Markdown
  end

  def set_mileage!(mileage)
    mileage = mileage.to_f
    current_user.messages.create!(
      value: mileage,
      kind: :mileage,
      telegram_message_id: telegram_message_id,
      telegram_date: telegram_date
    )
    current_car.update! current_mileage: mileage
    save_context :set_next_maintenance!
    @later_message = t('.next_maintenance_question')
    respond_with :message, text: t('.success', car: current_car), parse_mode: :Markdown
  end

  def set_insurance_date!(date)
    current_car.update! insurance_end_date: date == '0' ? nil : Date.parse(date)
    save_context :set_mileage!
    @later_message = t('.mileage_question')
    respond_with :message, text: t('.success', car: current_car), parse_mode: :Markdown
  end

  def set_number!(number = nil)
    current_car.update! number: number == '0' ? nil : number
    save_context :set_insurance_date!
    @later_message = t('.insurance_question')
    respond_with :message, text: t('.success', car: current_car), parse_mode: :Markdown
  end

  def set_car!(model = nil, mark = nil, year = nil)
    if model.present? && mark.present? && year.present?
      if current_car.present?
        current_car.update model: model, mark: mark, year: year
      else
        current_user.create_car! model: model, mark: mark, year: year
      end

      save_context :set_number!
      @later_message = t('.number_question')
      respond_with :message, text: t('.success', car: current_car), parse_mode: :Markdown
    else
      save_context :set_car!
      respond_with :message, text: t('.wrong'), parse_mode: :Markdown
    end
  end

  def start!(*)
    # TODO if current_car.present?
    save_context :set_car!
    @later_wait = 5.seconds
    @later_message = t('.car_question')
    respond_with :message, text: t('.response', user: current_user), parse_mode: :Markdown
  end

  private

  def logger
    Rails.application.config.telegram_updates_controller.logger
  end

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

  def value_numeric?(value)
    value.present? && (value.to_f.to_s == value || value.to_i.to_s == value)
  end

  def maintenance_message
    "Спасибо, значит следующее ТО будет через #{current_car.next_maintenance_mileage_distance} км. Будем ждать!"
  end

  def info_message
    return 'Я пока ничего не знаю о твоём автомобиле' if current_car.blank?

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

  def telegram_message_id
    return 0 if Rails.env.test?
    payload['message_id'] || raise('No message_id')
  end

  def telegram_date
    return Date.today if Rails.env.test?
    raise 'No date' unless payload.key? 'date'
    Time.zone.at(payload['date']).to_datetime
  end
end
