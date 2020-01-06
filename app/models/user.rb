# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :cars, dependent: :delete_all
  has_one :car, dependent: :delete
  has_many :messages, dependent: :delete_all

  validates :telegram_id, presence: true
end
