# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# frozen_string_literal: true

lock '3.11.2'

set :user, 'wwwuser'
set :repo_url, 'https://github.com/dapi/daily_car_bot.git' if ENV['USE_LOCAL_REPO'].nil?
set :keep_releases, 10
set :linked_files, %w[config/master.key]
set :linked_dirs, %w[log node_modules tmp/pids tmp/cache tmp/sockets public/qrcodes public/assets public/packs]
set :config_files, fetch(:linked_files)
set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:application)}" }

if ENV.key? 'BRANCH'
  if ENV['BRANCH'] == 'ask'
    ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
  else
    set :branch, ENV['BRANCH']
  end
else
  set :branch, 'master'
end

set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip

set :keep_assets, 2
set :local_assets_dir, 'public'
set :puma_init_active_record, true
set :db_local_clean, false
set :db_remote_clean, true

set :nvm_node, File.read('.nvmrc').strip
set :nvm_map_bins, %w[node npm yarn rake]

set :assets_dependencies,
    %w[
      app/assets lib/assets vendor/assets app/javascript
      yarn.lock Gemfile.lock config/routes.rb config/initializers/assets.rb
      .semver
    ]
