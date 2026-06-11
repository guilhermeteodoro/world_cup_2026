# frozen_string_literal: true

# Takes parsed sticker data and creates/replaces a user's collection.
# Wipes existing user_stickers and bulk-inserts new ones.
# On reimport, soft-deletes everything (user_stickers, trades) first.
class CollectionImporter
  def initialize(user, parsed_data)
    @user = user
    @owned = parsed_data[:owned]
    @duplicates = parsed_data[:duplicates]
  end

  def call
    sticker_positions = Sticker.where(position: @owned.to_a).pluck(:position, :id).to_h
    now = Time.current

    records = []

    @owned.each do |position|
      sticker_id = sticker_positions[position]
      next unless sticker_id

      # One glued row per owned sticker
      records << {
        user_id: @user.id,
        sticker_id: sticker_id,
        state: "glued",
        created_at: now,
        updated_at: now
      }

      # N duplicate rows for each copy
      copies = @duplicates.fetch(position, 0)
      copies.times do
        records << {
          user_id: @user.id,
          sticker_id: sticker_id,
          state: "duplicate",
          created_at: now,
          updated_at: now
        }
      end
    end

    UserSticker.transaction do
      # Soft-delete existing collection and trades
      @user.user_stickers.discard_all
      Trade.involving(@user).discard_all

      UserSticker.insert_all(records) if records.any?
    end
  end
end
