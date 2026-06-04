# frozen_string_literal: true

# One-shot task to migrate data from Postgres to SQLite.
# Run on Render after deploying the SQLite config:
#
#   POSTGRES_URL=postgresql://... bin/rails db:migrate_from_postgres
#
# Safe to delete after migration is confirmed.

namespace :db do
  desc "Migrate production data from Postgres to local SQLite"
  task migrate_from_postgres: :environment do
    require "pg"

    postgres_url = ENV.fetch("POSTGRES_URL") do
      abort "Set POSTGRES_URL to the Postgres connection string"
    end

    conn = PG.connect(postgres_url)

    puts "==> Migrating users..."
    users = conn.exec("SELECT id, name, email, slug, created_at, updated_at FROM users ORDER BY id")
    users.each do |row|
      User.create!(
        id: row["id"],
        name: row["name"],
        email: row["email"],
        slug: row["slug"],
        created_at: row["created_at"],
        updated_at: row["updated_at"]
      )
    end
    puts "    #{users.ntuples} users migrated"

    puts "==> Migrating user_stickers..."
    user_stickers = conn.exec("SELECT id, user_id, sticker_id, copies, created_at, updated_at FROM user_stickers ORDER BY id")
    # Bulk insert for performance
    batch = user_stickers.map do |row|
      {
        id: row["id"],
        user_id: row["user_id"],
        sticker_id: row["sticker_id"],
        copies: row["copies"],
        created_at: row["created_at"],
        updated_at: row["updated_at"]
      }
    end
    UserSticker.insert_all!(batch) if batch.any?
    puts "    #{user_stickers.ntuples} user_stickers migrated"

    puts "==> Migrating trades..."
    trades = conn.exec("SELECT id, user_a_id, user_b_id, confirmed_at, created_at, updated_at FROM trades ORDER BY id")
    trades.each do |row|
      Trade.create!(
        id: row["id"],
        user_a_id: row["user_a_id"],
        user_b_id: row["user_b_id"],
        confirmed_at: row["confirmed_at"],
        created_at: row["created_at"],
        updated_at: row["updated_at"]
      )
    end
    puts "    #{trades.ntuples} trades migrated"

    puts "==> Migrating trade_stickers..."
    trade_stickers = conn.exec("SELECT id, trade_id, sticker_id, giver_id, receiver_id, created_at, updated_at FROM trade_stickers ORDER BY id")
    batch = trade_stickers.map do |row|
      {
        id: row["id"],
        trade_id: row["trade_id"],
        sticker_id: row["sticker_id"],
        giver_id: row["giver_id"],
        receiver_id: row["receiver_id"],
        created_at: row["created_at"],
        updated_at: row["updated_at"]
      }
    end
    TradeSticker.insert_all!(batch) if batch.any?
    puts "    #{trade_stickers.ntuples} trade_stickers migrated"

    conn.close
    puts "\n==> Done! All data migrated to SQLite."
  end
end
