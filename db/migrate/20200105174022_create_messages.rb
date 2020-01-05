class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.decimal :value
      t.string :text
      t.integer :kind, null: false, default: 0
      t.integer :telegram_message_id, null: false
      t.timestamp :telegram_date, null: false

      t.timestamps
    end
  end
end
