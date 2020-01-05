Rails.application.config.telegram_updates_controller.session_store = :file_store, './tmp/session_store'

Rails.application.config.telegram_updates_controller.logger =
  ActiveSupport::Logger.new( Rails.root.join 'log', 'telegram.log').
  tap { |logger| logger.formatter = AutoLogger::Formatter.new }
