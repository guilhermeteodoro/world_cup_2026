# frozen_string_literal: true

class Views::Users::Show < Views::LoggedIn
  def initialize(user:, is_owner:, trade_result:, trade_clipboard_text:, current_user:)
    @user = user
    @is_owner = is_owner
    @trade_result = trade_result
    @trade_clipboard_text = trade_clipboard_text
    @current_user = current_user
  end

  def render_title
    div do
      div(class: "flex items-center gap-2 mb-2") do
        Heading(level: 2) { @is_owner ? t(".own_collection_title") : t(".collection_title", name: @user.name) }

        if @is_owner
          Link(href: edit_user_collection_path(@user), variant: :ghost, icon: true, class: "text-muted-foreground") { "✏️" }
        end
      end

      div(class: "flex flex-wrap gap-3 text-sm") do
        Badge(variant: :outline) { t(".owned", count: @user.owned_count) }
        Badge(variant: :outline) { t(".missing", count: @user.missing_count) }
      end
    end
  end

  def render_content
    render_user_info
    render_trade if @trade_result
    render_duplicates
    render_trade_history if @is_owner
  end

  private

  def render_user_info
    div(class: "mb-6") do
      if !@is_owner && !@current_user
        Alert(class: "mt-4") do
          AlertDescription do
            plain "#{t(".register_prompt")} "
            a(href: new_registration_path, class: "font-medium underline") { t(".register_link") }
          end
        end
      end
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
                render Components::StickerList.new(stickers: duplicates, copyable: true)
              else
                p(class: "text-muted-foreground italic") { t(".no_duplicates") }
              end
            end
          end
        end
      end
    end
  end

  def render_trade
    div(class: "py-4", data: { controller: "clipboard", clipboard_text_value: @trade_clipboard_text }) do
      div(class: "flex items-center justify-between mb-6") do
        h2(class: "text-xl font-bold text-gray-900") { t(".trade_title", name: @user.name) }
        copy_button
      end

      render_balanced_trade
      render_consolidate_button
      render_leftovers
    end
  end

  def render_diff_section(title, subtitle, stickers)
    div(class: "mb-6") do
      Heading(level: 3) { title }

      p(class: "text-sm text-gray-500 mb-2") { subtitle }

      if stickers.any?
        render Components::StickerList.new(stickers: stickers)
      else
        p(class: "text-gray-500 italic text-sm") { t(".nothing") }
      end
    end
  end

  def render_balanced_trade
    balanced = @trade_result.balanced
    return unless [ :shiny, :coke, :normal ].any? { balanced.send(it).a_gives.any? }

    Card(class: "mt-8 border-green-200 bg-green-50") do
      CardHeader do
        CardTitle { t(".balanced_title") }
      end

      CardContent do
        [ :shiny, :coke, :normal ].each do |cat|
          pair = balanced.send(cat)
          next if pair.a_gives.empty?

          count = pair.a_gives.size
          div(class: "mb-4") do
            h4(class: "font-semibold text-green-700 mb-2") { t(".category_trade", category: t("categories.#{cat}"), count: count) }
            div(class: "grid grid-cols-2 gap-4") do
              div do
                p(class: "text-xs text-muted-foreground mb-1") { t(".gives", name: @current_user.name) }
                render Components::StickerList.new(stickers: pair.a_gives)
              end
              div do
                p(class: "text-xs text-muted-foreground mb-1") { t(".gives", name: @user.name) }
                render Components::StickerList.new(stickers: pair.b_gives)
              end
            end
          end
        end
      end
    end
  end

  def render_consolidate_button
    balanced = @trade_result.balanced
    has_any = [ :shiny, :coke, :normal ].any? { balanced.send(it).a_gives.any? }
    return unless has_any

    div(class: "mt-4 flex justify-end") do
      form(action: user_trades_path(@user), method: "post") do
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        Button(type: :submit, variant: :primary) { t(".consolidate") }
      end
    end
  end

  def render_leftovers
    leftovers = @trade_result.leftovers
    return if leftovers.a_has.empty? && leftovers.b_has.empty?

    Card(class: "mt-6") do
      CardHeader do
        CardTitle { t(".leftovers_title") }
      end

      CardContent do
        if leftovers.a_has.any?
          div(class: "mb-3") do
            p(class: "text-sm font-medium text-muted-foreground mb-1") { t(".still_has", name: @current_user.name, count: leftovers.a_has.size) }
            render Components::StickerList.new(stickers: leftovers.a_has)
          end
        end

        if leftovers.b_has.any?
          div do
            p(class: "text-sm font-medium text-muted-foreground mb-1") { t(".still_has", name: @user.name, count: leftovers.b_has.size) }
            render Components::StickerList.new(stickers: leftovers.b_has)
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

                Heading(level: 4) { t(".history_with", name: participation.other_user.name) }
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
                      render Components::StickerList.new(stickers: participation.given)
                    end
                    div do
                      p(class: "font-medium text-muted-foreground mb-1") do
                        "#{t(".i_received")} (#{participation.received.count})"
                      end
                      render Components::StickerList.new(stickers: participation.received)
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

  def copy_button
    Button(variant: :outline, size: :sm, icon: true, type: "button", data: { action: "clipboard#copy", copy_button: "" }) { "📋" }
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

  def dom_id_for_trade(trade_id, prefix)
    "#{prefix}_trade_#{trade_id}"
  end
end
