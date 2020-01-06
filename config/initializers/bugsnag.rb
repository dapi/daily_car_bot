# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = Rails.application.credentials.bugsnag_api_key
    config.app_version = AppVersion.format('%M.%m.%p') # rubocop:disable Style/FormatStringToken
    config.send_code = true
    config.send_environment = true
  end
end
