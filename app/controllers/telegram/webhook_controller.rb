class Telegram::WebhookController < Telegram::Bot::UpdatesController
  #include Telegram::Bot::UpdatesController::Session
  #include Telegram::Bot::UpdatesController::MessageContext
  #include Telegram::Bot::UpdatesController::CallbackQueryContext

  #rescue_from StandardError, with: :handle_error

  #use_session!

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
    respond_with :message, text: multiline( 'Привет! Я помогаю вести журнал обслуживания личного авто', nil, nil, help_message )
  end

  def help!(*)
    respond_with :message, text: help_message
  end

  private

  def help_message
    multiline(
      '/help - Эта подсказка',
      '/projects - Список проектов',
      '/attach {projects_slug} - Указать проект этого чата',
      '/add {project_slug} {hours} {comment} - Отметить время',
      '/new {project_slug} - Создать новый проект',
      '/report - Детальный по команды и проектам',
      '/summary {week|summary}- Сумарное за период',
      '/attach {project_slug} - Присоеденить текущий чат к проекту'
    )
  end

  def multiline(*args)
    args.flatten.map(&:to_s).join("\n")
  end

  def code(text)
    multiline '```', text, '```'
  end

  def logger
    Rails.application.config.telegram_updates_controller.logger
  end

  # In this case session will persist for user only in specific chat.
  # Same user in other chat will have different session.
  def session_key
    "#{bot.username}:#{chat['id']}:#{from['id']}" if chat && from
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
