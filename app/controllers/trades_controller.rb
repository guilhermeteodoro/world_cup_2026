# frozen_string_literal: true

class TradesController < ApplicationController
  before_action :require_login
  before_action :set_trade, except: [ :create, :index ]
  before_action :authorize_participant!, except: [ :create, :index ]

  # POST /u/:user_slug/trades
  # Creates a new trade pre-loaded with balanced suggestion
  # Pass auto_agree=true for in-person trades (skips negotiation)
  def create
    other_user = User.find_by!(slug: params[:user_slug])

    result = TradeComparer.new(current_user, other_user).call
    balanced = result.balanced

    auto_agree = params[:auto_agree] == "true"

    trade = Trade.create!(
      user_a: current_user,
      user_b: other_user,
      user_a_accepted_at: auto_agree ? Time.current : nil,
      user_b_accepted_at: auto_agree ? Time.current : nil,
      confirmed_at: auto_agree ? Time.current : nil
    )

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

    trade.process_agreement! if auto_agree

    redirect_to trade_path(trade)
  end

  # GET /trades/:id
  def show
    render Views::Trades::Show.new(
      trade: @trade,
      current_user: current_user,
      receipt_frame_id: "receipt_trade_#{@trade.id}",
      zones_frame_id: "trade_#{@trade.id}_zones"
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

  # POST /trades/:id/agree
  # Params: auto=true for sticky acceptance
  def agree
    if params[:auto].present?
      @trade.auto_agree!(current_user)
    else
      @trade.accept!(current_user)
    end
    check_agreement!

    notice = params[:auto].present? ? t("trades.auto_agree.success") : t("trades.accept.success")
    redirect_to trade_path(@trade), notice: notice
  end

  # POST /trades/:id/withdraw
  def withdraw
    @trade.withdraw!(current_user)
    redirect_to trade_path(@trade), notice: t("trades.withdraw.success")
  end

  # POST /trades/:id/cancel
  def cancel
    if @trade.agreed?
      redirect_to trade_path(@trade), alert: t("trades.cancel.already_agreed")
      return
    end
    @trade.discard!
    redirect_to user_path(@trade.other_user(current_user)), notice: t("trades.cancel.success")
  end

  # GET /trades
  # User's trades dashboard
  def index
    @trades = Trade.involving(current_user).pending.order(updated_at: :desc)
    render Views::Trades::Index.new(trades: @trades, current_user: current_user)
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

  def check_agreement!
    @trade.reload
    if @trade.agreed? && @trade.confirmed_at.nil?
      @trade.update!(confirmed_at: Time.current)
      @trade.process_agreement!
    end
  end

  def add_sticker_to_trade
    sticker = Sticker.find(params[:sticker_id])
    giver = User.find(params[:giver_id])
    receiver = @trade.other_user(giver)
    user_sticker = giver.user_stickers.duplicates.find_by(sticker_id: sticker.id)

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
