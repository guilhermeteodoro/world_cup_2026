# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  def view_template
    div(class: "text-center py-16") do
      h1(class: "text-4xl font-bold text-gray-900 mb-4") { "⚽ Figurinhas 2026" }
      p(class: "text-lg text-gray-600 mb-8") do
        "Compare your World Cup 2026 sticker collection with friends and find trades."
      end

      div(class: "space-y-4") do
        a(href: new_registration_path, class: "inline-block bg-green-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-700") do
          "Register your collection"
        end
      end
    end
  end
end
