# frozen_string_literal: true

class User < ApplicationRecord
  has_many :user_stickers, dependent: :delete_all
  has_many :stickers, through: :user_stickers

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

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug ||= SecureRandom.alphanumeric(8).downcase
  end
end
