# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  def view_template
    h1(class: "text-2xl font-bold text-gray-900 mb-6") { "Log in" }

    form(action: session_path, method: "post") do
      authenticity_token_tag

      div(class: "mb-6") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { "Your email" }
        input(
          type: "email", name: "email", required: true, autofocus: true,
          class: "w-full border border-gray-300 rounded-lg p-3",
          placeholder: "e.g. gui@example.com"
        )
      end

      div(class: "mt-6") do
        button(type: "submit", class: "bg-green-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-700") do
          "Log in"
        end
      end
    end

    p(class: "mt-4 text-sm text-gray-500") do
      plain "Don't have an account? "
      a(href: new_registration_path, class: "text-green-600 hover:underline") { "Register" }
    end
  end

  private

  def authenticity_token_tag
    input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
  end
end
