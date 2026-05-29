# frozen_string_literal: true

class Components::Layout < Components::Base
  def initialize(title: "Figurinhas 2026", current_user: nil)
    @title = title
    @current_user = current_user
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
      body(class: "min-h-screen bg-gray-50") do
        render Components::Nav.new(current_user: @current_user)
        main(class: "max-w-4xl mx-auto px-4 py-8") do
          render_flash
          yield
        end
      end
    end
  end

  private

  def render_flash
    if flash[:notice]
      div(class: "mb-4 p-4 bg-green-50 border border-green-200 rounded-lg text-green-800 text-sm") do
        plain flash[:notice]
      end
    end
    if flash[:error]
      div(class: "mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-800 text-sm") do
        plain flash[:error]
      end
    end
  end
end
