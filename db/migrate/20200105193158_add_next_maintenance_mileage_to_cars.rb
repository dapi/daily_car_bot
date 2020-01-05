class AddNextMaintenanceMileageToCars < ActiveRecord::Migration[6.0]
  def change
    add_column :cars, :next_maintenance_mileage, :integer
    add_column :cars, :current_mileage, :integer
  end
end
