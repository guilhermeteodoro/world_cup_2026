# frozen_string_literal: true

class Sticker < ApplicationRecord
  belongs_to :country

  enum :category, { shiny: 0, coke: 1, normal: 2 }

  validates :number, presence: true, uniqueness: { scope: :country_id }
  validates :category, presence: true
  validates :position, presence: true, uniqueness: true

  scope :ordered, -> { order(:position) }

  delegate :code, to: :country, prefix: true

  def label
    "#{country.code} #{number}"
  end
end
