# frozen_string_literal: true

class Views::Users::Show < Views::Base
  def initialize(user:, is_owner:, trade_result:, current_user:)
    @user = user
    @is_owner = is_owner
    @trade_result = trade_result
    @current_user = current_user
  end

  def view_template
    render_user_info
    render_trade if @trade_result
    render_duplicates
  end

  private

  def render_user_info
    div(class: "mb-4") do
      h1(class: "text-2xl font-bold text-gray-900 mb-2") { "#{@user.name}'s Collection" }

      div(class: "flex gap-6 text-sm text-gray-600") do
        span { "#{@user.owned_count}/994 owned" }
        span { "#{@user.missing_count} missing" }
        span { "#{@user.duplicates_count} duplicates" }
      end

      if @is_owner
        a(href: edit_user_collection_path(@user), class: "inline-block mt-3 text-green-600 hover:text-green-700 font-medium") do
          "Update collection"
        end

        a(href: edit_user_path(@user), class: "inline-block mt-3 ml-4 text-gray-500 hover:text-gray-700 font-medium") do
          "Account settings"
        end
      elsif !@current_user
        div(class: "mt-4 p-4 bg-yellow-50 border border-yellow-200 rounded-lg") do
          p(class: "text-sm text-yellow-800") do
            plain "Want to see what you can trade? "
            a(href: new_registration_path, class: "font-medium underline") { "Register your collection" }
          end
        end
      end
    end
  end

  def render_duplicates
    duplicates = @user.duplicate_stickers
    text = format_stickers_as_text(duplicates)

    div(class: "py-4", data: { controller: "clipboard", clipboard_text_value: text }) do
      div(class: "flex items-center justify-between mb-3") do
        h2(class: "text-lg font-semibold text-gray-800") { "Available for trade" }
        copy_button
      end
      if duplicates.any?
        render_sticker_list_by_team(duplicates)
      else
        p(class: "text-gray-500 italic") { "No duplicates available." }
      end
    end
  end

  def render_trade
    text = build_trade_text

    div(class: "py-4", data: { controller: "clipboard", clipboard_text_value: text }) do
      div(class: "flex items-center justify-between mb-6") do
        h2(class: "text-xl font-bold text-gray-900") { "🔄 Trade with #{@user.name}" }
        copy_button
      end

      render_diff_section(
        "#{@current_user.name} → #{@user.name}",
        "Duplicates you have that #{@user.name} is missing",
        @trade_result.a_gives_b
      )
      render_diff_section(
        "#{@user.name} → #{@current_user.name}",
        "Duplicates #{@user.name} has that you are missing",
        @trade_result.b_gives_a
      )

      render_balanced_trade
      render_leftovers
    end
  end

  def render_diff_section(title, subtitle, stickers)
    div(class: "mb-6") do
      h3(class: "font-semibold text-gray-800") { "#{title} (#{stickers.size} stickers)" }
      p(class: "text-sm text-gray-500 mb-2") { subtitle }
      if stickers.any?
        render_sticker_list_by_team(stickers)
      else
        p(class: "text-gray-500 italic text-sm") { "(nothing)" }
      end
    end
  end

  def render_balanced_trade
    balanced = @trade_result.balanced
    return unless [ :shiny, :coke, :normal ].any? { balanced.send(it).a_gives.any? }

    div(class: "mt-8 p-6 bg-green-50 border border-green-200 rounded-lg") do
      h3(class: "text-lg font-bold text-green-800 mb-4") { "✅ Suggested Balanced Trade" }

      [ :shiny, :coke, :normal ].each do |cat|
        pair = balanced.send(cat)
        next if pair.a_gives.empty?

        count = pair.a_gives.size
        div(class: "mb-4") do
          h4(class: "font-semibold text-green-700 mb-2") { "#{cat.to_s.upcase} (#{count} for #{count})" }
          div(class: "grid grid-cols-2 gap-4") do
            div do
              p(class: "text-xs text-gray-500 mb-1") { "#{@current_user.name} gives:" }
              render_sticker_list_by_team(pair.a_gives)
            end
            div do
              p(class: "text-xs text-gray-500 mb-1") { "#{@user.name} gives:" }
              render_sticker_list_by_team(pair.b_gives)
            end
          end
        end
      end
    end
  end

  def render_leftovers
    leftovers = @trade_result.leftovers
    return if leftovers.a_has.empty? && leftovers.b_has.empty?

    div(class: "mt-6 p-6 bg-gray-50 border border-gray-200 rounded-lg") do
      h3(class: "text-lg font-semibold text-gray-700 mb-4") { "🤝 Leftovers" }

      if leftovers.a_has.any?
        div(class: "mb-3") do
          p(class: "text-sm font-medium text-gray-600 mb-1") { "#{@current_user.name} still has to offer (#{leftovers.a_has.size}):" }
          render_sticker_list_by_team(leftovers.a_has)
        end
      end

      if leftovers.b_has.any?
        div do
          p(class: "text-sm font-medium text-gray-600 mb-1") { "#{@user.name} still has to offer (#{leftovers.b_has.size}):" }
          render_sticker_list_by_team(leftovers.b_has)
        end
      end
    end
  end

  def render_sticker_list_by_team(stickers)
    grouped = stickers.group_by(&:country)
    div(class: "text-sm font-mono") do
      grouped.each do |country, country_stickers|
        p do
          span(class: "font-semibold") { "#{country.emoji} #{country.code}: " }
          plain country_stickers.map(&:number).join(", ")
        end
      end
    end
  end

  # --- Text builders for clipboard ---

  def format_stickers_as_text(stickers)
    stickers.group_by(&:country).map do |country, country_stickers|
      "#{country.emoji} #{country.code}: #{country_stickers.map(&:number).join(", ")}"
    end.join("\n")
  end

  def build_trade_text
    lines = []

    lines << "#{@current_user.name} → #{@user.name} (#{@trade_result.a_gives_b.size} stickers)"
    lines << indent(format_stickers_as_text(@trade_result.a_gives_b))
    lines << ""
    lines << "#{@user.name} → #{@current_user.name} (#{@trade_result.b_gives_a.size} stickers)"
    lines << indent(format_stickers_as_text(@trade_result.b_gives_a))

    balanced = @trade_result.balanced
    if [ :shiny, :coke, :normal ].any? { balanced.send(it).a_gives.any? }
      lines << ""
      lines << "✅ Suggested Balanced Trade"
      [ :shiny, :coke, :normal ].each do |cat|
        pair = balanced.send(cat)
        next if pair.a_gives.empty?
        count = pair.a_gives.size
        lines << "  #{cat.to_s.upcase} (#{count} for #{count})"
        lines << "    #{@current_user.name} gives:"
        lines << indent(format_stickers_as_text(pair.a_gives), 6)
        lines << "    #{@user.name} gives:"
        lines << indent(format_stickers_as_text(pair.b_gives), 6)
      end
    end

    leftovers = @trade_result.leftovers
    if leftovers.a_has.any? || leftovers.b_has.any?
      lines << ""
      lines << "🤝 Leftovers"
      if leftovers.a_has.any?
        lines << "  #{@current_user.name} still has to offer (#{leftovers.a_has.size}):"
        lines << indent(format_stickers_as_text(leftovers.a_has), 4)
      end
      if leftovers.b_has.any?
        lines << "  #{@user.name} still has to offer (#{leftovers.b_has.size}):"
        lines << indent(format_stickers_as_text(leftovers.b_has), 4)
      end
    end

    lines.join("\n")
  end

  def indent(text, spaces = 2)
    text.lines.map { |l| "#{" " * spaces}#{l}" }.join
  end

  def copy_button
    button(
      type: "button",
      data: { action: "clipboard#copy", copy_button: "" },
      class: "text-sm text-gray-500 hover:text-gray-700 border border-gray-300 rounded px-2 py-1"
    ) { "📋 Copy" }
  end
end
