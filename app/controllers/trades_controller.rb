# frozen_string_literal: true

class TradesController < ApplicationController
  before_action :require_login

  def create
    other_user = User.find_by!(slug: params[:user_slug])

    result = TradeComparer.new(current_user, other_user).call
    balanced = result.balanced

    trade = Trade.create!(
      user_a: current_user,
      user_b: other_user,
      confirmed_at: Time.current
    )

    # Insert trade_stickers for each direction
    [ :shiny, :coke, :normal ].each do |cat|
      pair = balanced.send(cat)

      pair.a_gives.each do |sticker|
        trade.trade_stickers.create!(sticker: sticker, giver: current_user, receiver: other_user)
      end

      pair.b_gives.each do |sticker|
        trade.trade_stickers.create!(sticker: sticker, giver: other_user, receiver: current_user)
      end
    end

    redirect_to user_path(other_user), notice: t("trades.create.success")
  end

  def export
    @trade = Trade.find(params[:id])
    authorize_trade_participant!

    result = TradeExporter.new(user: current_user, trade: @trade).call

    render Views::Trades::Export.new(
      trade: @trade,
      dump: result[:dump],
      missing: result[:missing],
      duplicates: result[:duplicates],
      current_user: current_user
    ), layout: false
  end

  private

  def require_login
    redirect_to new_session_path unless current_user
  end

  def authorize_trade_participant!
    unless @trade.user_a_id == current_user.id || @trade.user_b_id == current_user.id
      redirect_to root_path, alert: t("trades.export.unauthorized")
    end
  end
end
