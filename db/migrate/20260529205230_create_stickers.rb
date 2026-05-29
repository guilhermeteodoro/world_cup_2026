class CreateStickers < ActiveRecord::Migration[8.1]
  def change
    create_table :stickers do |t|
      t.references :country, null: false, foreign_key: true
      t.string :number, null: false
      t.integer :category, null: false
      t.integer :position, null: false
    end

    add_index :stickers, :position, unique: true
    add_index :stickers, [:country_id, :number], unique: true
    add_index :stickers, :category
  end
end
