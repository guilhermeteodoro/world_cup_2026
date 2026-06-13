# frozen_string_literal: true

class Views::Users::ShowOwner < Views::LoggedIn
  def initialize(user:, current_user:)
    @user = user
    @current_user = current_user
  end

  def page_title
    t(".title")
  end

  def render_title
    div do
      div(class: "flex items-center gap-2 mb-2") do
        Heading(level: 2) { t(".title") }
        Link(href: edit_user_collection_path(@user), variant: :ghost, icon: true, class: "text-muted-foreground") { "✏️" }
      end

      div(class: "flex flex-wrap gap-3 text-sm") do
        Badge(variant: :outline) { t(".owned", count: @user.owned_count) }
        Badge(variant: :outline) { t(".missing", count: @user.missing_count) }
      end
    end
  end

  def render_content
    div(data: { controller: "tabs", tabs_active_value: "album" }) do
      render_tab_bar
      render_album_panel
      render_trades_panel
    end
  end

  private

  def render_tab_bar
    pending_count = @user.pending_trades_count

    div(class: "flex gap-4 border-b mb-6") do
      button(
        type: "button",
        class: "pb-2 px-1 text-sm font-medium border-b-2 transition-colors border-primary text-foreground",
        data: { tabs_target: "tab", tab: "album", action: "click->tabs#switch" }
      ) { t(".tab_album") }
      button(
        type: "button",
        class: "pb-2 px-1 text-sm font-medium border-b-2 transition-colors border-transparent text-muted-foreground",
        data: { tabs_target: "tab", tab: "trades", action: "click->tabs#switch" }
      ) do
        plain t(".tab_trades")
        if pending_count > 0
          span(class: "ml-1 inline-flex items-center justify-center w-5 h-5 text-xs font-bold text-white bg-primary rounded-full") { pending_count.to_s }
        end
      end
    end
  end

  def render_album_panel
    div(data: { tabs_target: "panel", tab: "album" }) do
      render_album_grid
    end
  end

  def render_trades_panel
    div(class: "hidden", data: { tabs_target: "panel", tab: "trades" }) do
      render_incoming_card
      render_pending_trades
      render_glue_all_button
      render_trade_history
      render_duplicates
    end
  end

  def render_incoming_card
    incoming_count = @user.user_stickers.incoming.count
    return if incoming_count == 0

    div(class: "mb-6") do
      Card(class: "border-blue-200 bg-blue-50") do
        CardContent(class: "py-3") do
          div(class: "flex items-center gap-2 mb-1") do
            p(class: "text-sm font-medium") { t(".incoming_count", count: incoming_count) }
          end
          p(class: "text-xs text-muted-foreground") { t(".incoming_warning") }
        end
      end
    end
  end

  def render_pending_trades
    pending = @user.pending_trades
    return if pending.empty?

    div(class: "mb-6") do
      Heading(level: 3, class: "mb-4") { t(".pending_trades") }

      div(class: "space-y-2") do
        pending.each do |trade|
          other = trade.other_user(@user)
          a(href: trade_path(trade), class: "block") do
            Card(class: "hover:border-primary transition-colors") do
              CardContent(class: "flex items-center justify-between py-3") do
                div do
                  p(class: "font-medium text-sm") { other.name }
                  p(class: "text-xs text-muted-foreground") { "#{trade.trade_stickers.count} stickers" }
                end
                if trade.agreed?
                  Badge(variant: :default) { t(".status_agreed") }
                elsif trade.accepted_by?(@user)
                  Badge(variant: :outline) { t(".status_waiting") }
                else
                  Badge(variant: :outline) { t(".status_negotiating") }
                end
              end
            end
          end
        end
      end
    end
  end

  def render_glue_all_button
    to_be_glued_count = @user.user_stickers.to_be_glued.count
    return if to_be_glued_count == 0

    div(class: "mb-6") do
      Card(class: "border-amber-200 bg-amber-50") do
        CardContent(class: "flex items-center justify-between py-3") do
          p(class: "text-sm font-medium") { t(".to_be_glued_count", count: to_be_glued_count) }
          form(action: glue_all_user_user_stickers_path(@user), method: "post") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            Button(type: :submit, variant: :primary, size: :sm) { t(".glue_all") }
          end
        end
      end
    end
  end

  def render_album_grid
    stickers_by_country = Sticker.includes(:country).ordered.group_by(&:country)
    user_stickers_index = {}
    @user.user_stickers.each do |us|
      case us.state
      when "glued"
        user_stickers_index[us.sticker_id] ||= { id: us.id, copies: 0, state: "glued" }
      when "duplicate"
        user_stickers_index[us.sticker_id] ||= { id: nil, copies: 0, state: nil }
        user_stickers_index[us.sticker_id][:copies] += 1
      when "to_be_glued"
        user_stickers_index[us.sticker_id] ||= { id: nil, copies: 0, state: nil }
        user_stickers_index[us.sticker_id][:to_be_glued] = true
        user_stickers_index[us.sticker_id][:to_be_glued_id] = us.id
      when "incoming"
        user_stickers_index[us.sticker_id] ||= { id: nil, copies: 0, state: nil }
        user_stickers_index[us.sticker_id][:incoming] = true
        user_stickers_index[us.sticker_id][:trade_id] = us.trade_id
      end
    end

    div(class: "mb-6") do
      render UI::Fragments::AlbumGrid.new(
        user: @user,
        stickers_by_country: stickers_by_country,
        user_stickers_index: user_stickers_index
      )
    end
  end

  def render_duplicates
    duplicates = @user.duplicate_stickers

    div(class: "mt-8") do
      div(class: "flex items-center gap-2 mb-4") do
        Heading(level: 3) { t(".available_for_trade") }
        Badge(variant: :outline) { t(".duplicates", count: @user.duplicates_count) }
      end

      Card(class: "pt-6 bg-card") do
        CardContent do
          if duplicates.any?
            render UI::Fragments::StickerList.new(stickers: duplicates, copyable: true)
          else
            p(class: "text-muted-foreground italic") { t(".no_duplicates") }
          end
        end
      end
    end
  end

  def render_trade_history
    participations = @user.trade_history
    return if participations.empty?

    div(class: "mt-8") do
      Heading(level: 3, class: "mb-4") { t(".history_title") }

      participations.each do |participation|
        div(class: "mb-4") do
          render UI::Components::Collapsible.new(open: true) do |c|
            c.trigger(class: "flex items-center justify-between mb-2") do
              div(class: "flex items-center gap-2") do
                Button(variant: :ghost, icon: true) do
                  c.icon { "⬇️" }
                end

                Heading(level: 4) do
                  a(href: user_path(participation.other_user), class: "hover:underline") do
                    t(".history_with", name: participation.other_user.name)
                  end
                end
                Badge(variant: :outline) { t(".sticker_count", given: participation.given.count, received: participation.received.count) }
              end

              div(class: "flex items-center gap-2") do
                a(href: trade_path(participation.trade_id), class: "inline-flex") do
                  Button(variant: :outline, size: :sm, type: "button") { t(".view_trade") }
                end
                span(class: "text-xs text-muted-foreground") { I18n.l(participation.confirmed_at, format: :short) }
              end
            end

            c.content do
              Card(class: "pt-6 bg-card") do
                CardContent do
                  div(class: "grid grid-cols-2 gap-4 text-sm") do
                    div do
                      p(class: "font-medium text-muted-foreground mb-1") do
                        "#{t(".i_gave")} (#{participation.given.count})"
                      end
                      render UI::Fragments::StickerList.new(stickers: participation.given, copyable: true)
                    end
                    div do
                      p(class: "font-medium text-muted-foreground mb-1") do
                        "#{t(".i_received")} (#{participation.received.count})"
                      end
                      render UI::Fragments::StickerList.new(stickers: participation.received, copyable: true)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
