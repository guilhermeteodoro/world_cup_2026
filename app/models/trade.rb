# frozen_string_literal: true

# == Schema Information
#
# Table name: trades
#
#  id                 :integer          not null, primary key
#  confirmed_at       :datetime
#  user_a_accepted_at :datetime
#  user_b_accepted_at :datetime
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_a_id          :integer          not null
#  user_b_id          :integer          not null
#
# Indexes
#
#  index_trades_on_user_a_id   (user_a_id)
#  index_trades_on_user_b_id   (user_b_id)
#  index_trades_on_deleted_at  (deleted_at)
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

  scope :involving, ->(user) { where(user_a: user).or(where(user_b: user)) }
  scope :between, ->(user_a, user_b) {
    where(user_a: user_a, user_b: user_b).or(where(user_a: user_b, user_b: user_a))
  }
  scope :pending, -> { kept.where(confirmed_at: nil) }
  scope :agreed, -> { kept.where.not(user_a_accepted_at: nil).where.not(user_b_accepted_at: nil) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def agreed?
    user_a_accepted_at.present? && user_b_accepted_at.present?
  end

  def confirmed?
    confirmed_at.present?
  end

  def receipt_ended_by?(user)
    if user_a_id == user.id
      user_a_receipt_ended_at.present?
    else
      user_b_receipt_ended_at.present?
    end
  end

  def participant?(user)
    user_a_id == user.id || user_b_id == user.id
  end

  def other_user(user)
    user_a_id == user.id ? user_b : user_a
  end

  def accepted_by?(user)
    if user_a_id == user.id
      user_a_accepted_at.present?
    elsif user_b_id == user.id
      user_b_accepted_at.present?
    end
  end

  def accept!(user)
    if user_a_id == user.id
      update!(user_a_accepted_at: Time.current)
    elsif user_b_id == user.id
      update!(user_b_accepted_at: Time.current)
    end
  end

  def auto_agree!(user)
    if user_a_id == user.id
      update!(user_a_accepted_at: Time.current, user_a_auto_agreed_at: Time.current)
    elsif user_b_id == user.id
      update!(user_b_accepted_at: Time.current, user_b_auto_agreed_at: Time.current)
    end
  end

  def auto_agreed_by?(user)
    if user_a_id == user.id
      user_a_auto_agreed_at.present?
    elsif user_b_id == user.id
      user_b_auto_agreed_at.present?
    end
  end

  def reset_acceptance_for(user)
    return if auto_agreed_by?(user)

    if user_a_id == user.id
      update!(user_a_accepted_at: nil)
    elsif user_b_id == user.id
      update!(user_b_accepted_at: nil)
    end
  end

  def reset_other_acceptance!(user)
    other = other_user(user)
    reset_acceptance_for(other)
  end

  def withdraw!(user)
    if user_a_id == user.id
      update!(user_a_accepted_at: nil, user_a_auto_agreed_at: nil)
    elsif user_b_id == user.id
      update!(user_b_accepted_at: nil, user_b_auto_agreed_at: nil)
    end
  end

  # Called when trade becomes agreed. Soft-deletes giver duplicates,
  # creates incoming rows for receivers on both sides.
  def process_agreement!
    transaction do
      trade_stickers.includes(:sticker).each do |ts|
        # Soft-delete giver's duplicate
        ts.user_sticker&.discard!

        # Create incoming row for receiver
        UserSticker.create!(
          user: ts.receiver,
          sticker: ts.sticker,
          state: :incoming,
          trade: self
        )
      end
    end
  end

  def stickers_given_by(user)
    trade_stickers.joins(:sticker).includes(sticker: :country).where(giver: user).order("stickers.position").map(&:sticker)
  end

  def stickers_received_by(user)
    trade_stickers.joins(:sticker).includes(sticker: :country).where(receiver: user).order("stickers.position").map(&:sticker)
  end
end
