# frozen_string_literal: true

require "test_helper"

class AgreementTransitionTest < ActionDispatch::IntegrationTest
  setup do
    @user_a = create_user(name: "Alice", email: "alice@test.com")
    @user_b = create_user(name: "Bob", email: "bob@test.com")

    # Alice owns 1-10, has duplicate of position 3
    CollectionImporter.new(@user_a, { owned: Set.new(1..10), duplicates: { 3 => 1 } }).call
    # Bob owns 5-15, has duplicate of position 11
    CollectionImporter.new(@user_b, { owned: Set.new(5..15), duplicates: { 11 => 1 } }).call
  end

  test "agreement creates incoming rows and soft-deletes giver duplicates" do
    trade = create_agreed_trade(@user_a, @user_b)

    # Alice gave her duplicate (position 3) — should be soft-deleted
    alice_dup = @user_a.user_stickers.unscoped.where(user: @user_a, sticker_id: Sticker.find_by(position: 3).id, state: "duplicate").first
    assert alice_dup.discarded?, "Alice's duplicate should be soft-deleted after agreement"

    # Bob should have an incoming row for what Alice gave
    sticker_from_alice = trade.trade_stickers.where(giver: @user_a).first&.sticker
    if sticker_from_alice
      incoming = @user_b.user_stickers.incoming.find_by(sticker: sticker_from_alice)
      assert incoming.present?, "Bob should have an incoming row from Alice"
      assert_equal trade.id, incoming.trade_id
    end

    # Bob gave his duplicate (position 11) — should be soft-deleted
    bob_dup = @user_b.user_stickers.unscoped.where(user: @user_b, sticker_id: Sticker.find_by(position: 11).id, state: "duplicate").first
    assert bob_dup.discarded?, "Bob's duplicate should be soft-deleted after agreement"

    # Alice should have an incoming row for what Bob gave
    sticker_from_bob = trade.trade_stickers.where(giver: @user_b).first&.sticker
    if sticker_from_bob
      incoming = @user_a.user_stickers.incoming.find_by(sticker: sticker_from_bob)
      assert incoming.present?, "Alice should have an incoming row from Bob"
      assert_equal trade.id, incoming.trade_id
    end
  end

  test "agreed trade stickers excluded from duplicate counts" do
    initial_alice_dups = @user_a.user_stickers.duplicates.count
    assert_equal 1, initial_alice_dups

    create_agreed_trade(@user_a, @user_b)

    # After agreement, Alice's duplicate is soft-deleted — count is 0
    assert_equal 0, @user_a.user_stickers.duplicates.count
  end

  test "agreed trade stickers excluded from TradeComparer" do
    create_agreed_trade(@user_a, @user_b)

    # Alice has no duplicates available now
    result = TradeComparer.new(@user_a, @user_b).call
    # The sticker Alice already gave shouldn't appear in a_gives_b
    sticker_3 = Sticker.find_by(position: 3)
    refute_includes result.a_gives_b, sticker_3
  end

  test "receipt confirmation transitions incoming to to_be_glued" do
    trade = create_agreed_trade(@user_a, @user_b)

    login_as @user_b
    ts = trade.trade_stickers.where(receiver: @user_b).first
    return unless ts

    # Confirm receipt
    patch trade_receipt_path(trade, ts), params: { confirmed: "true" }

    # End confirmation
    post end_confirmation_trade_receipts_path(trade)

    # Bob's incoming should now be to_be_glued
    assert @user_b.user_stickers.to_be_glued.where(sticker: ts.sticker).exists?
    refute @user_b.user_stickers.incoming.where(sticker: ts.sticker).exists?
  end

  test "non-confirmed stickers get soft-deleted on end confirmation" do
    trade = create_agreed_trade(@user_a, @user_b)

    login_as @user_b
    ts = trade.trade_stickers.where(receiver: @user_b).first
    return unless ts

    # Don't confirm — just end
    post end_confirmation_trade_receipts_path(trade)

    # Bob's incoming should be soft-deleted
    refute @user_b.user_stickers.incoming.where(sticker: ts.sticker).exists?
    incoming_discarded = UserSticker.unscoped.find_by(user: @user_b, sticker: ts.sticker, state: "incoming")
    assert incoming_discarded&.discarded?
  end

  test "reclaim restores giver duplicate after non-confirmation" do
    trade = create_agreed_trade(@user_a, @user_b)

    # Bob ends confirmation without confirming anything (Alice gave stickers)
    login_as @user_b
    post end_confirmation_trade_receipts_path(trade)

    # Alice reclaims
    login_as @user_a
    ts = trade.trade_stickers.where(giver: @user_a, confirmed_at: nil).first
    return unless ts

    post reclaim_trade_receipts_path(trade), params: { trade_sticker_id: ts.id }
    assert_response :redirect

    # Alice's duplicate should be back
    assert ts.user_sticker.reload.kept?
    assert_equal "duplicate", ts.user_sticker.state
  end

  test "reclaim all restores all unconfirmed giver duplicates" do
    trade = create_agreed_trade(@user_a, @user_b)

    # Bob ends confirmation without confirming
    login_as @user_b
    post end_confirmation_trade_receipts_path(trade)

    # Alice reclaims all
    login_as @user_a
    post reclaim_trade_receipts_path(trade)
    assert_response :redirect

    # All of Alice's given duplicates should be restored
    trade.trade_stickers.where(giver: @user_a, confirmed_at: nil).each do |ts|
      assert ts.user_sticker.reload.kept?, "User sticker #{ts.user_sticker_id} should be restored"
    end
  end

  test "collection reimport does not affect trades" do
    trade = create_agreed_trade(@user_a, @user_b)
    trade_id = trade.id

    # Bob reimports
    CollectionImporter.new(@user_b, { owned: Set.new(1..20), duplicates: {} }).call

    # Trade should still exist
    assert Trade.find(trade_id).present?
    refute Trade.find(trade_id).discarded?
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email }
  end

  def create_agreed_trade(user_a, user_b)
    login_as user_a
    post user_trades_path(user_b)
    trade = Trade.last

    login_as user_a
    post agree_trade_path(trade)

    login_as user_b
    post agree_trade_path(trade)

    trade.reload
  end
end
