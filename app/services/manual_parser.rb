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
    results = []
    text.each_line do |line|
      line = line.strip
      next if line.empty? || line.start_with?("Hey") || line.start_with?("Download")

      match = line.match(/^([A-Z]{2,3}):\s*(.+)$/)
      next unless match

      team = match[1]
      numbers = match[2].split(",").map(&:strip)
      results << [team, numbers]
    end
    results
  end

  def parse_team_lines_with_counts(text)
    results = []
    text.each_line do |line|
      line = line.strip
      next if line.empty? || line.start_with?("Hey") || line.start_with?("Download")

      match = line.match(/^([A-Z]{2,3}):\s*(.+)$/)
      next unless match

      team = match[1]
      entries = match[2].scan(/(\d+)\((\d+)x\)/).map { |n, c| [n, c.to_i] }
      results << [team, entries]
    end
    results
  end
end
