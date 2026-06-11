# frozen_string_literal: true

class Views::Users::ShowVisitor < Views::LoggedIn
  def initialize(user:, trade_result:, trade_clipboard_text:, current_user:)
    @user = user
    @trade_result = trade_result
    @trade_clipboard_text = trade_clipboard_text
    @current_user = current_user
  end

  def page_title
    t(".title", name: @user.name)
  end

  def render_title
    div do
      div(class: "flex items-center gap-2 mb-2") do
        Heading(level: 2) { t(".title", name: @user.name) }
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
  end

  private

  def render_user_info
    return if @current_user

    div(class: "mb-6") do
      Alert(class: "mt-4") do
        AlertDescription do
          plain "#{t(".register_prompt")} "
          a(href: new_registration_path, class: "font-medium underline") { t(".register_link") }
        end
      end
    end
  end

  def render_duplicates
    duplicates = @user.duplicate_stickers

    div do
      render UI::Components::Collapsible.new(open: true) do |c|
        c.trigger(class: "flex items-center justify-between mb-2") do
          div(class: "flex items-center gap-2") do
            Button(variant: :ghost, icon: true) do
              c.icon { "⬇️" }
            end

            Heading(level: 3) { t(".available_for_trade") }
            Badge(variant: :outline) { t(".duplicates", count: @user.duplicates_count) }
          end
        end

        c.content do
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
                render UI::Fragments::StickerList.new(stickers: pair.a_gives, copyable: true)
              end
              div do
                p(class: "text-xs text-muted-foreground mb-1") { t(".gives", name: @user.name) }
                render UI::Fragments::StickerList.new(stickers: pair.b_gives, copyable: true)
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

    div(class: "mt-4 flex flex-wrap gap-3") do
      # Link to existing pending trade if any
      existing_trade = Trade.between(@current_user, @user).pending.first if @current_user
      if existing_trade
        a(href: trade_path(existing_trade), class: "inline-flex") do
          Button(variant: :outline) { t(".view_existing_trade") }
        end
      end

      # New trade button
      form(action: user_trades_path(@user), method: "post") do
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        Button(type: :submit, variant: :primary) { t(".new_trade") }
      end

      # Auto-agree button (for in-person trading)
      form(action: user_trades_path(@user), method: "post") do
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        input(type: "hidden", name: "auto_agree", value: "true")
        Button(type: :submit, variant: :outline) { t(".auto_agree") }
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
            render UI::Fragments::StickerList.new(stickers: leftovers.a_has, copyable: true)
          end
        end

        if leftovers.b_has.any?
          div do
            p(class: "text-sm font-medium text-muted-foreground mb-1") { t(".still_has", name: @user.name, count: leftovers.b_has.size) }
            render UI::Fragments::StickerList.new(stickers: leftovers.b_has, copyable: true)
          end
        end
      end
    end
  end

  def copy_button
    Button(variant: :outline, size: :sm, icon: true, type: "button", data: { action: "clipboard#copy", copy_button: "" }) { "📋" }
  end
end
