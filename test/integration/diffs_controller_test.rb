# frozen_string_literal: true

require "test_helper"

class DiffsControllerTest < ActionDispatch::IntegrationTest
  test "GET /diff loads successfully" do
    get diff_path
    assert_response :success
  end

  test "POST /diff renders results" do
    post diff_path, params: {
      list_a: "FWC: 00, 3, 4",
      list_b: "FWC: 00, 3"
    }
    assert_response :success
  end
end
