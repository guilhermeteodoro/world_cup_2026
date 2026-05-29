# frozen_string_literal: true

# Seed countries and the sticker catalog — 994 stickers total.

COUNTRIES_DATA = [
  { code: "FWC", name: "FIFA World Cup", emoji: "🏆", size: 20 },
  { code: "CC",  name: "Coca-Cola", emoji: "🥤", size: 14 },
  { code: "MEX", name: "Mexico", emoji: "🇲🇽", size: 20 },
  { code: "RSA", name: "South Africa", emoji: "🇿🇦", size: 20 },
  { code: "KOR", name: "South Korea", emoji: "🇰🇷", size: 20 },
  { code: "CZE", name: "Czech Republic", emoji: "🇨🇿", size: 20 },
  { code: "CAN", name: "Canada", emoji: "🇨🇦", size: 20 },
  { code: "BIH", name: "Bosnia and Herzegovina", emoji: "🇧🇦", size: 20 },
  { code: "QAT", name: "Qatar", emoji: "🇶🇦", size: 20 },
  { code: "SUI", name: "Switzerland", emoji: "🇨🇭", size: 20 },
  { code: "BRA", name: "Brazil", emoji: "🇧🇷", size: 20 },
  { code: "MAR", name: "Morocco", emoji: "🇲🇦", size: 20 },
  { code: "HAI", name: "Haiti", emoji: "🇭🇹", size: 20 },
  { code: "SCO", name: "Scotland", emoji: "🏴󠁧󠁢󠁳󠁣󠁴󠁿", size: 20 },
  { code: "USA", name: "United States", emoji: "🇺🇸", size: 20 },
  { code: "PAR", name: "Paraguay", emoji: "🇵🇾", size: 20 },
  { code: "AUS", name: "Australia", emoji: "🇦🇺", size: 20 },
  { code: "TUR", name: "Turkey", emoji: "🇹🇷", size: 20 },
  { code: "GER", name: "Germany", emoji: "🇩🇪", size: 20 },
  { code: "CUW", name: "Curaçao", emoji: "🇨🇼", size: 20 },
  { code: "CIV", name: "Ivory Coast", emoji: "🇨🇮", size: 20 },
  { code: "ECU", name: "Ecuador", emoji: "🇪🇨", size: 20 },
  { code: "NED", name: "Netherlands", emoji: "🇳🇱", size: 20 },
  { code: "JPN", name: "Japan", emoji: "🇯🇵", size: 20 },
  { code: "SWE", name: "Sweden", emoji: "🇸🇪", size: 20 },
  { code: "TUN", name: "Tunisia", emoji: "🇹🇳", size: 20 },
  { code: "BEL", name: "Belgium", emoji: "🇧🇪", size: 20 },
  { code: "EGY", name: "Egypt", emoji: "🇪🇬", size: 20 },
  { code: "IRN", name: "Iran", emoji: "🇮🇷", size: 20 },
  { code: "NZL", name: "New Zealand", emoji: "🇳🇿", size: 20 },
  { code: "ESP", name: "Spain", emoji: "🇪🇸", size: 20 },
  { code: "CPV", name: "Cape Verde", emoji: "🇨🇻", size: 20 },
  { code: "KSA", name: "Saudi Arabia", emoji: "🇸🇦", size: 20 },
  { code: "URU", name: "Uruguay", emoji: "🇺🇾", size: 20 },
  { code: "FRA", name: "France", emoji: "🇫🇷", size: 20 },
  { code: "SEN", name: "Senegal", emoji: "🇸🇳", size: 20 },
  { code: "IRQ", name: "Iraq", emoji: "🇮🇶", size: 20 },
  { code: "NOR", name: "Norway", emoji: "🇳🇴", size: 20 },
  { code: "ARG", name: "Argentina", emoji: "🇦🇷", size: 20 },
  { code: "ALG", name: "Algeria", emoji: "🇩🇿", size: 20 },
  { code: "AUT", name: "Austria", emoji: "🇦🇹", size: 20 },
  { code: "JOR", name: "Jordan", emoji: "🇯🇴", size: 20 },
  { code: "POR", name: "Portugal", emoji: "🇵🇹", size: 20 },
  { code: "COD", name: "DR Congo", emoji: "🇨🇩", size: 20 },
  { code: "UZB", name: "Uzbekistan", emoji: "🇺🇿", size: 20 },
  { code: "COL", name: "Colombia", emoji: "🇨🇴", size: 20 },
  { code: "ENG", name: "England", emoji: "🏴󠁧󠁢󠁥󠁮󠁧󠁿", size: 20 },
  { code: "CRO", name: "Croatia", emoji: "🇭🇷", size: 20 },
  { code: "GHA", name: "Ghana", emoji: "🇬🇭", size: 20 },
  { code: "PAN", name: "Panama", emoji: "🇵🇦", size: 20 },
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
    c.name = data[:name]
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
