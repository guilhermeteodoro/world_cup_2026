# frozen_string_literal: true

class UI::Components::LocaleSwitcher < UI::Base
  def view_template
    current = I18n.locale.to_s

    div(class: "flex items-center justify-center gap-2") do
      languages.map do |param, icon|
        a(
          href: "?locale=#{param}",
          class: "text-xl #{current == param ? "opacity-100" : "opacity-40 hover:opacity-75"}"
        ) { icon }
      end
    end
  end

  private

    def languages
      @languages ||= [
        [ "pt-BR", "🇧🇷" ],
        [ "en", "🇬🇧" ]
      ]
    end
end
