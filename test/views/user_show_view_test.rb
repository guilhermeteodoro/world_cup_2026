# frozen_string_literal: true

require "test_helper"
require "nokogiri"

class UserShowViewTest < ActiveSupport::TestCase
  include ComponentTestHelper

  setup do
    @user_a = create_user(name: "Gui", email: "gui@test.com")
    CollectionImporter.new(@user_a, {
      owned: Set.new(1..20),  # All FWC stickers
      duplicates: { 1 => 1, 2 => 1, 3 => 1 }  # FWC 00, FWC 1, FWC 2
    }).call

    @user_b = create_user(name: "Vitor", email: "vitor@test.com")
    CollectionImporter.new(@user_b, {
      owned: Set.new(5..30),
      duplicates: { 21 => 1, 22 => 1 }  # CC 1, CC 2
    }).call
  end

  test "duplicates clipboard text contains country codes and numbers" do
    doc = render_document(Views::Users::Show.new(
      user: @user_a,
      is_owner: true,
      trade_result: nil,
      trade_clipboard_text: nil,
      current_user: @user_a
    ))

    clipboard_div = doc.at_css("[data-clipboard-text-value]")
    text = clipboard_div["data-clipboard-text-value"]

    assert_includes text, "FWC:"
    assert_includes text, "00"
  end

  test "trade clipboard text contains both directions" do
    trade_result = TradeComparer.new(@user_a, @user_b).call

    doc = render_document(Views::Users::Show.new(
      user: @user_b,
      is_owner: false,
      trade_result: trade_result,
      trade_clipboard_text: "Gui \u2192 Vitor\nVitor \u2192 Gui",
      current_user: @user_a
    ))

    clipboard_divs = doc.css("[data-clipboard-text-value]")
    trade_text = clipboard_divs.map { |d| d["data-clipboard-text-value"] }
      .find { |t| t.include?("→") }

    assert_not_nil trade_text, "Trade clipboard text should exist"
    assert_includes trade_text, "Gui →"
    assert_includes trade_text, "Vitor →"
  end

  test "trade clipboard text has indentation" do
    trade_result = TradeComparer.new(@user_a, @user_b).call

    doc = render_document(Views::Users::Show.new(
      user: @user_b,
      is_owner: false,
      trade_result: trade_result,
      trade_clipboard_text: "Gui \u2192 Vitor\n  FWC: 00, 1, 2\n\nVitor \u2192 Gui\n  CC: 1, 2",
      current_user: @user_a
    ))

    trade_text = doc.css("[data-clipboard-text-value]")
      .map { |d| d["data-clipboard-text-value"] }
      .find { |t| t.include?("→") }

    # Sticker lines should be indented
    sticker_lines = trade_text.lines.select { |l| l.include?("FWC:") || l.include?("CC:") }
    assert sticker_lines.any? { |l| l.start_with?("  ") }, "Sticker lines should be indented"
  end

  test "balanced trade section appears when trade is possible" do
    # Create users with same-category duplicates for balanced trade
    user_x = create_user(name: "X", email: "x@test.com")
    # X owns FWC stickers 1-10, has dupes at 1,2,3 (shiny)
    CollectionImporter.new(user_x, {
      owned: Set.new(1..10),
      duplicates: { 1 => 1, 2 => 1, 3 => 1 }
    }).call

    user_y = create_user(name: "Y", email: "y@test.com")
    # Y owns FWC stickers 5-20, has dupes at 11,12 (shiny - FWC 10, FWC 11)
    CollectionImporter.new(user_y, {
      owned: Set.new(5..20),
      duplicates: { 11 => 1, 12 => 1 }
    }).call

    trade_result = TradeComparer.new(user_x, user_y).call

    doc = render_document(Views::Users::Show.new(
      user: user_y,
      is_owner: false,
      trade_result: trade_result,
      trade_clipboard_text: "X → Y\n" + I18n.t("views.users.show.balanced_title"),
      current_user: user_x
    ))

    trade_text = doc.css("[data-clipboard-text-value]")
      .map { |d| d["data-clipboard-text-value"] }
      .find { |t| t.include?("→") }

    assert_includes trade_text, I18n.t("views.users.show.balanced_title")
  end
end
