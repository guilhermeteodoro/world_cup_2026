# frozen_string_literal: true

class Components::StickerList < Components::Base
  def initialize(stickers:, copyable: false)
    @stickers = stickers
    @copyable = copyable
  end

  def view_template
    if @copyable
      div(data: { controller: "clipboard", clipboard_text_value: clipboard_text }) do
        div(class: "flex items-center justify-end mb-1") do
          Button(variant: :ghost, size: :sm, type: "button", data: { action: "clipboard#copy", copy_button: "" }) { t(".copy") }
        end
        render_grouped_stickers
      end
    else
      render_grouped_stickers
    end
  end

  private

  def render_grouped_stickers
    grouped = @stickers.group_by(&:country)
    div(class: "text-sm font-mono") do
      grouped.each do |country, country_stickers|
        p do
          span(class: "font-semibold") { "#{country.emoji} #{country.code}: " }
          plain country_stickers.map(&:number).join(", ")
        end
      end
    end
  end

  def clipboard_text
    Sticker.format_as_text(@stickers)
  end
end
