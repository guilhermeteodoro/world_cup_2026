# frozen_string_literal: true

class Views::Trades::Show < Views::LoggedIn
  def initialize(trade:, current_user:, receipt_frame_id:, zones_frame_id:)
    @trade = trade
    @current_user = current_user
    @other_user = trade.other_user(current_user)
    @receipt_frame_id = receipt_frame_id
    @zones_frame_id = zones_frame_id
  end

  def page_title
    t(".title", name: @other_user.name)
  end

  def render_title
    div(class: "flex items-center justify-between gap-4") do
      div do
        Heading(level: 2) { t(".title", name: @other_user.name) }
        render_status_badge
      end
    end
  end

  def render_content
    turbo_frame(id: @zones_frame_id) do
      render_actions
      render_agreement_info unless @trade.agreed?
      render_trade_zones
    end
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
    div(class: "grid grid-cols-1 md:grid-cols-2 gap-4 mt-6") do
      render_user_card(
        title: t(".you_give"),
        trade_stickers: stickers_given_by(@current_user),
        pool_stickers: available_pool_for(@current_user),
        giver: @current_user,
        removable: !@trade.agreed?
      )

      render_user_card(
        title: t(".they_give", name: @other_user.name),
        trade_stickers: stickers_given_by(@other_user),
        pool_stickers: available_pool_for(@other_user),
        giver: @other_user,
        removable: !@trade.agreed?
      )
    end

    render_receipt_section if @trade.agreed?
  end

  def render_user_card(title:, trade_stickers:, pool_stickers:, giver:, removable:)
    div do
      p(class: "text-sm font-semibold mb-2") { title }

      # In trade section (green-tinted)
      div(class: "rounded-md border border-green-200 bg-green-50 p-3 mb-3") do
        p(class: "text-xs font-semibold text-muted-foreground mb-2") do
          plain t(".in_trade", count: trade_stickers.size)
        end
        if trade_stickers.any?
          render_grouped_trade_stickers(trade_stickers, removable: removable)
        else
          p(class: "text-muted-foreground italic text-sm") { t(".empty_zone") }
        end
      end

      # Available pool section (dashed border, only during negotiation)
      unless @trade.agreed?
        render UI::Components::Collapsible.new(open: true,
          persist_key: "trade_#{@trade.id}_pool_#{giver.id}",
          class: "rounded-md border border-dashed") do
          div(class: "flex items-center justify-between p-3 cursor-pointer hover:bg-muted/50 transition-colors",
            data: { action: "click->collapsible#toggle" }) do
            p(class: "text-xs font-semibold text-muted-foreground") { t(".available", count: pool_stickers.size) }
            span(class: "text-xs text-muted-foreground transition-transform", style: "display:inline-block",
              data: { collapsible_target: "icon" }) { "▾" }
          end
          div(data: { collapsible_target: "content" }, class: "p-3 pt-0") do
            if pool_stickers.any?
              render_grouped_pool_stickers(pool_stickers, giver: giver)
            else
              p(class: "text-muted-foreground italic text-sm") { t(".empty_pool") }
            end
          end
        end
      end
    end
  end

  def render_grouped_trade_stickers(stickers, removable:)
    grouped = stickers.group_by { |ts| ts.sticker.category }
    %w[shiny coke normal].each do |cat|
      group = grouped[cat]
      next unless group&.any?

      div(class: "mb-3 last:mb-0") do
        p(class: "text-xs font-semibold text-muted-foreground mb-1") { t("categories.#{cat}") }
        by_country = group.group_by { |ts| ts.sticker.country }
        by_country.each do |country, country_stickers|
          div(class: "mb-1.5 last:mb-0") do
            span(class: "text-[10px] font-medium text-muted-foreground mr-1") { "#{country.emoji} #{country.code}" }
            div(class: "inline-flex flex-wrap gap-1.5") do
              country_stickers.each do |ts|
                render_trade_sticker_chip(ts, removable: removable)
              end
            end
          end
        end
      end
    end
  end

  def render_grouped_pool_stickers(stickers, giver:)
    grouped = stickers.group_by(&:category)
    %w[shiny coke normal].each do |cat|
      group = grouped[cat]
      next unless group&.any?

      div(class: "mb-3 last:mb-0") do
        p(class: "text-xs font-semibold text-muted-foreground mb-1") { t("categories.#{cat}") }
        by_country = group.group_by(&:country)
        by_country.each do |country, country_stickers|
          div(class: "mb-1.5 last:mb-0") do
            span(class: "text-[10px] font-medium text-muted-foreground mr-1") { "#{country.emoji} #{country.code}" }
            div(class: "inline-flex flex-wrap gap-1.5") do
              country_stickers.each do |sticker|
                render_pool_sticker_chip(sticker, giver: giver)
              end
            end
          end
        end
      end
    end
  end

  def render_trade_sticker_chip(trade_sticker, removable:)
    sticker = trade_sticker.sticker
    color = sticker.country.color || "#6B7280"

    if removable
      form(action: trade_path(@trade), method: "post", class: "inline", data: { turbo_frame: @zones_frame_id }) do
        input(type: "hidden", name: "_method", value: "patch")
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        input(type: "hidden", name: "action_type", value: "remove")
        input(type: "hidden", name: "trade_sticker_id", value: trade_sticker.id)
        button(
          type: "submit",
          class: "inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-medium text-white cursor-pointer hover:opacity-80 transition-opacity",
          style: "background-color: #{color}"
        ) { "#{sticker.country.code} #{sticker.number} ×" }
      end
    else
      div(class: "inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-medium text-white", style: "background-color: #{color}") do
        span { "#{sticker.country.code} #{sticker.number}" }
      end
    end
  end

  def render_pool_sticker_chip(sticker, giver:)
    color = sticker.country.color || "#6B7280"

    form(action: trade_path(@trade), method: "post", class: "inline", data: { turbo_frame: @zones_frame_id }) do
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

    turbo_frame(id: @receipt_frame_id) do
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
  end

  def render_actions
    div(class: "flex flex-col gap-3 md:flex-row md:items-center md:justify-between") do
      # Help text on the left
      unless @trade.agreed?
        p(class: "text-sm text-muted-foreground") { t(".help_text") }
      end

      div(class: "flex gap-3") do
        unless @trade.agreed?
          if @trade.accepted_by?(@current_user) || @trade.auto_agreed_by?(@current_user)
            form(action: withdraw_trade_path(@trade), method: "post", class: "inline") do
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
              Button(type: :submit, variant: :outline) do
                @trade.auto_agreed_by?(@current_user) ? t(".auto_agreed") : t(".accepted")
              end
            end
          else
            render_agree_split_button
          end
        end

        # Reject button with confirmation dialog
        Dialog do
          DialogTrigger do
            Button(variant: :destructive) { t(".reject") }
          end
          DialogContent do
            DialogHeader do
              DialogTitle { t(".reject_confirm.title") }
              DialogDescription { t(".reject_confirm.description", name: @other_user.name) }
            end
            DialogFooter do
              form(action: cancel_trade_path(@trade), method: "post") do
                input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
                Button(type: :submit, variant: :destructive) { t(".reject_confirm.confirm") }
              end
            end
          end
        end
      end
    end
  end

  def render_agreement_info
    div(class: "mt-4 rounded-md bg-muted/50 p-3 text-sm text-muted-foreground") do
      if @trade.accepted_by?(@current_user) && @trade.accepted_by?(@other_user)
        # Should not happen (would be agreed), but defensive
        plain t(".agreement_info.both_accepted")
      elsif @trade.accepted_by?(@current_user)
        plain t(".agreement_info.you_accepted", name: @other_user.name)
      elsif @trade.accepted_by?(@other_user)
        plain t(".agreement_info.they_accepted", name: @other_user.name)
      else
        plain t(".agreement_info.explanation")
      end
    end
  end

  def render_agree_split_button
    div(class: "inline-flex items-stretch rounded-md shadow-sm", data: { controller: "split-button" }) do
      form(
        action: agree_trade_path(@trade),
        method: "post",
        data: { split_button_target: "form" }
      ) do
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        button(
          type: "submit",
          class: "whitespace-nowrap h-full px-4 py-2 text-sm font-medium text-white bg-primary rounded-l-md hover:bg-primary/90 cursor-pointer",
          data: { split_button_target: "label" }
        ) { t(".accept") }
      end

      DropdownMenu(options: { placement: "bottom-end" }) do
        DropdownMenuTrigger do
          button(
            type: "button",
            class: "h-full px-2 py-2 text-sm font-medium text-white bg-primary border-l border-primary-foreground/20 rounded-r-md hover:bg-primary/90 cursor-pointer"
          ) { "▾" }
        end

        DropdownMenuContent do
          button(
            type: "button",
            class: "relative flex w-full whitespace-nowrap cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors hover:bg-accent hover:text-accent-foreground",
            data: { action: "split-button#select", split_button_target: "option", action_value: agree_trade_path(@trade), label_value: t(".accept") }
          ) { t(".accept") }
          button(
            type: "button",
            class: "relative flex w-full whitespace-nowrap cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors hover:bg-accent hover:text-accent-foreground",
            data: { action: "split-button#select", split_button_target: "option", action_value: agree_trade_path(@trade, auto: true), label_value: t(".auto_agree") }
          ) { t(".auto_agree") }
        end
      end
    end
  end

  # Helpers

  def stickers_given_by(user)
    @trade.trade_stickers.includes(sticker: :country).where(giver: user).order("stickers.position")
  end

  def available_pool_for(giver)
    receiver = @trade.other_user(giver)
    # Giver's duplicates that receiver is missing, excluding stickers already in trade
    giver_sticker_ids = giver.user_stickers.available_for_trade.select(:sticker_id)
    receiver_owned_ids = receiver.user_stickers.glued.select(:sticker_id)
    already_in_trade_ids = @trade.trade_stickers.where(giver: giver).select(:sticker_id)

    Sticker.includes(:country)
      .where(id: giver_sticker_ids)
      .where.not(id: receiver_owned_ids)
      .where.not(id: already_in_trade_ids)
      .order(:position)
  end
end
