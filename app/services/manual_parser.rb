# frozen_string_literal: true

# Parses the manual text format (missing stickers + duplicates lists).
# Returns { owned: Set<position>, duplicates: Hash<position, copies> }
#
# Missing format:
#   FWC: 00, 3, 4, 6, 7
#   BRA: 2, 3, 4, 6
#
# Duplicates format:
#   FWC: 9(1x), 10(1x)
#   MEX: 4(3x), 5(1x)
class ManualParser
  ParseError = Class.new(StandardError)

  def initialize(missing_text:, duplicates_text:)
    @missing_text = missing_text.strip
    @duplicates_text = duplicates_text.strip
  end

  def call
    sticker_lookup = build_sticker_lookup
    missing_positions = parse_missing(sticker_lookup)
    duplicates = parse_duplicates(sticker_lookup)

    all_positions = Set.new(1..994)
    owned = all_positions - missing_positions

    { owned: owned, duplicates: duplicates }
  end

  private

  def build_sticker_lookup
    @sticker_lookup ||= Sticker.joins(:country).pluck("countries.code", :number, :position).each_with_object({}) do |(code, number, position), hash|
      hash["#{code}:#{number}"] = position
    end
  end

  def parse_missing(lookup)
    result = Set.new
    parse_team_lines(@missing_text).each do |team, numbers|
      numbers.each do |number|
        key = "#{team}:#{number}"
        position = lookup[key]
        raise ParseError, "Unknown sticker: #{team} #{number}" unless position
        result.add(position)
      end
    end
    result
  end

  def parse_duplicates(lookup)
    result = {}
    parse_team_lines_with_counts(@duplicates_text).each do |team, entries|
      entries.each do |number, count|
        key = "#{team}:#{number}"
        position = lookup[key]
        raise ParseError, "Unknown sticker: #{team} #{number}" unless position
        result[position] = count
      end
    end
    result
  end

  def parse_team_lines(text)
    self.class.parse_team_lines(text)
  end

  def self.parse_team_lines(text)
    grouped = {}
    text.each_line do |line|
      line = line.strip
      next if line.empty? || line.start_with?("Hey") || line.start_with?("Download")

      match = line.match(/^[^A-Z]*([A-Z]{2,3})\s*[^:]*:\s*(.+)$/)
      next unless match

      team = match[1]
      numbers = match[2].split(",").map(&:strip)
      grouped[team] ||= Set.new
      numbers.each { |n| grouped[team].add(n) }
    end
    grouped.map { |team, numbers| [ team, numbers.to_a ] }
  end

  def parse_team_lines_with_counts(text)
    results = []
    text.each_line do |line|
      line = line.strip
      next if line.empty? || line.start_with?("Hey") || line.start_with?("Download")

      match = line.match(/^[^A-Z]*([A-Z]{2,3})\s*[^:]*:\s*(.+)$/)
      next unless match

      team = match[1]
      numbers_str = match[2]

      # Try format with counts: 4(3x), 12(1x)
      entries_with_counts = numbers_str.scan(/(\d+)\((\d+)x\)/)
      entries = if entries_with_counts.any?
        entries_with_counts.map { |n, c| [ n, c.to_i ] }
      else
        # Plain numbers without counts: 4, 12, 17 — assume 1 copy each
        numbers_str.split(",").map { |n| [ n.strip, 1 ] }
      end
      results << [ team, entries ]
    end
    results
  end
end
