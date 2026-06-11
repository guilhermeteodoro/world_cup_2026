# frozen_string_literal: true

class AddReceiptConfirmationFields < ActiveRecord::Migration[8.1]
  def change
    add_column :trade_stickers, :confirmed_at, :datetime
    add_column :trades, :user_a_receipt_ended_at, :datetime
    add_column :trades, :user_b_receipt_ended_at, :datetime
  end
end
