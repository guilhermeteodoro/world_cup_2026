# frozen_string_literal: true

require "test_helper"

class CollectionImporterTest < ActiveSupport::TestCase
  test "creates user_stickers for owned positions" do
    user = create_user(name: "Importer", email: "import@test.com")
    parsed = { owned: Set[1, 2, 3, 4, 5], duplicates: { 1 => 2, 3 => 1 } }

    CollectionImporter.new(user, parsed).call

    # 5 glued + 2 duplicates for pos 1 + 1 duplicate for pos 3 = 8 total
    assert_equal 5, user.user_stickers.glued.count
    assert_equal 2, user.user_stickers.duplicates.where(sticker: Sticker.find_by(position: 1)).count
    assert_equal 1, user.user_stickers.duplicates.where(sticker: Sticker.find_by(position: 3)).count
    assert_equal 0, user.user_stickers.duplicates.where(sticker: Sticker.find_by(position: 2)).count
  end

  test "wipes and replaces on re-import" do
    user = create_user(name: "ReImport", email: "reimport@test.com")
    first = { owned: Set[1, 2, 3], duplicates: {} }
    second = { owned: Set[4, 5], duplicates: { 4 => 1 } }

    CollectionImporter.new(user, first).call
    assert_equal 3, user.user_stickers.glued.count

    CollectionImporter.new(user, second).call
    assert_equal 2, user.reload.user_stickers.glued.count
    assert_nil user.user_stickers.glued.find_by(sticker: Sticker.find_by(position: 1))
    assert_equal 1, user.user_stickers.duplicates.where(sticker: Sticker.find_by(position: 4)).count
  end

  test "imports real dump correctly" do
    user = create_user(name: "RealDump", email: "real@test.com", dump: sample_dump)

    assert_equal 591, user.owned_count
    assert_equal 403, user.missing_count
    assert_equal 270, user.duplicates_count
  end
end
