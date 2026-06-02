# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string           not null
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_slug   (slug) UNIQUE
#
class User < ApplicationRecord
  has_many :user_stickers, dependent: :delete_all
  has_many :stickers, through: :user_stickers
  has_many :trades_as_a, class_name: "Trade", foreign_key: :user_a_id, dependent: :destroy
  has_many :trades_as_b, class_name: "Trade", foreign_key: :user_b_id, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :generate_slug, on: :create

  def owned_count
    user_stickers.count
  end

  def missing_count
    994 - owned_count
  end

  def duplicates_count
    user_stickers.where("copies > 0").count
  end

  def duplicate_stickers
    stickers.includes(:country).merge(UserSticker.where("copies > 0")).order(:position)
  end

  def missing_stickers
    Sticker.includes(:country).where.not(id: user_stickers.select(:sticker_id)).order(:position)
  end

  def trade_history
    Trade.involving(self).confirmed.order(confirmed_at: :desc).map do |trade|
      TradeParticipation.new(
        trade_id: trade.id,
        other_user: trade.user_a_id == id ? trade.user_b : trade.user_a,
        given: trade.stickers_given_by(self),
        received: trade.stickers_received_by(self),
        confirmed_at: trade.confirmed_at
      )
    end
  end

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug ||= SecureRandom.alphanumeric(8).downcase
  end
end
