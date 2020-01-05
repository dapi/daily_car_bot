if Rails.env.development?
  require 'openssl'
  OpenSSL::SSL.send :remove_const, 'VERIFY_PEER'
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

Rails.application.config.telegram_updates_controller.logger =
  ActiveSupport::Logger.new( Rails.root.join 'log', 'telegram.log').
  tap { |logger| logger.formatter = AutoLogger::Formatter.new }
