# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
