# frozen_string_literal: true

class ReceiptsController < ApplicationController
  before_action :require_login
  before_action :set_trade
  before_action :authorize_participant!
  before_action :require_agreed!

  # PATCH /trades/:trade_id/receipts/:id
  # Toggle confirmed_at on a trade_sticker
  def update
    trade_sticker = @trade.trade_stickers.find(params[:id])

    unless trade_sticker.receiver_id == current_user.id
      redirect_to trade_path(@trade), alert: t("receipts.unauthorized")
      return
    end

    if params[:confirmed] == "true"
      trade_sticker.update!(confirmed_at: Time.current)
    else
      trade_sticker.update!(confirmed_at: nil)
    end

    redirect_to trade_path(@trade)
  end

  # POST /trades/:trade_id/receipts/end
  # End confirmation phase for current user
  def end_confirmation
    if already_ended?
      redirect_to trade_path(@trade), alert: t("receipts.already_ended")
      return
    end

    Trade.transaction do
      if params[:confirm_all] == "true"
        my_receipts.where(confirmed_at: nil).update_all(confirmed_at: Time.current)
      end

      # Apply state transitions for confirmed stickers
      my_receipts.where.not(confirmed_at: nil).each do |ts|
        ts.confirm_receipt!
      end

      # Mark this user's receipt phase as ended
      if @trade.user_a_id == current_user.id
        @trade.update!(user_a_receipt_ended_at: Time.current)
      else
        @trade.update!(user_b_receipt_ended_at: Time.current)
      end
    end

    redirect_to trade_path(@trade), notice: t("receipts.ended")
  end

  private

  def require_login
    redirect_to new_session_path unless current_user
  end

  def set_trade
    @trade = Trade.find(params[:trade_id])
  end

  def authorize_participant!
    unless @trade.participant?(current_user)
      redirect_to trades_path, alert: t("trades.unauthorized")
    end
  end

  def require_agreed!
    unless @trade.agreed?
      redirect_to trade_path(@trade)
    end
  end

  def my_receipts
    @trade.trade_stickers.where(receiver: current_user)
  end

  def already_ended?
    if @trade.user_a_id == current_user.id
      @trade.user_a_receipt_ended_at.present?
    else
      @trade.user_b_receipt_ended_at.present?
    end
  end
end
