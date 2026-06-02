# frozen_string_literal: true

# Computes a virtual post-trade collection state and serializes it
# in dump and manual formats for export to external apps.
class TradeExporter
  def initialize(user:, trade:)
    @user = user
    @trade = trade
  end

  def call
    collection = build_virtual_collection
    {
      dump: serialize_dump(collection),
      missing: serialize_missing(collection),
      duplicates: serialize_duplicates(collection)
    }
  end

  private

  def build_virtual_collection
    # Load current collection: { position => copies }
    # Row exists = owned (copies = extra tradeable copies)
    # No row = missing
    collection = @user.user_stickers.reload.pluck(:sticker_id, :copies).each_with_object({}) do |(sticker_id, copies), hash|
      position = sticker_positions[sticker_id]
      hash[position] = copies if position
    end

    # Apply trade: subtract given, add received
    given_stickers.each do |sticker|
      pos = sticker.position
      if collection.key?(pos)
        collection[pos] -= 1
        collection.delete(pos) if collection[pos] < 0
      end
    end

    received_stickers.each do |sticker|
      pos = sticker.position
      if collection.key?(pos)
        collection[pos] += 1
      else
        collection[pos] = 0 # newly owned, no extras
      end
    end

    collection
  end

  def serialize_dump(collection)
    owned_positions = collection.keys.sort
    duplicates = collection.select { |_, copies| copies > 0 }.sort_by(&:first)

    owned_ranges = compress_ranges(owned_positions)
    duplicates_str = duplicates.map { |pos, count| "#{pos}:#{count}" }.join(",")

    "SA26|1|#{owned_ranges}|#{duplicates_str}"
  end

  def serialize_missing(collection)
    owned_positions = Set.new(collection.keys)
    missing_positions = (1..994).reject { |pos| owned_positions.include?(pos) }
    missing_stickers = Sticker.includes(:country).where(position: missing_positions).order(:position)

    format_grouped(missing_stickers) { |sticker| sticker.number }
  end

  def serialize_duplicates(collection)
    duplicate_entries = collection.select { |_, copies| copies > 0 }
    duplicate_stickers = Sticker.includes(:country).where(position: duplicate_entries.keys).order(:position)

    format_grouped(duplicate_stickers) { |sticker| "#{sticker.number}(#{duplicate_entries[sticker.position]}x)" }
  end

  def format_grouped(stickers, &formatter)
    stickers.group_by(&:country).map do |country, country_stickers|
      "#{country.code}: #{country_stickers.map(&formatter).join(", ")}"
    end.join("\n")
  end

  def compress_ranges(sorted_positions)
    return "" if sorted_positions.empty?

    ranges = []
    start = sorted_positions.first
    prev = start

    sorted_positions[1..].each do |pos|
      if pos == prev + 1
        prev = pos
      else
        ranges << (start == prev ? start.to_s : "#{start}-#{prev}")
        start = pos
        prev = pos
      end
    end
    ranges << (start == prev ? start.to_s : "#{start}-#{prev}")
    ranges.join(",")
  end

  def given_stickers
    @given_stickers ||= @trade.stickers_given_by(@user)
  end

  def received_stickers
    @received_stickers ||= @trade.stickers_received_by(@user)
  end

  def sticker_positions
    @sticker_positions ||= Sticker.pluck(:id, :position).to_h
  end
end
