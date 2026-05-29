class CreateCountries < ActiveRecord::Migration[8.1]
  def change
    create_table :countries do |t|
      t.string :code, null: false
      t.string :emoji, null: false
    end

    add_index :countries, :code, unique: true
  end
end
