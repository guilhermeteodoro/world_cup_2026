class AddNegotiationFieldsToTrades < ActiveRecord::Migration[8.1]
  def change
    add_column :trades, :user_a_accepted_at, :datetime
    add_column :trades, :user_b_accepted_at, :datetime

    add_column :trade_stickers, :user_sticker_id, :integer
    add_index :trade_stickers, :user_sticker_id

    # Backfill existing confirmed trades: set both accepted_at to confirmed_at
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE trades
          SET user_a_accepted_at = confirmed_at,
              user_b_accepted_at = confirmed_at
          WHERE confirmed_at IS NOT NULL
        SQL
      end
    end
  end
end
