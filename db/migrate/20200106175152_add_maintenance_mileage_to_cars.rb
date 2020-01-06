# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

class AddMaintenanceMileageToCars < ActiveRecord::Migration[6.0]
  def change
    add_column :cars, :maintenance_mileage, :integer
  end
end
