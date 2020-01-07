# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

set :application, 'dailycar.brandymint.ru'
set :stage, :production
set :rails_env, :production
fetch(:default_env)[:rails_env] = :production

server 'dailycar.brandymint.ru',
       user: fetch(:user),
       port: '22',
       roles: %w[web app db bugsnag].freeze,
       ssh_options: { forward_agent: true }
