class Telegram::WebhookController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::Session
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext
  include CurrentUser
  include TelegramHelpers
  include HandleErrors

  use_session!

  def message(message)
    # message can be also accessed via instance method
    message == self.payload # true
    # store_message(message['tex'])
    respond_with :message, text: 'Я не Алиса, мне нужна конкретика. Жми /help'
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

  def start_message
  %{
Привет, #{current_user.first_name}!

Я – бот-дневник, помогаю вести журнал обслуживания твоего авто. Со мной ты не пропустишь техобслуживание, осмотр, обновление страховки, будешь знать стоимость владения автомобилем и многое другое.

Принцип работы простой: сначала я задам тебе пару вопросов о твоём авто, затем буду периодически напоминать о необходимых мероприятиях. А ты, периодически, не забывай скидывать в этот чат пробег своего авто, а также стоимость и название запчастей и услуг. Скидывай сюда все, что считаешь имеет отношение к твоему авто: текстовые сообщения, звуковые записи, фото (например чеки) и видео. Таким образом ты будешь знать где хранится информация о твоем авто.

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
