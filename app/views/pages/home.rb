# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  def view_template
    div(class: "text-center py-16") do
      h1(class: "text-4xl font-bold text-foreground mb-4") { t("pages.home.title") }
      p(class: "text-lg text-muted-foreground mb-8") { t("pages.home.subtitle") }

      Link(variant: :primary, href: new_registration_path) { t("pages.home.cta") }
    end
  end
end
