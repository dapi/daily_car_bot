# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application
