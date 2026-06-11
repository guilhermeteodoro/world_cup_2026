class AddAutoAgreedAtToTrades < ActiveRecord::Migration[8.1]
  def change
    add_column :trades, :user_a_auto_agreed_at, :datetime
    add_column :trades, :user_b_auto_agreed_at, :datetime
  end
end
