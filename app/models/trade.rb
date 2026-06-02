# frozen_string_literal: true

# == Schema Information
#
# Table name: trades
#
#  id           :integer          not null, primary key
#  confirmed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_a_id    :integer          not null
#  user_b_id    :integer          not null
#
# Indexes
#
#  index_trades_on_user_a_id  (user_a_id)
#  index_trades_on_user_b_id  (user_b_id)
#
# Foreign Keys
#
#  user_a_id  (user_a_id => users.id)
#  user_b_id  (user_b_id => users.id)
#
class Trade < ApplicationRecord
  belongs_to :user_a, class_name: "User"
  belongs_to :user_b, class_name: "User"

  has_many :trade_stickers, dependent: :destroy

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :involving, ->(user) { where(user_a: user).or(where(user_b: user)) }

  def confirmed?
    confirmed_at.present?
  end

  def stickers_given_by(user)
    trade_stickers.joins(:sticker).includes(sticker: :country).where(giver: user).order("stickers.position").map(&:sticker)
  end

  def stickers_received_by(user)
    trade_stickers.joins(:sticker).includes(sticker: :country).where(receiver: user).order("stickers.position").map(&:sticker)
  end
end
