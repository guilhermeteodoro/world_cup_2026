# frozen_string_literal: true

class UI::Fragments::AlbumGrid < UI::Base
  def initialize(user:, stickers_by_country:, user_stickers_index:)
    @user = user
    @stickers_by_country = stickers_by_country
    @user_stickers_index = user_stickers_index
  end

  def view_template
    div(class: "space-y-2 px-2", data: { controller: "album-toggle" }) do
      div(class: "flex items-center justify-between mb-2") do
        Heading(level: 3) { t(".title") }
        button(
          type: "button",
          class: "text-xs text-muted-foreground hover:text-foreground px-2 py-1 rounded border",
          data: {
            action: "click->album-toggle#toggleAll",
            album_toggle_target: "btn",
            expand_text: t(".expand_all"),
            collapse_text: t(".collapse_all")
          }
        ) { t(".expand_all") }
      end

      @stickers_by_country.each do |country, stickers|
        render_country_section(country, stickers)
      end
    end
  end

  private

  def render_country_section(country, stickers)
    owned = stickers.count { |s| @user_stickers_index.key?(s.id) }
    total = stickers.size
    dups = stickers.sum { |s| @user_stickers_index.dig(s.id, :copies) || 0 }

    Collapsible do
      CollapsibleTrigger do
        div(class: "flex items-center gap-2 py-3 px-3 cursor-pointer bg-muted/50 rounded-lg") do
          span(class: "transition-transform duration-200 text-sm", data: { ruby_ui__collapsible_target: "icon" }) { "▼" }
          span(class: "font-semibold text-sm") { "#{country.emoji} #{country.code}" }
          span(class: "text-xs text-muted-foreground") { "#{owned}/#{total}" }
          span(class: "text-xs text-muted-foreground") { "(#{dups} dups)" } if dups > 0
        end
      end

      CollapsibleContent(class: "hidden") do
        div(class: "grid grid-cols-5 sm:grid-cols-8 md:grid-cols-10 gap-2 p-2") do
          stickers.each do |sticker|
            render_card(sticker, country)
          end
        end
      end
    end
  end

  def render_card(sticker, country)
    us = @user_stickers_index[sticker.id]
    glued = us.present?
    copies = us&.dig(:copies) || 0
    user_sticker_id = us&.dig(:id) || 0

    base_url = user_user_stickers_path(@user)
    color = country.color || "#6B7280"

    div(
      class: "relative rounded-lg border p-2 text-center text-xs cursor-pointer select-none #{glued ? "text-white border-transparent" : "text-gray-600 border-gray-300 bg-gray-50"}",
      style: glued ? "background-color: #{color}" : "",
      data: {
        controller: "album-card",
        album_card_sticker_id_value: sticker.id,
        album_card_user_sticker_id_value: user_sticker_id,
        album_card_copies_value: copies,
        album_card_glued_value: glued,
        album_card_color_value: color,
        album_card_create_url_value: base_url,
        album_card_update_url_value: glued ? "#{base_url}/#{user_sticker_id}" : "",
        album_card_destroy_url_value: glued ? "#{base_url}/#{user_sticker_id}" : "",
        action: "click->album-card#glue"
      }
    ) do
      # Badge for copies count
      span(
        class: "absolute -top-1 -right-1 bg-primary text-primary-foreground rounded-full w-5 h-5 text-[10px] flex items-center justify-center font-bold #{copies > 0 ? "" : "hidden"}",
        data: { album_card_target: "badge" }
      ) { copies.to_s }

      # Sticker label
      span(class: "font-mono font-medium leading-tight block") { "#{country.code} #{sticker.number}" }

      # +/- actions (invisible but space-reserving when not glued)
      div(
        class: "flex items-center justify-center gap-1 mt-1 #{glued ? "" : "invisible"}",
        data: { album_card_target: "actions" }
      ) do
        button(
          type: "button",
          class: "w-6 h-6 rounded bg-white/30 text-white text-sm font-bold active:scale-95",
          data: { action: "click->album-card#decrement" }
        ) { "−" }
        button(
          type: "button",
          class: "w-6 h-6 rounded bg-white/30 text-white text-sm font-bold active:scale-95",
          data: { action: "click->album-card#increment" }
        ) { "+" }
      end
    end
  end
end
