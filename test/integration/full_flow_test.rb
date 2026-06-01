# frozen_string_literal: true

require "test_helper"

class FullFlowTest < ActionDispatch::IntegrationTest
  test "user registers from home, sees their collection" do
    # 1. Visit home
    get root_path
    assert_response :success
    assert_includes response.body, I18n.t("views.pages.home.cta")

    # 2. Visit registration page
    get new_registration_path
    assert_response :success
    assert_includes response.body, I18n.t("views.registrations.new.title")

    # 3. Submit registration with dump
    post registration_path, params: {
      name: "Guilherme",
      email: "gui@example.com",
      import_method: "dump",
      dump: sample_dump
    }

    # 4. Should redirect to collection page
    assert_response :redirect
    user = User.find_by(email: "gui@example.com")
    assert_not_nil user
    assert_redirected_to user_path(user)

    # 5. Follow redirect and assert collection info
    follow_redirect!
    assert_response :success

    # User name in title
    assert_includes response.body, "Guilherme"

    # Stats
    assert_includes response.body, "591/994"
    assert_includes response.body, "403"
    assert_includes response.body, "202"

    # Duplicates section with sticker data
    assert_includes response.body, "FWC:"
    assert_includes response.body, "BRA:"

    # Owner actions visible
    # Owner edit link (pencil emoji)
    assert_includes response.body, edit_user_collection_path(user)
    # Account settings in popover menu
    assert_includes response.body, edit_user_path(user)

    # Clipboard data attribute present
    assert_includes response.body, "data-clipboard-text-value"
  end

  test "user registers, logs out, logs back in, sees collection" do
    # Register
    post registration_path, params: {
      name: "Vitor",
      email: "vitor@example.com",
      import_method: "dump",
      dump: "SA26|1|1-20|1:1,2:1,3:1"
    }
    user = User.find_by(email: "vitor@example.com")
    follow_redirect!
    assert_includes response.body, "Vitor"

    # Log out
    delete session_path
    follow_redirect!
    assert_response :success

    # Log back in
    post session_path, params: { email: "vitor@example.com" }
    assert_redirected_to user_path(user)
    follow_redirect!
    assert_includes response.body, "Vitor"
    assert_includes response.body, "20/994"
  end

  test "two users register and see trade comparison" do
    # User A registers
    post registration_path, params: {
      name: "Alice",
      email: "alice@example.com",
      import_method: "dump",
      dump: "SA26|1|1-20|1:1,2:1,3:1"
    }
    user_a = User.find_by(email: "alice@example.com")

    # Log out
    delete session_path

    # User B registers
    post registration_path, params: {
      name: "Bob",
      email: "bob@example.com",
      import_method: "dump",
      dump: "SA26|1|10-30|11:1,12:1,13:1"
    }
    user_b = User.find_by(email: "bob@example.com")

    # User B views User A's page → sees trade comparison
    get user_path(user_a)
    assert_response :success
    assert_includes response.body, I18n.t("views.users.show.trade_title", name: "Alice")
    assert_includes response.body, "Bob →"
    assert_includes response.body, "Alice →"
  end
end
