class CreateCars < ActiveRecord::Migration[6.0]
  def change
    create_table :cars, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :model
      t.string :mark
      t.integer :year
      t.string :number
      t.string :vin

      t.timestamps
    end
  end
end
