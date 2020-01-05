class Message < ApplicationRecord
  belongs_to :user
  enum status: [ :other, :mileage, :spend], _prefix: true
end
