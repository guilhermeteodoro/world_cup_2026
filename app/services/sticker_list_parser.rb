# frozen_string_literal: true

# Parses the display format (e.g. "🇧🇷 BRA: 1, 5, 7\nMEX: 3, 11") into Sticker records.
# Merges repeated country lines and deduplicates numbers.
# Returns { stickers: [Sticker], errors: [String] }
class StickerListParser
  def initialize(text)
    @text = text.to_s.strip
  end

  def call
    return { stickers: [], errors: [] } if @text.empty?

    parsed_lines = ManualParser.parse_team_lines(@text)
    sticker_lookup = build_sticker_lookup

    stickers = []
    errors = []

    parsed_lines.each do |team, numbers|
      numbers.each do |number|
        key = "#{team}:#{number}"
        sticker_id = sticker_lookup[key]
        if sticker_id
          stickers << sticker_id
        else
          errors << "#{team} #{number}"
        end
      end
    end

    {
      stickers: Sticker.includes(:country).where(id: stickers.uniq).order(:position).to_a,
      errors: errors
    }
  end

  private

  def build_sticker_lookup
    @sticker_lookup ||= Sticker.joins(:country).pluck("countries.code", :number, :id).each_with_object({}) do |(code, number, id), hash|
      hash["#{code}:#{number}"] = id
    end
  end
end
