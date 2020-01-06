# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

class Car < ApplicationRecord
  belongs_to :user

  def humanized
    [mark, model, year].join(' ') + ' года'
  end

  def next_maintenance_mileage_distance
    return '?' if next_maintenance_mileage.nil? || current_mileage.nil?

    next_maintenance_mileage - current_mileage
  end
end
