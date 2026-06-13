class AddTradeIdToUserStickers < ActiveRecord::Migration[8.1]
  def change
    add_reference :user_stickers, :trade, null: true, foreign_key: true
  end
end
