# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  def view_template
    div(class: "text-center py-16") do
      h1(class: "text-4xl font-bold text-gray-900 mb-4") { t("pages.home.title") }
      p(class: "text-lg text-gray-600 mb-8") { t("pages.home.subtitle") }

      div(class: "space-y-4") do
        a(href: new_registration_path, class: "inline-block bg-green-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-700") do
          t("pages.home.cta")
        end
      end
    end
  end
end
