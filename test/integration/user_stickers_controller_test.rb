# frozen_string_literal: true

require "test_helper"

class UserStickersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test", email: "test@example.com", slug: "test123")
    @sticker = Sticker.first
    post session_path, params: { email: @user.email }
  end

  test "glue a sticker" do
    post user_user_stickers_path(@user), params: { sticker_id: @sticker.id }, as: :json

    assert_response :created
    data = response.parsed_body
    assert_equal 0, data["copies"]
    assert @user.user_stickers.exists?(sticker: @sticker, state: "glued")
  end

  test "increment copies" do
    us = @user.user_stickers.create!(sticker: @sticker, state: :glued)

    patch user_user_sticker_path(@user, us), params: { copies: 3 }, as: :json

    assert_response :success
    assert_equal 3, @user.user_stickers.duplicates.where(sticker_id: @sticker.id).count
  end

  test "unglue a sticker" do
    us = @user.user_stickers.create!(sticker: @sticker, state: :glued)

    delete user_user_sticker_path(@user, us), as: :json

    assert_response :no_content
    assert_not @user.user_stickers.exists?(id: us.id)
  end

  test "glue, increment, decrement, unglue flow" do
    # Glue
    post user_user_stickers_path(@user), params: { sticker_id: @sticker.id }, as: :json
    assert_response :created
    us_id = response.parsed_body["id"]

    # Increment to 3
    patch user_user_sticker_path(@user, us_id), params: { copies: 3 }, as: :json
    assert_response :success
    assert_equal 3, response.parsed_body["copies"]

    # Decrement to 1
    patch user_user_sticker_path(@user, us_id), params: { copies: 1 }, as: :json
    assert_response :success
    assert_equal 1, response.parsed_body["copies"]

    # Unglue (only the glued row is discarded, 1 duplicate remains)
    delete user_user_sticker_path(@user, us_id), as: :json
    assert_response :no_content
    assert_equal 1, @user.user_stickers.count
    assert_equal 1, @user.user_stickers.duplicates.count
  end

  test "cannot modify another user's stickers" do
    other_user = User.create!(name: "Other", email: "other@example.com", slug: "other123")

    post user_user_stickers_path(other_user), params: { sticker_id: @sticker.id }, as: :json
    assert_response :forbidden
  end

  test "cannot access when not logged in" do
    delete session_path
    post user_user_stickers_path(@user), params: { sticker_id: @sticker.id }, as: :json
    assert_response :forbidden
  end
end
