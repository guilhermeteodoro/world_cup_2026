# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  def view_template
    h1(class: "text-2xl font-bold text-gray-900 mb-6") { t("sessions.new.title") }

    form(action: session_path, method: "post") do
      authenticity_token_tag

      div(class: "mb-6") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { t("sessions.new.email_label") }
        input(
          type: "email", name: "email", required: true, autofocus: true,
          class: "w-full border border-gray-300 rounded-lg p-3",
          placeholder: t("sessions.new.email_placeholder")
        )
      end

      div(class: "mt-6") do
        button(type: "submit", class: "bg-green-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-700") do
          t("sessions.new.submit")
        end
      end
    end

    p(class: "mt-4 text-sm text-gray-500") do
      plain "#{t("sessions.new.no_account")} "
      a(href: new_registration_path, class: "text-green-600 hover:underline") { t("sessions.new.register_link") }
    end
  end

  private

  def authenticity_token_tag
    input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
  end
end
