class AddDeletedAtToAllTables < ActiveRecord::Migration[8.1]
  def change
    add_column :countries, :deleted_at, :datetime
    add_column :stickers, :deleted_at, :datetime
    add_column :users, :deleted_at, :datetime
    add_column :user_stickers, :deleted_at, :datetime
    add_column :trades, :deleted_at, :datetime
    add_column :trade_stickers, :deleted_at, :datetime

    add_index :countries, :deleted_at
    add_index :stickers, :deleted_at
    add_index :users, :deleted_at
    add_index :user_stickers, :deleted_at
    add_index :trades, :deleted_at
    add_index :trade_stickers, :deleted_at
  end
end
