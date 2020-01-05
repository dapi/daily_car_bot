class Message < ApplicationRecord
  belongs_to :user
  enum kind: [ :other, :mileage, :spending], _prefix: true

  def humanized
    case kind
    when 'mileage'
      "Текущий пробег #{value} км"
    when 'spending'
      "Затраты #{value} руб. (#{text})"
    else
      text
    end
  end
end
