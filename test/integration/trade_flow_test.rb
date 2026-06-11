# frozen_string_literal: true

require "test_helper"

class TradeFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user_a = create_user(name: "Alice", email: "alice@test.com")
    @user_b = create_user(name: "Bob", email: "bob@test.com")

    # Alice owns positions 1-10, dupe at 1
    CollectionImporter.new(@user_a, { owned: Set.new(1..10), duplicates: { 1 => 1 } }).call
    # Bob owns positions 5-15, dupe at 11
    CollectionImporter.new(@user_b, { owned: Set.new(5..15), duplicates: { 11 => 1 } }).call
  end

  test "create trade pre-loaded with balanced suggestion" do
    login_as @user_a

    post user_trades_path(@user_b)
    assert_response :redirect

    trade = Trade.last
    assert_equal @user_a.id, trade.user_a_id
    assert_equal @user_b.id, trade.user_b_id
    assert_nil trade.confirmed_at
    assert trade.trade_stickers.any?

    follow_redirect!
    assert_response :success
  end

  test "accept trade from both sides triggers agreement" do
    trade = create_trade_between(@user_a, @user_b)

    login_as @user_a
    post agree_trade_path(trade)
    trade.reload
    assert trade.accepted_by?(@user_a)
    refute trade.agreed?

    login_as @user_b
    post agree_trade_path(trade)
    trade.reload
    assert trade.agreed?
    assert trade.confirmed_at.present?
  end

  test "modifying trade resets other's acceptance" do
    trade = create_trade_between(@user_a, @user_b)

    # Alice accepts
    login_as @user_a
    post agree_trade_path(trade)
    trade.reload
    assert trade.accepted_by?(@user_a)

    # Bob modifies (removes a sticker)
    login_as @user_b
    ts = trade.trade_stickers.first
    patch trade_path(trade), params: { action_type: "remove", trade_sticker_id: ts.id }
    trade.reload
    refute trade.accepted_by?(@user_a)
  end

  test "cancel trade soft-deletes it" do
    trade = create_trade_between(@user_a, @user_b)

    login_as @user_a
    post cancel_trade_path(trade)

    assert_response :redirect
    assert trade.reload.discarded?
  end

  test "receipt confirmation creates to_be_glued sticker" do
    trade = create_agreed_trade(@user_a, @user_b)

    login_as @user_b
    ts = trade.trade_stickers.where(receiver: @user_b).first

    # Toggle confirm
    patch trade_receipt_path(trade, ts), params: { confirmed: "true" }
    assert ts.reload.confirmed_at.present?

    # End confirmation
    assert_difference -> { @user_b.user_stickers.to_be_glued.count }, 1 do
      post end_confirmation_trade_receipts_path(trade)
    end

    assert trade.reload.user_b_receipt_ended_at.present?
  end

  test "glue_all applies to_be_glued stickers" do
    # Give Bob a to_be_glued sticker he's missing
    sticker = Sticker.find_by(position: 1) # Bob is missing position 1
    @user_b.user_stickers.create!(sticker: sticker, state: :to_be_glued)

    login_as @user_b
    post glue_all_user_user_stickers_path(@user_b)

    assert_response :redirect
    us = @user_b.user_stickers.find_by(sticker: sticker, state: :glued)
    assert us.present?
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email }
  end

  def create_trade_between(user_a, user_b)
    login_as user_a
    post user_trades_path(user_b)
    Trade.last
  end

  def create_agreed_trade(user_a, user_b)
    trade = create_trade_between(user_a, user_b)

    login_as user_a
    post agree_trade_path(trade)

    login_as user_b
    post agree_trade_path(trade)

    trade.reload
  end
end
