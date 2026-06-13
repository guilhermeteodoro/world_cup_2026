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
        Heading(level: 2) do
          plain t(".title_with_id", id: @trade.id)
          a(href: user_path(@other_user), class: "underline hover:no-underline") { @other_user.name }
        end
        div(class: "mt-1") do
          render_status_badge_inline
        end
      end
    end
  end

  def render_content
    turbo_frame(id: @zones_frame_id) do
      if @trade.agreed?
        render_confirmation_phase
      else
        render_actions
        render_agreement_info
        render_trade_zones
      end
    end
  end

  def render_status_badge_inline
    date_str = " · #{I18n.l(trade_latest_date, format: :short)}"
    if receipt_ended?
      Badge(variant: :default) { t(".status.confirmed") + date_str }
    elsif @trade.agreed?
      Badge(variant: :default) { t(".status.agreed") + date_str }
    elsif @trade.accepted_by?(@current_user)
      Badge(variant: :outline) { t(".status.waiting_for_other", name: @other_user.name) + date_str }
    elsif @trade.accepted_by?(@other_user)
      Badge(variant: :outline) { t(".status.other_accepted", name: @other_user.name) + date_str }
    else
      Badge(variant: :outline) { t(".status.negotiating") + date_str }
    end
  end

  def render_trade_zones
    div(class: "grid grid-cols-1 md:grid-cols-2 gap-4 mt-6") do
      render_user_card(
        title: t(".you_give"),
        trade_stickers: stickers_given_by(@current_user),
        pool_stickers: available_pool_for(@current_user),
        giver: @current_user,
        removable: editable?
      )

      render_user_card(
        title: t(".they_give", name: @other_user.name),
        trade_stickers: stickers_given_by(@other_user),
        pool_stickers: available_pool_for(@other_user),
        giver: @other_user,
        removable: editable?
      )
    end
  end

  def render_user_card(title:, trade_stickers:, pool_stickers:, giver:, removable:)
    div do
      p(class: "text-sm font-semibold mb-2") { title }

      # In trade section
      card_classes = if @trade.agreed?
                       "rounded-md border border-gray-200 bg-gray-50 p-3 mb-3"
      else
                       "rounded-md border border-green-200 bg-green-50 p-3 mb-3"
      end
      div(class: card_classes) do
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
      unless @trade.agreed? || @trade.accepted_by?(@current_user)
        render UI::Components::Collapsible.new(open: true,
          persist_key: "trade_#{@trade.id}_pool_#{giver.id}",
          class: "rounded-md border border-dashed") do |c|
          c.trigger(class: "flex items-center justify-between p-3 cursor-pointer hover:bg-muted/50 transition-colors") do
            p(class: "text-xs font-semibold text-muted-foreground") { t(".available", count: pool_stickers.size) }
            c.icon(class: "text-xs text-muted-foreground") { "▾" }
          end
          c.content(class: "p-3 pt-0") do
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
    elsif confirmation_phase? && trade_sticker.receiver_id == @current_user.id
      confirmed = trade_sticker.confirmed_at.present?
      form(action: trade_receipt_path(@trade, trade_sticker), method: "post", class: "inline", data: { turbo_frame: @zones_frame_id }) do
        input(type: "hidden", name: "_method", value: "patch")
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        input(type: "hidden", name: "confirmed", value: confirmed ? "false" : "true")
        if confirmed
          button(
            type: "submit",
            class: "inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-medium text-white cursor-pointer hover:opacity-80 transition-opacity ring-2 ring-green-400",
            style: "background-color: #{color}"
          ) { "#{sticker.country.code} #{sticker.number} ✓" }
        else
          button(
            type: "submit",
            class: "inline-flex items-center gap-1 px-2 py-1 rounded border text-xs font-medium cursor-pointer hover:opacity-80 transition-opacity",
            style: "border-color: #{color}; color: #{color}"
          ) { "#{sticker.country.code} #{sticker.number}" }
        end
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

  def render_confirmation_phase
    if receipt_ended?
      render_receipt_ended
    else
      render_receipt_actions
      render_receipt_card
    end
    render_reclaim_section
    render_trade_zones
  end

  def render_receipt_actions
    my_receipts = receipts_for_current_user
    @receipt_confirmed_count = my_receipts.where.not(confirmed_at: nil).count
    @receipt_total_count = my_receipts.count

    # Help text
    div(class: "rounded-md border border-green-200 bg-green-50 px-3 py-2 text-sm text-green-800 dark:border-green-800 dark:bg-green-950 dark:text-green-200") do
      p { t(".receipt_help") }
    end
  end

  def render_receipt_ended
    confirmed_receipts = receipts_for_current_user.where.not(confirmed_at: nil).includes(sticker: :country).order("stickers.position")
    return if confirmed_receipts.empty?

    div(class: "mt-4 rounded-md border border-gray-200 bg-gray-50 p-3") do
      p(class: "text-xs font-semibold text-muted-foreground mb-2") { t(".receipt_ended") }
      render_grouped_trade_stickers(confirmed_receipts, removable: false)
    end
  end

  def render_reclaim_section
    # Show reclaim UI when the other user ended confirmation and left unconfirmed stickers I gave
    return unless other_user_receipt_ended?

    reclaimable = reclaimable_trade_stickers
    return if reclaimable.empty?

    div(class: "mt-4 rounded-md border border-amber-200 bg-amber-50 p-3") do
      p(class: "text-xs font-semibold text-amber-800 mb-1") { t(".reclaim.title") }
      p(class: "text-xs text-amber-700 mb-3") { t(".reclaim.help_text") }

      div(class: "flex flex-wrap gap-1 mb-3") do
        reclaimable.each do |ts|
          sticker = ts.sticker
          color = sticker.country.color || "#6B7280"

          form(action: reclaim_trade_receipts_path(@trade), method: "post", class: "inline") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            input(type: "hidden", name: "trade_sticker_id", value: ts.id)
            button(
              type: "submit",
              class: "inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-medium text-white cursor-pointer hover:opacity-80 transition-opacity",
              style: "background-color: #{color}"
            ) { "#{sticker.country.code} #{sticker.number} ↩" }
          end
        end
      end

      # Reclaim all button
      form(action: reclaim_trade_receipts_path(@trade), method: "post", class: "flex justify-end") do
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        Button(type: :submit, variant: :outline, size: :sm) { t(".reclaim.reclaim_all") }
      end
    end
  end

  def render_receipt_card
    my_receipts = receipts_for_current_user.includes(sticker: :country).order("stickers.position")
    return if my_receipts.empty?

    div(class: "mt-4 rounded-md border-2 border-green-300 bg-green-50 p-3") do
      p(class: "text-xs font-semibold text-green-800 mb-2") { t(".receipt_title") }
      render_grouped_trade_stickers(my_receipts, removable: false)

      # Action buttons bottom-right
      div(class: "flex justify-end gap-3 mt-4") do
        # Confirm all & end
        form(action: end_confirmation_trade_receipts_path(@trade), method: "post", class: "inline") do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          input(type: "hidden", name: "confirm_all", value: "true")
          confirm_msg = t(".end_confirm_all.message", count: @receipt_total_count)
          Button(type: :submit, data: { turbo_confirm: confirm_msg }) { t(".confirm_all_and_end") }
        end

        # End confirmation (with current state)
        form(action: end_confirmation_trade_receipts_path(@trade), method: "post", class: "inline") do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          unconfirmed_count = @receipt_total_count - @receipt_confirmed_count
          confirm_msg = if unconfirmed_count == 0
                          t(".end_confirm_all.message", count: @receipt_total_count)
          else
                          t(".end_confirm_partial.message", confirmed: @receipt_confirmed_count, total: @receipt_total_count, unconfirmed: unconfirmed_count)
          end
          Button(type: :submit, variant: :outline, data: { turbo_confirm: confirm_msg }) { t(".end_confirmation") }
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
        unless @trade.agreed?
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
  end

  def render_agreement_info
    variant = if @trade.accepted_by?(@other_user) && !@trade.accepted_by?(@current_user)
                :warning
    else
                :info
    end

    classes = if variant == :warning
                "border-amber-200 bg-amber-50 text-amber-800 dark:border-amber-800 dark:bg-amber-950 dark:text-amber-200"
    else
                "border-blue-200 bg-blue-50 text-blue-800 dark:border-blue-800 dark:bg-blue-950 dark:text-blue-200"
    end

    div(class: "mt-4 rounded-md border px-3 py-2 text-sm #{classes}") do
      p do
        if @trade.accepted_by?(@current_user) && @trade.accepted_by?(@other_user)
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
  end

  def render_agree_split_button
    div(class: "inline-flex items-stretch rounded-md shadow-sm", data: { controller: "split-button", split_button_key_value: "trade_agree_preference" }) do
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

  def editable?
    !@trade.agreed? && !@trade.accepted_by?(@current_user)
  end

  def stickers_given_by(user)
    @trade.trade_stickers.includes(sticker: :country).where(giver: user).order("stickers.position")
  end

  def available_pool_for(giver)
    receiver = @trade.other_user(giver)
    # Giver's duplicates that receiver is missing, excluding stickers already in trade
    giver_sticker_ids = giver.user_stickers.duplicates.select(:sticker_id)
    receiver_owned_ids = receiver.user_stickers.glued.select(:sticker_id)
    already_in_trade_ids = @trade.trade_stickers.where(giver: giver).select(:sticker_id)

    Sticker.includes(:country)
      .where(id: giver_sticker_ids)
      .where.not(id: receiver_owned_ids)
      .where.not(id: already_in_trade_ids)
      .order(:position)
  end

  def receipt_ended?
    @trade.receipt_ended_by?(@current_user)
  end

  def other_user_receipt_ended?
    if @trade.user_a_id == @current_user.id
      @trade.user_b_receipt_ended_at.present?
    else
      @trade.user_a_receipt_ended_at.present?
    end
  end

  def reclaimable_trade_stickers
    # Trade stickers where I'm the giver, receiver didn't confirm, and my duplicate is still soft-deleted
    @trade.trade_stickers
      .includes(sticker: :country)
      .where(giver: @current_user, confirmed_at: nil)
      .select { |ts| ts.user_sticker&.discarded? }
  end

  def receipts_for_current_user
    @trade.trade_stickers.where(receiver: @current_user)
  end

  def confirmation_phase?
    @trade.agreed? && !receipt_ended?
  end

  def trade_latest_date
    receipt_ended_at = if @trade.user_a_id == @current_user.id
                         @trade.user_a_receipt_ended_at
    else
                         @trade.user_b_receipt_ended_at
    end
    [ receipt_ended_at, @trade.confirmed_at, @trade.created_at ].compact.max
  end
end
