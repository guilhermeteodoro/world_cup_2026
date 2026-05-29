# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :stickers, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :emoji, presence: true

  def name
    I18n.t("countries.#{code}")
  end
end
