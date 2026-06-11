# frozen_string_literal: true

# == Schema Information
#
# Table name: trade_stickers
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  giver_id        :integer          not null
#  receiver_id     :integer          not null
#  sticker_id      :integer          not null
#  trade_id        :integer          not null
#  user_sticker_id :integer
#
# Indexes
#
#  index_trade_stickers_on_giver_id                 (giver_id)
#  index_trade_stickers_on_receiver_id              (receiver_id)
#  index_trade_stickers_on_sticker_id               (sticker_id)
#  index_trade_stickers_on_trade_id                 (trade_id)
#  index_trade_stickers_on_trade_id_and_sticker_id  (trade_id,sticker_id) UNIQUE
#  index_trade_stickers_on_user_sticker_id          (user_sticker_id)
#
# Foreign Keys
#
#  giver_id     (giver_id => users.id)
#  receiver_id  (receiver_id => users.id)
#  sticker_id   (sticker_id => stickers.id)
#  trade_id     (trade_id => trades.id)
#
class TradeSticker < ApplicationRecord
  belongs_to :trade
  belongs_to :sticker
  belongs_to :giver, class_name: "User"
  belongs_to :receiver, class_name: "User"
  belongs_to :user_sticker, optional: true

  validates :sticker_id, uniqueness: { scope: :trade_id }

  scope :search, ->(country_code: nil, number: nil, giver: nil) do
    params = {}
    params[:stickers] = { number: } if number
    params[:countries] = { code: country_code } if country_code
    params[:giver] = giver if giver

    joins(sticker: :country).where(**params)
  end

  # Confirm receipt: soft-delete giver's copy, create to_be_glued for receiver
  def confirm_receipt!
    transaction do
      user_sticker&.discard!

      # Create to_be_glued row for receiver
      UserSticker.create!(
        user: receiver,
        sticker: sticker,
        state: :to_be_glued
      )
    end
  end
end
