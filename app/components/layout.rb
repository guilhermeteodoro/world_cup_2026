# frozen_string_literal: true

class Components::Layout < Components::Base
  def initialize(title: I18n.t("app_name"))
    @title = title
  end

  def view_template
    doctype
    html(lang: "pt-BR") do
      head do
        meta(charset: "utf-8")
        meta(name: "viewport", content: "width=device-width, initial-scale=1")
        title { @title }
        csp_meta_tag
        csrf_meta_tags
        stylesheet_link_tag "tailwind", "data-turbo-track": "reload"
        stylesheet_link_tag :app, "data-turbo-track": "reload"
        javascript_importmap_tags
      end
      body(class: "min-h-screen bg-background") do
        main(class: "max-w-4xl mx-auto px-4 py-8") do
          yield
        end
        render RubyUI::ToastRegion.new(position: :top_right, flash: flash)
      end
    end
  end
end
