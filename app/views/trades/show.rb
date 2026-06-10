# frozen_string_literal: true

class Views::Trades::Show < Views::LoggedIn
  def initialize(trade:, current_user:)
    @trade = trade
    @current_user = current_user
    @other_user = trade.other_user(current_user)
  end

  def page_title
    t(".title", name: @other_user.name)
  end

  def render_title
    div do
      Heading(level: 2) { t(".title", name: @other_user.name) }
      render_status_badge
    end
  end

  def render_content
    render_trade_zones
    render_actions
  end

  private

  def render_status_badge
    div(class: "flex gap-2 mt-2") do
      if @trade.agreed?
        Badge(variant: :default) { t(".status.agreed") }
      elsif @trade.accepted_by?(@current_user)
        Badge(variant: :outline) { t(".status.waiting_for_other", name: @other_user.name) }
      elsif @trade.accepted_by?(@other_user)
        Badge(variant: :outline) { t(".status.other_accepted", name: @other_user.name) }
      else
        Badge(variant: :outline) { t(".status.negotiating") }
      end
    end
  end

  def render_trade_zones
    div(class: "space-y-4 mt-6") do
      # Current user gives
      render_zone(
        title: t(".you_give"),
        stickers: stickers_given_by(@current_user),
        zone: :current_user_gives,
        removable: !@trade.agreed?
      )

      # Current user's available pool
      unless @trade.agreed?
        render_pool(
          title: t(".your_available"),
          stickers: available_pool_for(@current_user),
          giver: @current_user
        )
      end

      # Other user gives
      render_zone(
        title: t(".they_give", name: @other_user.name),
        stickers: stickers_given_by(@other_user),
        zone: :other_user_gives,
        removable: !@trade.agreed?
      )

      # Other user's available pool
      unless @trade.agreed?
        render_pool(
          title: t(".their_available", name: @other_user.name),
          stickers: available_pool_for(@other_user),
          giver: @other_user
        )
      end
    end

    # Receipt confirmation section (only after agreement)
    render_receipt_section if @trade.agreed?
  end

  def render_zone(title:, stickers:, zone:, removable:)
    Card(class: "border-green-200 bg-green-50") do
      CardHeader(class: "pb-2") do
        CardTitle(class: "text-sm") { title }
        Badge(variant: :outline) { stickers.size.to_s }
      end
      CardContent do
        if stickers.any?
          div(class: "flex flex-wrap gap-1.5") do
            stickers.each do |ts|
              render_trade_sticker_chip(ts, removable: removable)
            end
          end
        else
          p(class: "text-muted-foreground italic text-sm") { t(".empty_zone") }
        end
      end
    end
  end

  def render_pool(title:, stickers:, giver:)
    Card(class: "border-dashed") do
      CardHeader(class: "pb-2") do
        CardTitle(class: "text-sm text-muted-foreground") { title }
        Badge(variant: :outline) { stickers.size.to_s }
      end
      CardContent do
        if stickers.any?
          div(class: "flex flex-wrap gap-1.5") do
            stickers.each do |sticker|
              render_pool_sticker_chip(sticker, giver: giver)
            end
          end
        else
          p(class: "text-muted-foreground italic text-sm") { t(".empty_pool") }
        end
      end
    end
  end

  def render_trade_sticker_chip(trade_sticker, removable:)
    sticker = trade_sticker.sticker
    color = sticker.country.color || "#6B7280"

    div(class: "inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-medium text-white", style: "background-color: #{color}") do
      span { "#{sticker.country.code} #{sticker.number}" }

      if removable
        form(action: trade_path(@trade), method: "post", class: "inline") do
          input(type: "hidden", name: "_method", value: "patch")
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          input(type: "hidden", name: "action_type", value: "remove")
          input(type: "hidden", name: "trade_sticker_id", value: trade_sticker.id)
          button(type: "submit", class: "ml-1 hover:text-red-200 cursor-pointer") { "×" }
        end
      end
    end
  end

  def render_pool_sticker_chip(sticker, giver:)
    color = sticker.country.color || "#6B7280"

    form(action: trade_path(@trade), method: "post", class: "inline") do
      input(type: "hidden", name: "_method", value: "patch")
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      input(type: "hidden", name: "action_type", value: "add")
      input(type: "hidden", name: "sticker_id", value: sticker.id)
      input(type: "hidden", name: "giver_id", value: giver.id)
      button(
        type: "submit",
        class: "inline-flex items-center px-2 py-1 rounded text-xs font-medium text-white opacity-60 hover:opacity-100 cursor-pointer transition-opacity",
        style: "background-color: #{color}"
      ) { "#{sticker.country.code} #{sticker.number} +" }
    end
  end

  def render_receipt_section
    my_receipts = @trade.trade_stickers.where(receiver: @current_user)
    return if my_receipts.empty?

    div(class: "mt-6") do
      Card do
        CardHeader do
          CardTitle { t(".receipt_title") }
        end
        CardContent do
          div(class: "flex flex-wrap gap-2") do
            my_receipts.each do |ts|
              confirmed = ts.user_sticker&.discarded?
              sticker = ts.sticker

              div(class: "inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-medium #{confirmed ? "bg-green-100 text-green-800 line-through" : "bg-yellow-100 text-yellow-800"}") do
                span { "#{sticker.country.code} #{sticker.number}" }

                unless confirmed
                  form(action: confirm_receipt_trade_path(@trade, trade_sticker_id: ts.id), method: "post", class: "inline") do
                    input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                    button(type: "submit", class: "ml-1 text-green-600 hover:text-green-800 cursor-pointer") { "✓" }
                  end
                end
              end
            end
          end

          # Confirm all button
          unconfirmed = my_receipts.reject { |ts| ts.user_sticker&.discarded? }
          if unconfirmed.any?
            div(class: "mt-4") do
              form(action: confirm_all_receipts_trade_path(@trade), method: "post") do
                input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                Button(type: :submit, variant: :outline, size: :sm) { t(".confirm_all") }
              end
            end
          end
        end
      end
    end
  end

  def render_actions
    div(class: "mt-6 flex gap-3") do
      unless @trade.agreed?
        # Accept button
        form(action: accept_trade_path(@trade), method: "post") do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          if @trade.accepted_by?(@current_user)
            Button(type: :submit, variant: :primary, disabled: true) { t(".accepted") }
          else
            Button(type: :submit, variant: :primary) { t(".accept") }
          end
        end
      end

      # Cancel button
      form(action: cancel_trade_path(@trade), method: "post") do
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        Button(type: :submit, variant: :destructive) { t(".cancel") }
      end
    end
  end

  # Helpers

  def stickers_given_by(user)
    @trade.trade_stickers.includes(sticker: :country).where(giver: user).order("stickers.position")
  end

  def available_pool_for(giver)
    receiver = @trade.other_user(giver)
    # Giver's available duplicates that receiver is missing
    giver_available = giver.user_stickers.available_for_trade.pluck(:sticker_id)
    receiver_missing = receiver.missing_stickers.pluck(:id)
    available_ids = giver_available & receiver_missing

    # Exclude stickers already in this trade
    already_in_trade = @trade.trade_stickers.where(giver: giver).pluck(:sticker_id)
    available_ids -= already_in_trade

    Sticker.includes(:country).where(id: available_ids).order(:position)
  end
end
