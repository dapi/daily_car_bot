# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

class AddInsuranceEndDateToCars < ActiveRecord::Migration[6.0]
  def change
    add_column :cars, :insurance_end_date, :date
  end
end
