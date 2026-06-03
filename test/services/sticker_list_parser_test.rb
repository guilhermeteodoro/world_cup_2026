# frozen_string_literal: true

require "test_helper"

class StickerListParserTest < ActiveSupport::TestCase
  test "parses basic sticker list format" do
    result = StickerListParser.new("FWC: 00, 3, 4\nMEX: 1, 5").call

    assert_equal 5, result[:stickers].size
    assert_empty result[:errors]
    labels = result[:stickers].map(&:label)
    assert_includes labels, "FWC 00"
    assert_includes labels, "FWC 3"
    assert_includes labels, "MEX 1"
  end

  test "parses format with emoji prefix" do
    result = StickerListParser.new("🏆 FWC: 00, 3\n🇲🇽 MEX: 1, 5").call

    assert_equal 4, result[:stickers].size
    assert_empty result[:errors]
  end

  test "merges repeated country lines" do
    result = StickerListParser.new("BRA: 1, 5, 7\nMEX: 3\nBRA: 12, 15").call

    labels = result[:stickers].map(&:label)
    assert_includes labels, "BRA 1"
    assert_includes labels, "BRA 5"
    assert_includes labels, "BRA 12"
    assert_includes labels, "BRA 15"
    assert_includes labels, "MEX 3"
    assert_equal 6, result[:stickers].size
  end

  test "deduplicates stickers within and across lines" do
    result = StickerListParser.new("BRA: 1, 5, 5\nBRA: 5, 12").call

    labels = result[:stickers].map(&:label)
    assert_equal 3, labels.size
    assert_equal 1, labels.count("BRA 5")
  end

  test "reports errors for unknown stickers" do
    result = StickerListParser.new("BRA: 1, 5\nXXX: 1, 2").call

    assert_equal 2, result[:stickers].size
    assert_includes result[:errors], "XXX 1"
    assert_includes result[:errors], "XXX 2"
  end

  test "reports errors for invalid numbers" do
    result = StickerListParser.new("BRA: 1, 99").call

    assert_equal 1, result[:stickers].size
    assert_includes result[:errors], "BRA 99"
  end

  test "returns empty results for blank input" do
    result = StickerListParser.new("").call

    assert_empty result[:stickers]
    assert_empty result[:errors]
  end

  test "returns stickers ordered by position" do
    result = StickerListParser.new("MEX: 5, 1\nFWC: 00").call

    positions = result[:stickers].map(&:position)
    assert_equal positions.sort, positions
  end

  test "ignores blank lines" do
    result = StickerListParser.new("FWC: 00\n\n\nMEX: 1").call

    assert_equal 2, result[:stickers].size
    assert_empty result[:errors]
  end
end
