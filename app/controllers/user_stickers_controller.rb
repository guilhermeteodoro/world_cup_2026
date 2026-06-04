# frozen_string_literal: true

class UserStickersController < ApplicationController
  before_action :require_owner

  def create
    sticker = Sticker.find(params[:sticker_id])
    user_sticker = @user.user_stickers.create!(sticker: sticker, copies: 0)

    render json: { id: user_sticker.id, copies: user_sticker.copies }, status: :created
  end

  def update
    user_sticker = @user.user_stickers.find(params[:id])
    user_sticker.update!(copies: params[:copies].to_i)

    render json: { id: user_sticker.id, copies: user_sticker.copies }
  end

  def destroy
    user_sticker = @user.user_stickers.find(params[:id])
    user_sticker.destroy!

    head :no_content
  end

  private

  def require_owner
    @user = User.find_by!(slug: params[:user_slug])
    head :forbidden unless @user == current_user
  end
end
