# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.setup(:deploy)

# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano-db-tasks'
require 'capistrano/shell'
require 'capistrano/puma'
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Workers
# install_plugin Capistrano::Puma::Nginx

# require 'capistrano/rails/assets'
# require 'capistrano/faster_assets'
require 'capistrano/rails/migrations'

require 'capistrano/rails/console'
require 'capistrano/master_key'
