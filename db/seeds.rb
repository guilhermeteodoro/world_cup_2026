# frozen_string_literal: true

# Seed countries and the sticker catalog — 994 stickers total.

COUNTRIES_DATA = [
  { code: "FWC", emoji: "🏆", size: 20 },
  { code: "CC",  emoji: "🥤", size: 14 },
  { code: "MEX", emoji: "🇲🇽", size: 20 },
  { code: "RSA", emoji: "🇿🇦", size: 20 },
  { code: "KOR", emoji: "🇰🇷", size: 20 },
  { code: "CZE", emoji: "🇨🇿", size: 20 },
  { code: "CAN", emoji: "🇨🇦", size: 20 },
  { code: "BIH", emoji: "🇧🇦", size: 20 },
  { code: "QAT", emoji: "🇶🇦", size: 20 },
  { code: "SUI", emoji: "🇨🇭", size: 20 },
  { code: "BRA", emoji: "🇧🇷", size: 20 },
  { code: "MAR", emoji: "🇲🇦", size: 20 },
  { code: "HAI", emoji: "🇭🇹", size: 20 },
  { code: "SCO", emoji: "🏴\u200d☠️", size: 20 },
  { code: "USA", emoji: "🇺🇸", size: 20 },
  { code: "PAR", emoji: "🇵🇾", size: 20 },
  { code: "AUS", emoji: "🇦🇺", size: 20 },
  { code: "TUR", emoji: "🇹🇷", size: 20 },
  { code: "GER", emoji: "🇩🇪", size: 20 },
  { code: "CUW", emoji: "🇨🇼", size: 20 },
  { code: "CIV", emoji: "🇨🇮", size: 20 },
  { code: "ECU", emoji: "🇪🇨", size: 20 },
  { code: "NED", emoji: "🇳🇱", size: 20 },
  { code: "JPN", emoji: "🇯🇵", size: 20 },
  { code: "SWE", emoji: "🇸🇪", size: 20 },
  { code: "TUN", emoji: "🇹🇳", size: 20 },
  { code: "BEL", emoji: "🇧🇪", size: 20 },
  { code: "EGY", emoji: "🇪🇬", size: 20 },
  { code: "IRN", emoji: "🇮🇷", size: 20 },
  { code: "NZL", emoji: "🇳🇿", size: 20 },
  { code: "ESP", emoji: "🇪🇸", size: 20 },
  { code: "CPV", emoji: "🇨🇻", size: 20 },
  { code: "KSA", emoji: "🇸🇦", size: 20 },
  { code: "URU", emoji: "🇺🇾", size: 20 },
  { code: "FRA", emoji: "🇫🇷", size: 20 },
  { code: "SEN", emoji: "🇸🇳", size: 20 },
  { code: "IRQ", emoji: "🇮🇶", size: 20 },
  { code: "NOR", emoji: "🇳🇴", size: 20 },
  { code: "ARG", emoji: "🇦🇷", size: 20 },
  { code: "ALG", emoji: "🇩🇿", size: 20 },
  { code: "AUT", emoji: "🇦🇹", size: 20 },
  { code: "JOR", emoji: "🇯🇴", size: 20 },
  { code: "POR", emoji: "🇵🇹", size: 20 },
  { code: "COD", emoji: "🇨🇩", size: 20 },
  { code: "UZB", emoji: "🇺🇿", size: 20 },
  { code: "COL", emoji: "🇨🇴", size: 20 },
  { code: "ENG", emoji: "🏴\u200d☠️", size: 20 },
  { code: "CRO", emoji: "🇭🇷", size: 20 },
  { code: "GHA", emoji: "🇬🇭", size: 20 },
  { code: "PAN", emoji: "🇵🇦", size: 20 },
].freeze

def category_for(code, number)
  return :shiny if code == "FWC"
  return :coke if code == "CC"
  return :shiny if number == "1"
  :normal
end

puts "Seeding countries and stickers..."

# Create countries
countries = {}
COUNTRIES_DATA.each do |data|
  countries[data[:code]] = Country.find_or_create_by!(code: data[:code]) do |c|
    c.emoji = data[:emoji]
  end
end

# Create stickers
stickers = []
position = 1

COUNTRIES_DATA.each do |data|
  country = countries[data[:code]]
  numbers = if data[:code] == "FWC"
    ["00"] + (1..19).map(&:to_s)
  else
    (1..data[:size]).map(&:to_s)
  end

  numbers.each do |number|
    stickers << {
      country_id: country.id,
      number: number,
      category: category_for(data[:code], number),
      position: position
    }
    position += 1
  end
end

Sticker.upsert_all(stickers, unique_by: :position)

puts "Seeded #{Country.count} countries, #{Sticker.count} stickers (shiny: #{Sticker.shiny.count}, coke: #{Sticker.coke.count}, normal: #{Sticker.normal.count})"
