# frozen_string_literal: true

class Views::Trades::Index < Views::LoggedIn
  def initialize(trades:, current_user:)
    @trades = trades
    @current_user = current_user
  end

  def page_title
    t(".title")
  end

  def render_title
    div do
      div(class: "flex items-center gap-2") do
        Heading(level: 2) { t(".title") }
        Badge(variant: :outline) { @trades.size.to_s } if @trades.any?
      end
    end
  end

  def render_content
    if @trades.any?
      div(class: "space-y-3") do
        @trades.each do |trade|
          render_trade_card(trade)
        end
      end
    else
      div(class: "text-center py-12") do
        p(class: "text-muted-foreground") { t(".empty") }
      end
    end
  end

  private

  def render_trade_card(trade)
    other = trade.other_user(@current_user)
    stickers_count = trade.trade_stickers.count

    a(href: trade_path(trade), class: "block") do
      Card(class: "hover:border-primary transition-colors") do
        CardContent(class: "flex items-center justify-between py-4") do
          div do
            p(class: "font-medium") { other.name }
            p(class: "text-sm text-muted-foreground") do
              plain t(".stickers_count", count: stickers_count)
            end
          end
          div(class: "flex items-center gap-2") do
            if trade.agreed?
              Badge(variant: :default) { t(".agreed") }
            elsif trade.accepted_by?(@current_user)
              Badge(variant: :outline) { t(".waiting") }
            elsif trade.accepted_by?(other)
              Badge(variant: :outline) { t(".their_turn") }
            else
              Badge(variant: :outline) { t(".negotiating") }
            end
          end
        end
      end
    end
  end
end
