# frozen_string_literal: true

class AnonymousTradesController < ApplicationController
  before_action :require_login

  # GET /anonymous_trades/new
  def new
    render Views::AnonymousTrades::New.new(current_user: current_user)
  end

  # POST /anonymous_trades
  def create
    given_sticker_ids = Array(params[:given_sticker_ids]).map(&:to_i)
    received_sticker_ids = Array(params[:received_sticker_ids]).map(&:to_i)

    trade = Trade.create!(
      user_a: current_user,
      user_b: current_user, # self-referencing for anonymous
      user_a_accepted_at: Time.current,
      user_b_accepted_at: Time.current,
      confirmed_at: Time.current
    )

    # Process given stickers (soft-delete duplicates)
    given_sticker_ids.each do |sticker_id|
      user_sticker = current_user.user_stickers.duplicates.find_by(sticker_id: sticker_id)
      next unless user_sticker

      trade.trade_stickers.create!(
        sticker_id: sticker_id,
        giver: current_user,
        receiver: current_user,
        user_sticker: user_sticker
      )
      user_sticker.discard!
    end

    # Process received stickers (create to_be_glued)
    received_sticker_ids.each do |sticker_id|
      us = current_user.user_stickers.create!(sticker_id: sticker_id, state: :to_be_glued)
      trade.trade_stickers.create!(
        sticker_id: sticker_id,
        giver: current_user,
        receiver: current_user,
        user_sticker: us
      )
    end

    redirect_to user_path(current_user), notice: t("anonymous_trades.create.success")
  end

  private

  def require_login
    redirect_to new_session_path unless current_user
  end
end
