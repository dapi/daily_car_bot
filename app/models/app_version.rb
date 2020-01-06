# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# frozen_string_literal: true

require 'semver'
AppVersion = SemVer.find

# Deployed version has ./REVISION file in root directory
#
revision = Rails.root.join('REVISION')
AppVersion.metadata = File.read(revision).chomp if File.exist? revision
