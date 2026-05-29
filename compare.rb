#!/usr/bin/env ruby
# frozen_string_literal: true

# Compare two Sticker Album 2026 dumps and find trading opportunities.
# Output grouped by team, with balanced trade suggestion by category.
#
# Usage:
#   ruby compare.rb <dump_file_a> <dump_file_b> [name_a] [name_b]
#   ruby compare.rb --inline "<dump_a>" "<dump_b>" [name_a] [name_b]

require "set"

TEAMS = [
  ["FWC", 20], ["CC", 14],
  ["MEX", 20], ["RSA", 20], ["KOR", 20], ["CZE", 20], ["CAN", 20],
  ["BIH", 20], ["QAT", 20], ["SUI", 20], ["BRA", 20], ["MAR", 20],
  ["HAI", 20], ["SCO", 20], ["USA", 20], ["PAR", 20], ["AUS", 20],
  ["TUR", 20], ["GER", 20], ["CUW", 20], ["CIV", 20], ["ECU", 20],
  ["NED", 20], ["JPN", 20], ["SWE", 20], ["TUN", 20], ["BEL", 20],
  ["EGY", 20], ["IRN", 20], ["NZL", 20], ["ESP", 20], ["CPV", 20],
  ["KSA", 20], ["URU", 20], ["FRA", 20], ["SEN", 20], ["IRQ", 20],
  ["NOR", 20], ["ARG", 20], ["ALG", 20], ["AUT", 20], ["JOR", 20],
  ["POR", 20], ["COD", 20], ["UZB", 20], ["COL", 20], ["ENG", 20],
  ["CRO", 20], ["GHA", 20], ["PAN", 20],
].freeze

# Build bidirectional mappings between sequential IDs and team+number labels
ID_TO_LABEL = {}
LABEL_TO_ID = {}

seq = 1
TEAMS.each do |team, size|
  sticker_numbers = team == "FWC" ? ["00"] + (1..19).map(&:to_s) : (1..size).map(&:to_s)
  sticker_numbers.each do |n|
    label = "#{team} #{n}"
    ID_TO_LABEL[seq] = label
    LABEL_TO_ID[label] = seq
    seq += 1
  end
end

TOTAL_STICKERS = ID_TO_LABEL.size # 994

# Category classification
# Shiny: all FWC (00-19) + sticker 1 of every other team
# Coke: all CC (1-14)
# Normal: everything else
SHINY_IDS = Set.new
COKE_IDS = Set.new
NORMAL_IDS = Set.new

ID_TO_LABEL.each do |id, label|
  team, number = label.split(" ", 2)
  if team == "FWC"
    SHINY_IDS.add(id)
  elsif team == "CC"
    COKE_IDS.add(id)
  elsif number == "1"
    SHINY_IDS.add(id)
  else
    NORMAL_IDS.add(id)
  end
end

def category_for(id)
  return :shiny if SHINY_IDS.include?(id)
  return :coke if COKE_IDS.include?(id)
  :normal
end

def expand_ranges(ranges_str)
  result = Set.new
  return result if ranges_str.nil? || ranges_str.strip.empty?

  ranges_str.split(",").each do |part|
    part = part.strip
    if part.include?("-")
      s, e = part.split("-", 2).map(&:to_i)
      result.merge(s..e)
    else
      result.add(part.to_i)
    end
  end
  result
end

def parse_duplicates(dupes_str)
  result = Set.new
  return result if dupes_str.nil? || dupes_str.strip.empty?

  dupes_str.split(",").each do |part|
    sticker, _ = part.strip.split(":")
    result.add(sticker.to_i)
  end
  result
end

def parse_dump(raw, name)
  parts = raw.strip.split("|")
  abort "Invalid dump header: #{parts[0]}" unless parts[0] == "SA26"

  owned = expand_ranges(parts[2])
  duplicates = parts.length > 3 ? parse_duplicates(parts[3]) : Set.new

  { name: name, owned: owned, duplicates: duplicates }
end

def missing_for(album)
  Set.new(1..TOTAL_STICKERS) - album[:owned]
end

def group_by_team(sticker_ids)
  grouped = {}
  sticker_ids.sort.each do |id|
    label = ID_TO_LABEL[id]
    team, number = label.split(" ", 2)
    grouped[team] ||= []
    grouped[team] << number
  end
  grouped
end

def print_grouped(sticker_ids, indent: "   ")
  grouped = group_by_team(sticker_ids)
  grouped.each do |team, numbers|
    puts "#{indent}#{team}: #{numbers.join(", ")}"
  end
end

def categorize(sticker_ids)
  result = { shiny: [], coke: [], normal: [] }
  sticker_ids.sort.each do |id|
    result[category_for(id)] << id
  end
  result
end

def compare(a, b)
  a_missing = missing_for(a)
  b_missing = missing_for(b)

  # Full tradeable sets
  a_gives_b = (a[:duplicates] & b_missing).sort
  b_gives_a = (b[:duplicates] & a_missing).sort

  a_by_cat = categorize(a_gives_b)
  b_by_cat = categorize(b_gives_a)

  puts "=" * 60
  puts "STICKER ALBUM 2026 — TRADE COMPARISON"
  puts "=" * 60

  puts
  puts "📊 #{a[:name]}: #{a[:owned].size}/#{TOTAL_STICKERS} owned, #{a_missing.size} missing"
  puts "📊 #{b[:name]}: #{b[:owned].size}/#{TOTAL_STICKERS} owned, #{b_missing.size} missing"

  # --- Full diff ---
  puts
  puts "─" * 60
  puts "🔄 #{a[:name]} → #{b[:name]}  (#{a_gives_b.size} stickers)"
  puts "   Duplicates #{a[:name]} has that #{b[:name]} is missing:"
  puts "─" * 60
  if a_gives_b.any?
    print_grouped(a_gives_b)
  else
    puts "   (nothing)"
  end

  puts
  puts "─" * 60
  puts "🔄 #{b[:name]} → #{a[:name]}  (#{b_gives_a.size} stickers)"
  puts "   Duplicates #{b[:name]} has that #{a[:name]} is missing:"
  puts "─" * 60
  if b_gives_a.any?
    print_grouped(b_gives_a)
  else
    puts "   (nothing)"
  end

  # --- Balanced trade suggestion ---
  puts
  puts "=" * 60
  puts "✅ SUGGESTED BALANCED TRADE"
  puts "=" * 60

  leftovers_a = { shiny: [], coke: [], normal: [] }
  leftovers_b = { shiny: [], coke: [], normal: [] }

  [:shiny, :coke, :normal].each do |cat|
    a_pool = a_by_cat[cat]
    b_pool = b_by_cat[cat]
    trade_count = [a_pool.size, b_pool.size].min

    if trade_count > 0
      a_selected = a_pool.first(trade_count)
      b_selected = b_pool.first(trade_count)

      cat_label = cat.to_s.upcase
      puts
      puts "   #{cat_label} (#{trade_count} for #{trade_count}):"
      puts "   #{a[:name]} gives:"
      print_grouped(a_selected, indent: "      ")
      puts "   #{b[:name]} gives:"
      print_grouped(b_selected, indent: "      ")
    end

    # Leftovers
    leftovers_a[cat] = a_pool.drop([a_pool.size, b_pool.size].min)
    leftovers_b[cat] = b_pool.drop([b_pool.size, a_pool.size].min)
  end

  # --- Leftovers ---
  total_leftovers_a = leftovers_a.values.flatten
  total_leftovers_b = leftovers_b.values.flatten

  if total_leftovers_a.any? || total_leftovers_b.any?
    puts
    puts "─" * 60
    puts "🤝 LEFTOVERS (negotiate cross-category)"
    puts "─" * 60

    if total_leftovers_a.any?
      puts
      puts "   #{a[:name]} still has to offer (#{total_leftovers_a.size}):"
      [:shiny, :coke, :normal].each do |cat|
        next if leftovers_a[cat].empty?
        puts "   [#{cat}]"
        print_grouped(leftovers_a[cat], indent: "      ")
      end
    end

    if total_leftovers_b.any?
      puts
      puts "   #{b[:name]} still has to offer (#{total_leftovers_b.size}):"
      [:shiny, :coke, :normal].each do |cat|
        next if leftovers_b[cat].empty?
        puts "   [#{cat}]"
        print_grouped(leftovers_b[cat], indent: "      ")
      end
    end
  end

  puts
end

# --- Main ---

if ARGV[0] == "--inline"
  abort 'Usage: ruby compare.rb --inline "<dump_a>" "<dump_b>" [name_a] [name_b]' if ARGV.length < 3
  dump_a = ARGV[1]
  dump_b = ARGV[2]
  name_a = ARGV[3] || "me"
  name_b = ARGV[4] || "friend"
elsif ARGV.length >= 2
  dump_a = File.read(ARGV[0]).strip
  dump_b = File.read(ARGV[1]).strip
  name_a = ARGV[2] || "me"
  name_b = ARGV[3] || "friend"
else
  puts "Usage:"
  puts '  ruby compare.rb <file_a> <file_b> [name_a] [name_b]'
  puts '  ruby compare.rb --inline "<dump_a>" "<dump_b>" [name_a] [name_b]'
  exit 1
end

a = parse_dump(dump_a, name_a)
b = parse_dump(dump_b, name_b)
compare(a, b)
