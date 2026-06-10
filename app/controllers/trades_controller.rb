# frozen_string_literal: true

class TradesController < ApplicationController
  before_action :require_login
  before_action :set_trade, only: [ :show, :update, :accept, :cancel, :confirm_receipt, :confirm_all_receipts ]
  before_action :authorize_participant!, only: [ :show, :update, :accept, :cancel, :confirm_receipt, :confirm_all_receipts ]

  # POST /u/:user_slug/trades
  # Creates a new trade pre-loaded with balanced suggestion
  def create
    other_user = User.find_by!(slug: params[:user_slug])

    result = TradeComparer.new(current_user, other_user).call
    balanced = result.balanced

    trade = Trade.create!(user_a: current_user, user_b: other_user)

    # Pre-load with balanced suggestion
    [ :shiny, :coke, :normal ].each do |cat|
      pair = balanced.send(cat)

      pair.a_gives.each do |sticker|
        user_sticker = current_user.user_stickers.duplicates.find_by(sticker_id: sticker.id)
        trade.trade_stickers.create!(
          sticker: sticker,
          giver: current_user,
          receiver: other_user,
          user_sticker: user_sticker
        )
      end

      pair.b_gives.each do |sticker|
        user_sticker = other_user.user_stickers.duplicates.find_by(sticker_id: sticker.id)
        trade.trade_stickers.create!(
          sticker: sticker,
          giver: other_user,
          receiver: current_user,
          user_sticker: user_sticker
        )
      end
    end

    redirect_to trade_path(trade)
  end

  # GET /trades/:id
  def show
    render Views::Trades::Show.new(
      trade: @trade,
      current_user: current_user
    )
  end

  # PATCH /trades/:id
  # Modify stickers in the trade (add/remove)
  def update
    case params[:action_type]
    when "add"
      add_sticker_to_trade
    when "remove"
      remove_sticker_from_trade
    end

    # Reset the other user's acceptance when modifying
    @trade.reset_other_acceptance!(current_user)

    redirect_to trade_path(@trade)
  end

  # POST /trades/:id/accept
  def accept
    @trade.accept!(current_user)

    if @trade.reload.agreed?
      @trade.update!(confirmed_at: Time.current)
    end

    redirect_to trade_path(@trade), notice: t("trades.accept.success")
  end

  # POST /trades/:id/cancel
  def cancel
    @trade.discard!
    redirect_to user_path(@trade.other_user(current_user)), notice: t("trades.cancel.success")
  end

  # POST /trades/:id/trade_stickers/:trade_sticker_id/confirm_receipt
  def confirm_receipt
    trade_sticker = @trade.trade_stickers.find(params[:trade_sticker_id])

    unless trade_sticker.receiver_id == current_user.id
      redirect_to trade_path(@trade), alert: t("trades.confirm_receipt.unauthorized")
      return
    end

    trade_sticker.confirm_receipt!
    redirect_to trade_path(@trade), notice: t("trades.confirm_receipt.success")
  end

  # POST /trades/:id/confirm_all_receipts
  def confirm_all_receipts
    @trade.trade_stickers.where(receiver: current_user).each do |ts|
      ts.confirm_receipt! unless ts.user_sticker&.discarded?
    end

    redirect_to trade_path(@trade), notice: t("trades.confirm_all_receipts.success")
  end

  # GET /trades
  # User's trades dashboard
  def index
    @trades = Trade.involving(current_user).pending.order(updated_at: :desc)
    render Views::Trades::Index.new(trades: @trades, current_user: current_user)
  end

  def export
    @trade = Trade.find(params[:id])
    authorize_participant!

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

  def set_trade
    @trade = Trade.find(params[:id])
  end

  def authorize_participant!
    unless @trade.participant?(current_user)
      redirect_to root_path, alert: t("trades.unauthorized")
    end
  end

  def add_sticker_to_trade
    sticker = Sticker.find(params[:sticker_id])
    giver = User.find(params[:giver_id])
    receiver = @trade.other_user(giver)
    user_sticker = giver.user_stickers.available_for_trade.find_by(sticker_id: sticker.id)

    return unless user_sticker

    @trade.trade_stickers.create!(
      sticker: sticker,
      giver: giver,
      receiver: receiver,
      user_sticker: user_sticker
    )
  end

  def remove_sticker_from_trade
    trade_sticker = @trade.trade_stickers.find(params[:trade_sticker_id])
    trade_sticker.destroy!
  end
end
