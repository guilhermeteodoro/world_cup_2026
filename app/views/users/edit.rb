# frozen_string_literal: true

class Views::Users::Edit < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    h1(class: "text-2xl font-bold text-gray-900 mb-6") { "Account settings" }

    form(action: user_path(@user), method: "post") do
      input(type: "hidden", name: "_method", value: "patch")
      authenticity_token_tag

      div(class: "mb-6") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { "Name" }
        input(
          type: "text", name: "name", required: true, value: @user.name,
          class: "w-full border border-gray-300 rounded-lg p-3"
        )
      end

      div(class: "mb-6") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { "Email" }
        input(
          type: "email", name: "email", required: true, value: @user.email,
          class: "w-full border border-gray-300 rounded-lg p-3"
        )
      end

      div(class: "mt-6") do
        button(type: "submit", class: "bg-green-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-700") do
          "Save"
        end
      end
    end
  end

  private

  def authenticity_token_tag
    input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
  end
end
