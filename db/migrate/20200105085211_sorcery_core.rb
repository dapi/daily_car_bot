# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

class SorceryCore < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'uuid-ossp'

    create_table :users, id: :uuid, default: -> { 'uuid_generate_v4()' } do |t|
      t.string :email, null: false
      t.string :crypted_password
      t.string :salt

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
