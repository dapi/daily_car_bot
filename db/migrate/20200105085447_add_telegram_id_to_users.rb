class AddTelegramIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :telegram_id, :integer
    change_column_null :users, :email, true
  end
end
