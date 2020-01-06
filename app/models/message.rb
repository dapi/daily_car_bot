# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

class Message < ApplicationRecord
  belongs_to :user
  enum kind: { other: 0, mileage: 1, spending: 2 }, _prefix: true

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
