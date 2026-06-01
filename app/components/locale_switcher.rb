# frozen_string_literal: true

class Components::LocaleSwitcher < Components::Base
  def view_template
    current = I18n.locale.to_s

    div(class: "flex items-center gap-2") do
      a(
        href: "?locale=pt-BR",
        class: "text-xl #{current == "pt-BR" ? "opacity-100" : "opacity-40 hover:opacity-75"}"
      ) { "🇧🇷" }
      a(
        href: "?locale=en",
        class: "text-xl #{current == "en" ? "opacity-100" : "opacity-40 hover:opacity-75"}"
      ) { "🇬🇧" }
    end
  end
end
