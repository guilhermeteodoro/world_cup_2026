# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  def view_template
    div(class: "text-center py-16") do
      img(src: image_path("album.png"), alt: "Sticker Album 2026", class: "mx-auto mb-8 w-1/5 max-w-xs")

      h1(class: "text-4xl font-bold text-foreground mb-4") { t("pages.home.title") }
      p(class: "text-lg text-muted-foreground mb-8") { t("pages.home.subtitle") }

      div(class: "flex items-center justify-center gap-4 mb-6") do
        Link(variant: :primary, href: new_registration_path) { t("pages.home.cta") }
        Link(variant: :outline, href: new_session_path) { t("nav.login") }
      end

      div(class: "flex justify-center mt-4") do
        render Components::LocaleSwitcher.new
      end
    end
  end
end
