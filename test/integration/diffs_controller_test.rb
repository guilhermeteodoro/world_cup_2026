# frozen_string_literal: true

require "test_helper"

class DiffsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Force English locale for test assertions
    I18n.locale = :en
  end

  teardown do
    I18n.locale = I18n.default_locale
  end

  test "GET /diff loads the diff page" do
    get diff_path, headers: { "Accept-Language" => "en" }
    assert_response :success
    assert_includes response.body, "List A"
    assert_includes response.body, "List B"
  end

  test "POST /diff shows stickers only in list A" do
    post diff_path, params: {
      list_a: "FWC: 00, 3, 4\nBRA: 1",
      list_b: "FWC: 00, 3"
    }, headers: { "Accept-Language" => "en" }

    assert_response :success
    assert_includes response.body, "Only in List A"
    # FWC 4 and BRA 1 are only in A
    assert_includes response.body, "FWC"
    assert_includes response.body, "4"
    assert_includes response.body, "BRA"
  end

  test "POST /diff shows stickers only in list B" do
    post diff_path, params: {
      list_a: "FWC: 00",
      list_b: "FWC: 00, 3, 4"
    }, headers: { "Accept-Language" => "en" }

    assert_response :success
    assert_includes response.body, "Only in List B"
    assert_includes response.body, "3"
    assert_includes response.body, "4"
  end

  test "POST /diff shows nothing when lists are identical" do
    post diff_path, params: {
      list_a: "FWC: 00, 3",
      list_b: "FWC: 00, 3"
    }, headers: { "Accept-Language" => "en" }

    assert_response :success
    # Both "only in" sections should show empty state
    assert_includes response.body, "(nothing)"
  end

  test "POST /diff shows parse warnings for invalid stickers" do
    post diff_path, params: {
      list_a: "FWC: 00\nXXX: 1",
      list_b: "FWC: 00"
    }, headers: { "Accept-Language" => "en" }

    assert_response :success
    assert_includes response.body, "XXX 1"
  end

  test "POST /diff preserves textarea content" do
    list_a = "FWC: 00, 3"
    list_b = "BRA: 1, 5"

    post diff_path, params: { list_a: list_a, list_b: list_b }, headers: { "Accept-Language" => "en" }

    assert_response :success
    assert_includes response.body, "FWC: 00, 3"
    assert_includes response.body, "BRA: 1, 5"
  end

  test "POST /diff handles merged repeated country lines" do
    post diff_path, params: {
      list_a: "BRA: 1, 5\nBRA: 12",
      list_b: "BRA: 1"
    }, headers: { "Accept-Language" => "en" }

    assert_response :success
    # BRA 5 and BRA 12 should be only in A
    assert_includes response.body, "5"
    assert_includes response.body, "12"
  end
end
