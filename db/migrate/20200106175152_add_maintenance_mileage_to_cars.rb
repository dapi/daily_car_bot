class AddMaintenanceMileageToCars < ActiveRecord::Migration[6.0]
  def change
    add_column :cars, :maintenance_mileage, :integer
  end
end
