# frozen_string_literal: true

require "test_helper"

class RouteSmokeTest < ActionDispatch::IntegrationTest
  test "home page loads" do
    get root_path
    assert_response :success
  end

  test "registration page loads" do
    get new_registration_path
    assert_response :success
  end

  test "login page loads" do
    get new_session_path
    assert_response :success
  end

  test "user collection page loads" do
    user = create_user(name: "Smoke", email: "smoke@test.com", dump: sample_dump)
    get user_path(user)
    assert_response :success
  end

  test "user collection page shows stats" do
    user = create_user(name: "Smoke", email: "smoke@test.com", dump: sample_dump)
    get user_path(user)
    assert_includes response.body, "591/994"
  end

  test "collection edit requires login" do
    user = create_user(name: "Locked", email: "locked@test.com", dump: sample_dump)
    get edit_user_collection_path(user)
    assert_redirected_to root_path
  end

  test "registration creates user and redirects" do
    post registration_path, params: {
      name: "NewUser",
      email: "new@test.com",
      import_method: "dump",
      dump: "SA26|1|1-5|1:1,2:1"
    }
    user = User.find_by(email: "new@test.com")
    assert_not_nil user
    assert_redirected_to user_path(user)
    assert_equal 5, user.owned_count
  end

  test "login with existing email redirects to profile" do
    user = create_user(name: "Existing", email: "existing@test.com", dump: sample_dump)
    post session_path, params: { email: "existing@test.com" }
    assert_redirected_to user_path(user)
  end

  test "login with unknown email redirects to registration" do
    post session_path, params: { email: "unknown@test.com" }
    assert_redirected_to new_registration_path(email: "unknown@test.com")
  end

  test "diff page loads without login" do
    get diff_path
    assert_response :success
  end
end
