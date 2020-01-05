class User < ApplicationRecord
  authenticates_with_sorcery!

  has_one :car
  has_many :messages

  validates :telegram_id, presence: true
end
