class AddInsuranceEndDateToCars < ActiveRecord::Migration[6.0]
  def change
    add_column :cars, :insurance_end_date, :date
  end
end
