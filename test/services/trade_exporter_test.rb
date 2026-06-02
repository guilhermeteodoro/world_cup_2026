# frozen_string_literal: true

require "test_helper"

class TradeExporterTest < ActiveSupport::TestCase
  setup do
    # User A owns positions 1-10, duplicates at 1(2x), 2(1x), 3(1x)
    @user_a = create_user(name: "A", email: "a@test.com")
    CollectionImporter.new(@user_a, {
      owned: Set.new(1..10),
      duplicates: { 1 => 2, 2 => 1, 3 => 1 }
    }).call

    # User B owns positions 5-15, duplicates at 11(1x), 12(1x), 13(1x)
    @user_b = create_user(name: "B", email: "b@test.com")
    CollectionImporter.new(@user_b, {
      owned: Set.new(5..15),
      duplicates: { 11 => 1, 12 => 1, 13 => 1 }
    }).call

    # Create a trade: A gives stickers at positions 1, 2, 3 / B gives stickers at positions 11, 12, 13
    @trade = Trade.create!(user_a: @user_a, user_b: @user_b, confirmed_at: Time.current)

    stickers_a_gives = Sticker.where(position: [ 1, 2, 3 ])
    stickers_b_gives = Sticker.where(position: [ 11, 12, 13 ])

    stickers_a_gives.each do |s|
      @trade.trade_stickers.create!(sticker: s, giver: @user_a, receiver: @user_b)
    end
    stickers_b_gives.each do |s|
      @trade.trade_stickers.create!(sticker: s, giver: @user_b, receiver: @user_a)
    end
  end

  test "dump format reflects virtual post-trade state" do
    result = TradeExporter.new(user: @user_a, trade: @trade).call

    # After trade: A gave positions 1,2,3 (copies -1 each), received 11,12,13 (new owned)
    # Original: owned 1-10, dupes {1=>2, 2=>1, 3=>1}
    # After: owned 1-13, dupes {1=>1} (2,3 go to 0 copies; 11,12,13 are new with 0 copies)
    dump = result[:dump]
    assert dump.start_with?("SA26|1|")

    # Owned should now be 1-13
    parts = dump.split("|")
    assert_equal "1-13", parts[2]

    # Duplicates: only position 1 with 1 copy
    assert_equal "1:1", parts[3]
  end

  test "missing format shows all stickers not owned post-trade" do
    result = TradeExporter.new(user: @user_a, trade: @trade).call

    # After trade: owned 1-13, so missing is 14-994
    missing_lines = result[:missing].split("\n")
    assert missing_lines.any?, "missing should have content"
    # Position 14 should appear in missing
    sticker_14 = Sticker.find_by(position: 14)
    assert_includes result[:missing], sticker_14.country.code
  end

  test "duplicates format shows only stickers with copies > 0 post-trade" do
    result = TradeExporter.new(user: @user_a, trade: @trade).call

    # Only position 1 has 1 copy remaining
    sticker_1 = Sticker.find_by(position: 1)
    assert_includes result[:duplicates], "#{sticker_1.number}(1x)"
  end

  test "received stickers that were missing become owned with 0 copies" do
    result = TradeExporter.new(user: @user_a, trade: @trade).call

    # Positions 11,12,13 were missing, now owned — should NOT appear in missing or duplicates
    [ 11, 12, 13 ].each do |pos|
      sticker = Sticker.find_by(position: pos)
      refute_includes result[:missing], "#{sticker.country.code}: #{sticker.number}"
      refute_includes result[:duplicates], sticker.number
    end
  end

  test "received stickers that were already owned get copies incremented" do
    # User A already owns position 5 (no duplicates). Give it to them again via a second trade.
    trade2 = Trade.create!(user_a: @user_a, user_b: @user_b, confirmed_at: Time.current)
    sticker_5 = Sticker.find_by(position: 5)
    trade2.trade_stickers.create!(sticker: sticker_5, giver: @user_b, receiver: @user_a)

    result = TradeExporter.new(user: @user_a, trade: trade2).call

    # Position 5 had 0 copies, now should have 1
    assert_includes result[:duplicates], "#{sticker_5.number}(1x)"
  end
end
