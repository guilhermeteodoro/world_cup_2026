# frozen_string_literal: true

class UI::Fragments::AlbumGrid < UI::Base
  def initialize(user:, stickers_by_country:, user_stickers_index:)
    @user = user
    @stickers_by_country = stickers_by_country
    @user_stickers_index = user_stickers_index
  end

  def view_template
    div(class: "space-y-1 px-2", data: { controller: "album-toggle" }) do
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

  def light_color?(hex)
    return false unless hex
    r, g, b = hex.match(/#(..)(..)(..)/).captures.map { |c| c.to_i(16) }
    luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
    luminance > 0.55
  end

  def render_country_section(country, stickers)
    owned = stickers.count { |s| @user_stickers_index.dig(s.id, :state) == "glued" }
    total = stickers.size
    dups = stickers.sum { |s| @user_stickers_index.dig(s.id, :copies) || 0 }
    to_glue = stickers.count { |s| @user_stickers_index.dig(s.id, :to_be_glued) }

    render UI::Components::Collapsible.new(open: false, persist_key: "album_#{@user.id}_#{country.code}") do |c|
      c.trigger(class: "flex items-center gap-2 py-3 px-3 cursor-pointer bg-gray-200 text-gray-800 rounded-lg") do
        c.icon(class: "text-sm") { "▼" }
        span(class: "font-semibold text-sm") { "#{country.emoji} #{country.code}" }
        span(class: "italic font-extralight font-stretch-50% text-sm text-gray-500") { country.name }
        span(class: "text-xs text-gray-500") { "#{owned}/#{total}" }
        span(class: "text-xs text-gray-500") { "(#{dups} dups)" } if dups > 0
        span(class: "text-xs text-amber-600", data: { new_count: true }) { t(".new_count", count: to_glue) } if to_glue > 0
      end

      c.content do
        div(class: "grid grid-cols-4 sm:grid-cols-8 md:grid-cols-10 gap-1.5 p-2 bg-gray-200 rounded-b-lg") do
          stickers.each do |sticker|
            render_card(sticker, country)
          end
        end
      end
    end
  end

  def render_card(sticker, country)
    us = @user_stickers_index[sticker.id]
    glued = us.present? && us[:state] == "glued"
    to_be_glued = us&.dig(:to_be_glued) || false
    copies = us&.dig(:copies) || 0
    user_sticker_id = us&.dig(:id) || (to_be_glued ? us[:to_be_glued_id] : 0)

    base_url = user_user_stickers_path(@user)
    color = country.color || "#6B7280"
    is_foil = sticker.shiny?
    has_copies = copies > 0
    owned = glued || to_be_glued

    text_class = light_color?(color) ? "text-gray-900 [text-shadow:_0_1px_0_rgba(255,255,255,0.3)]" : "text-white [text-shadow:_0_1px_2px_rgba(0,0,0,0.5)]"

    group_classes = if owned
      "opacity-100"
    else
      "opacity-0 pointer-events-none"
    end
    group_classes += " folded-corner" if to_be_glued

    group_style = if to_be_glued
      "transform: rotate(2deg) translate(2px, 2px)"
    else
      ""
    end

    card_classes = if owned
      "#{text_class}"
    else
      ""
    end
    card_classes += " foil-card" if owned && is_foil

    group_filter = has_copies ? "filter: drop-shadow(3px 3px 0 #374151)" : nil

    # Wrapper
    div(class: "relative", data: { controller: "album-card",
      album_card_sticker_id_value: sticker.id,
      album_card_user_sticker_id_value: user_sticker_id,
      album_card_copies_value: copies,
      album_card_glued_value: glued,
      album_card_to_be_glued_value: to_be_glued,
      album_card_color_value: color,
      album_card_foil_value: is_foil,
      album_card_dark_text_value: light_color?(color),
      album_card_create_url_value: base_url,
      album_card_update_url_value: owned ? "#{base_url}/#{user_sticker_id}" : "",
      album_card_destroy_url_value: owned ? "#{base_url}/#{user_sticker_id}" : "",
      action: "click->album-card#glue" }) do
      # Placeholder (relative — sets the height)
      div(
        class: "border rounded border-gray-300 p-1 opacity-50 text-gray-600 bg-gray-100 flex flex-col select-none cursor-pointer aspect-5/7",
        data: { album_card_target: "placeholder" }
      ) do
        div(class: "flex items-start justify-between text-sm leading-none") do
          span(class: "font-extralight text-nowrap font-stretch-50% opacity-50") { sticker.country.code }
          span(class: "font-black tracking-tight tabular-nums") { sticker.number }
        end
        div(class: "flex-1 flex flex-col items-center justify-center text-center px-0.5") do
          render_sticker_name(sticker)
        end
      end

      # Hover wrapper — scales card + badge together
      div(class: "absolute inset-0 z-10 transition-transform hover:scale-105 hover:brightness-105") do
        # Card group — owns clip-path and transform
        div(
          class: "absolute inset-0 #{group_classes}",
          style: [ group_style.presence, group_filter ].compact.join("; ").presence,
          data: { album_card_target: "cardGroup" }
        ) do
          # Top card
          div(
            class: "w-full h-full border rounded border-gray-300 p-1 select-none flex flex-col #{card_classes}",
            style: owned ? "background-color: #{color}" : nil,
            data: { album_card_target: "topCard" }
          ) do
            div(class: "flex items-start justify-between text-sm leading-none") do
              span(class: "font-extralight text-nowrap font-stretch-50% opacity-50") { sticker.country.code }
              span(class: "font-black tracking-tight tabular-nums") { sticker.number }
            end
            div(class: "flex-1 flex flex-col items-center justify-center text-center px-0.5") do
              render_sticker_name(sticker)
            end

            if owned
              div(data: { album_card_target: "actions" }) do
                div(class: "grid grid-cols-2 gap-1") do
                  btn_color = light_color?(color) ? "bg-black/20 text-gray-900" : "bg-white/30 text-white"
                  button_class = "h-8 sm:h-6 rounded-lg #{btn_color} text-xs font-bold active:scale-95 cursor-pointer"

                  button(
                    type: "button",
                    class: button_class,
                    data: { action: "click->album-card#decrement" }
                  ) { "−" }
                  button(
                    type: "button",
                    class: button_class,
                    data: { action: "click->album-card#increment" }
                  ) { "+" }
                end
              end
            end
          end

          # Fold flap — square in top-right, clipped by parent's polygon
          div(class: "fold-flap absolute top-0 right-0 w-[40%] h-[40%] rounded-bl border border-gray-300 bg-gradient-to-bl from-white to-gray-100 shadow-[-2px_2px_3px_rgba(0,0,0,0.15)] pointer-events-none")
        end

        # Badge — outside cardGroup so clip-path doesn't cut it
        span(
          class: "absolute z-30 -bottom-1 -right-1 bg-[#374151] rounded text-[9px] font-bold text-white w-4 h-4 flex items-center justify-center #{copies > 0 ? "" : "hidden"}",
          data: { album_card_target: "badge" }
        ) { copies }
      end
    end
  end

  def render_sticker_name(sticker)
    return unless sticker.name

    if sticker.shiny? || sticker.name == "Team Photo"
      # FWC specials + Team Logo + Team Photo: show full name centered
      span(class: "text-[9px] sm:text-[10px] leading-tight opacity-75 italic") { sticker.name.sub(" (Foil)", "") }
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
