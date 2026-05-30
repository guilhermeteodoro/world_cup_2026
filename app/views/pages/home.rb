# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  def view_template
    div(class: "text-center py-16") do
      img(src: image_path("album.png"), alt: "Sticker Album 2026", class: "mx-auto mb-8 max-w-xs")

      h1(class: "text-4xl font-bold text-foreground mb-4") { t("pages.home.title") }
      p(class: "text-lg text-muted-foreground mb-8") { t("pages.home.subtitle") }

      div(class: "flex items-center justify-center gap-4 mb-6") do
        Link(variant: :primary, href: new_registration_path) { t("pages.home.cta") }
        Link(variant: :outline, href: new_session_path) { t("nav.login") }
      end

      render_locale_switcher
    end
  end

  private

  def render_locale_switcher
    current = I18n.locale.to_s

    div(class: "flex items-center justify-center gap-2 mt-4") do
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
