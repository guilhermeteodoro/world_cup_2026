# frozen_string_literal: true

# == Schema Information
#
# Table name: stickers
#
#  id         :integer          not null, primary key
#  category   :integer          not null
#  number     :string           not null
#  position   :integer          not null
#  country_id :integer          not null
#
# Indexes
#
#  index_stickers_on_category               (category)
#  index_stickers_on_country_id             (country_id)
#  index_stickers_on_country_id_and_number  (country_id,number) UNIQUE
#  index_stickers_on_position               (position) UNIQUE
#
# Foreign Keys
#
#  country_id  (country_id => countries.id)
#
class Sticker < ApplicationRecord
  belongs_to :country

  enum :category, { shiny: 0, coke: 1, normal: 2 }

  validates :number, presence: true, uniqueness: { scope: :country_id }
  validates :category, presence: true
  validates :position, presence: true, uniqueness: true

  scope :ordered, -> { order(:position) }

  def self.format_as_text(stickers)
    stickers.group_by(&:country).map do |country, country_stickers|
      "#{country.emoji} #{country.code}: #{country_stickers.map(&:number).join(", ")}"
    end.join("\n")
  end

  delegate :code, to: :country, prefix: true

  def label
    "#{country.code} #{number}"
  end
end
