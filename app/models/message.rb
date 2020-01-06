# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

class Message < ApplicationRecord
  belongs_to :user
  enum kind: %i[other mileage spending], _prefix: true

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
