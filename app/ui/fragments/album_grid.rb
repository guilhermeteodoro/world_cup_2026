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
    is_team_photo = sticker.name == "Team Photo"

    card_bg_class = if glued && is_foil
      "foil-card"
    elsif glued
      ""
    else
      "bg-gray-100"
    end

    div(
      class: "relative rounded-md border border-gray-900 p-1 cursor-pointer select-none aspect-[5/7] flex flex-col #{glued ? "text-white [text-shadow:_0_1px_2px_rgba(0,0,0,0.5)]" : "opacity-50"} #{card_bg_class}",
      style: glued ? "background-color: #{color}" : "",
      data: {
        controller: "album-card",
        album_card_sticker_id_value: sticker.id,
        album_card_user_sticker_id_value: user_sticker_id,
        album_card_copies_value: copies,
        album_card_glued_value: glued,
        album_card_color_value: color,
        album_card_foil_value: is_foil,
        album_card_create_url_value: base_url,
        album_card_update_url_value: glued ? "#{base_url}/#{user_sticker_id}" : "",
        album_card_destroy_url_value: glued ? "#{base_url}/#{user_sticker_id}" : "",
        action: "click->album-card#glue"
      }
    ) do
      # Top row: number right-aligned
      div(class: "flex items-start justify-end") do
        span(class: "font-black text-sm leading-none tracking-tight tabular-nums") { sticker.number }
      end

      # Extras badge (green circle) - bottom right
      span(
        class: "absolute -bottom-1 -right-1 bg-green-600 text-white rounded-full w-4 h-4 text-[8px] flex items-center justify-center font-bold border border-gray-900 #{copies > 0 ? "" : "hidden"}",
        data: { album_card_target: "badge" }
      ) { copies.to_s }

      # Center: player name
      div(class: "flex-1 flex flex-col items-center justify-center text-center px-0.5") do
        render_sticker_name(sticker)
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

  def render_sticker_name(sticker)
    return unless sticker.name

    if sticker.shiny? || sticker.name == "Team Photo"
      # FWC specials + Team Logo + Team Photo: show full name centered
      span(class: "text-[9px] sm:text-[10px] leading-tight opacity-75") { sticker.name.sub(" (Foil)", "") }
    else
      # Players (normal + coke): Last Name bold, First Name below
      parts = sticker.name.split(" ", 2)
      if parts.size == 1
        span(class: "text-[9px] sm:text-[10px] font-bold leading-tight") { parts[0] }
      else
        name_parts = sticker.name.split
        if name_parts.size >= 2
          last_name = name_parts.last
          first_name = name_parts[0..-2].join(" ")
        end
        span(class: "text-[9px] sm:text-[10px] font-bold leading-tight truncate max-w-full") { last_name }
        span(class: "text-[7px] sm:text-[8px] leading-tight truncate max-w-full opacity-75") { first_name }
      end
    end
  end
end
