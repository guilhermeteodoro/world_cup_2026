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
        div(class: "grid grid-cols-5 sm:grid-cols-8 md:grid-cols-10 gap-1.5 p-2") do
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
    is_foil = sticker.shiny?

    div(
      class: "relative rounded-md border border-gray-900 p-1 text-left cursor-pointer select-none aspect-[5/7] flex flex-col justify-between #{glued ? "text-white" : "opacity-50"}",
      style: glued ? "background: linear-gradient(135deg, #{color} 0%, #{color}cc 100%)" : "",
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
      # Foil indicator + number top section
      div(class: "flex items-start justify-between") do
        span(class: "text-[9px]") { "✨" } if is_foil
        span(class: "text-[9px]") { "" } unless is_foil
      end

      # Extras badge (green circle)
      span(
        class: "absolute -top-1 -right-1 bg-green-600 text-white rounded-full w-4 h-4 text-[8px] flex items-center justify-center font-bold border border-gray-900 #{copies > 0 ? "" : "hidden"}",
        data: { album_card_target: "badge" }
      ) { copies.to_s }

      # Content: number + name
      div(class: "flex flex-col items-end") do
        span(class: "font-black text-sm leading-none tracking-tight tabular-nums") { sticker.number }
        span(class: "text-[7px] leading-tight truncate max-w-full opacity-75 mt-0.5") { sticker.name } if sticker.name
      end

      # +/- actions (invisible but space-reserving when not glued)
      div(
        class: "flex items-center justify-center gap-0.5 #{glued ? "" : "invisible"}",
        data: { album_card_target: "actions" }
      ) do
        button(
          type: "button",
          class: "w-4 h-4 rounded bg-white/30 text-white text-[10px] font-bold active:scale-95",
          data: { action: "click->album-card#decrement" }
        ) { "−" }
        button(
          type: "button",
          class: "w-4 h-4 rounded bg-white/30 text-white text-[10px] font-bold active:scale-95",
          data: { action: "click->album-card#increment" }
        ) { "+" }
      end
    end
  end
end
