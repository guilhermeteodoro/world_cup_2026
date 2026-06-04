# frozen_string_literal: true

# Seed countries and the sticker catalog — 994 stickers total.

COUNTRIES_DATA = [
  { code: "FWC", emoji: "🏆", size: 20, color: "#DAA520" },
  { code: "CC",  emoji: "🥤", size: 14, color: "#E61E2B" },
  { code: "MEX", emoji: "🇲🇽", size: 20, color: "#006847" },
  { code: "RSA", emoji: "🇿🇦", size: 20, color: "#007A4D" },
  { code: "KOR", emoji: "🇰🇷", size: 20, color: "#CD2E3A" },
  { code: "CZE", emoji: "🇨🇿", size: 20, color: "#11457E" },
  { code: "CAN", emoji: "🇨🇦", size: 20, color: "#FF0000" },
  { code: "BIH", emoji: "🇧🇦", size: 20, color: "#002395" },
  { code: "QAT", emoji: "🇶🇦", size: 20, color: "#8A1538" },
  { code: "SUI", emoji: "🇨🇭", size: 20, color: "#FF0000" },
  { code: "BRA", emoji: "🇧🇷", size: 20, color: "#009739" },
  { code: "MAR", emoji: "🇲🇦", size: 20, color: "#C1272D" },
  { code: "HAI", emoji: "🇭🇹", size: 20, color: "#00209F" },
  { code: "SCO", emoji: "🏴󠁧󠁢󠁳󠁣󠁴󠁿", size: 20, color: "#005EB8" },
  { code: "USA", emoji: "🇺🇸", size: 20, color: "#3C3B6E" },
  { code: "PAR", emoji: "🇵🇾", size: 20, color: "#D52B1E" },
  { code: "AUS", emoji: "🇦🇺", size: 20, color: "#00008B" },
  { code: "TUR", emoji: "🇹🇷", size: 20, color: "#E30A17" },
  { code: "GER", emoji: "🇩🇪", size: 20, color: "#000000" },
  { code: "CUW", emoji: "🇨🇼", size: 20, color: "#002B7F" },
  { code: "CIV", emoji: "🇨🇮", size: 20, color: "#F77F00" },
  { code: "ECU", emoji: "🇪🇨", size: 20, color: "#FFD100" },
  { code: "NED", emoji: "🇳🇱", size: 20, color: "#FF4F00" },
  { code: "JPN", emoji: "🇯🇵", size: 20, color: "#BC002D" },
  { code: "SWE", emoji: "🇸🇪", size: 20, color: "#006AA7" },
  { code: "TUN", emoji: "🇹🇳", size: 20, color: "#E70013" },
  { code: "BEL", emoji: "🇧🇪", size: 20, color: "#000000" },
  { code: "EGY", emoji: "🇪🇬", size: 20, color: "#CE1126" },
  { code: "IRN", emoji: "🇮🇷", size: 20, color: "#239F40" },
  { code: "NZL", emoji: "🇳🇿", size: 20, color: "#00247D" },
  { code: "ESP", emoji: "🇪🇸", size: 20, color: "#AA151B" },
  { code: "CPV", emoji: "🇨🇻", size: 20, color: "#003893" },
  { code: "KSA", emoji: "🇸🇦", size: 20, color: "#006C35" },
  { code: "URU", emoji: "🇺🇾", size: 20, color: "#5CBEF0" },
  { code: "FRA", emoji: "🇫🇷", size: 20, color: "#002395" },
  { code: "SEN", emoji: "🇸🇳", size: 20, color: "#00853F" },
  { code: "IRQ", emoji: "🇮🇶", size: 20, color: "#007A3D" },
  { code: "NOR", emoji: "🇳🇴", size: 20, color: "#EF2B2D" },
  { code: "ARG", emoji: "🇦🇷", size: 20, color: "#75AADB" },
  { code: "ALG", emoji: "🇩🇿", size: 20, color: "#006233" },
  { code: "AUT", emoji: "🇦🇹", size: 20, color: "#ED2939" },
  { code: "JOR", emoji: "🇯🇴", size: 20, color: "#007A3D" },
  { code: "POR", emoji: "🇵🇹", size: 20, color: "#006600" },
  { code: "COD", emoji: "🇨🇩", size: 20, color: "#007FFF" },
  { code: "UZB", emoji: "🇺🇿", size: 20, color: "#1EB53A" },
  { code: "COL", emoji: "🇨🇴", size: 20, color: "#FCD116" },
  { code: "ENG", emoji: "🏴󠁧󠁢󠁥󠁮󠁧󠁿", size: 20, color: "#CF081F" },
  { code: "CRO", emoji: "🇭🇷", size: 20, color: "#FF0000" },
  { code: "GHA", emoji: "🇬🇭", size: 20, color: "#006B3F" },
  { code: "PAN", emoji: "🇵🇦", size: 20, color: "#005EB8" }
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
  country = Country.find_or_initialize_by(code: data[:code])
  country.emoji = data[:emoji]
  country.color = data[:color]
  country.save! if country.new_record? || country.changed?
  countries[data[:code]] = country
end

# Create stickers
stickers = []
position = 1

COUNTRIES_DATA.each do |data|
  country = countries[data[:code]]
  numbers = if data[:code] == "FWC"
    [ "00" ] + (1..19).map(&:to_s)
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
