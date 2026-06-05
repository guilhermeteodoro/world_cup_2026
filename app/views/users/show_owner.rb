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
      ) { t(".tab_trades") }
    end
  end

  def render_album_panel
    div(data: { tabs_target: "panel", tab: "album" }) do
      render_album_grid
    end
  end

  def render_trades_panel
    div(class: "hidden", data: { tabs_target: "panel", tab: "trades" }) do
      render_trade_history
      render_duplicates
    end
  end

  def render_album_grid
    stickers_by_country = Sticker.includes(:country).ordered.group_by(&:country)
    user_stickers_index = @user.user_stickers.each_with_object({}) do |us, hash|
      hash[us.sticker_id] = { id: us.id, copies: us.copies }
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

    div do
      Collapsible(open: true) do
        div(class: "flex items-center justify-between mb-2") do
          div(class: "flex items-center gap-2") do
            CollapsibleTrigger do
              Button(variant: :ghost, icon: true) do
                span(class: "transition-transform duration-200", data: { ruby_ui__collapsible_target: "icon" }) { "⬇️" }
              end
            end

            Heading(level: 3) { t(".available_for_trade") }
            Badge(variant: :outline) { t(".duplicates", count: @user.duplicates_count) }
          end
        end

        CollapsibleContent do
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
    end
  end

  def render_trade_history
    participations = @user.trade_history
    return if participations.empty?

    div(class: "mt-8") do
      Heading(level: 3, class: "mb-4") { t(".history_title") }

      participations.each do |participation|
        div(class: "mb-4") do
          Collapsible(open: true) do
            div(class: "flex items-center justify-between mb-2") do
              div(class: "flex items-center gap-2") do
                CollapsibleTrigger do
                  Button(variant: :ghost, icon: true) do
                    span(class: "transition-transform duration-200", data: { ruby_ui__collapsible_target: "icon" }) { "⬇️" }
                  end
                end

                Heading(level: 4) do
                  a(href: user_path(participation.other_user), class: "hover:underline") do
                    t(".history_with", name: participation.other_user.name)
                  end
                end
                Badge(variant: :outline) { t(".sticker_count", given: participation.given.count, received: participation.received.count) }
              end

              div(class: "flex items-center gap-2") do
                render_export_dialog(participation)
                span(class: "text-xs text-muted-foreground") { I18n.l(participation.confirmed_at, format: :short) }
              end
            end

            CollapsibleContent do
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

  def render_export_dialog(participation)
    Dialog do
      DialogTrigger do
        Button(variant: :outline, size: :sm, type: "button") { t(".export") }
      end

      DialogContent(class: "bg-white sm:max-w-lg") do
        DialogHeader do
          DialogTitle { t(".export_title", name: participation.other_user.name) }
          DialogDescription { t(".export_description") }
        end

        DialogMiddle do
          turbo_frame(id: "export_trade_#{participation.trade_id}", src: export_trade_path(participation.trade_id), loading: :lazy) do
            p(class: "text-sm text-muted-foreground py-4") { t(".loading") }
          end
        end
      end
    end
  end
end
