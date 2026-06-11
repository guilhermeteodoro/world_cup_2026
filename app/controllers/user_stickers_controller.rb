# frozen_string_literal: true

class UserStickersController < ApplicationController
  before_action :require_owner

  # Glue a sticker to the album
  def create
    sticker = Sticker.find(params[:sticker_id])
    user_sticker = @user.user_stickers.create!(sticker: sticker, state: :glued)

    render json: { id: user_sticker.id, state: user_sticker.state, copies: duplicates_count(sticker) }, status: :created
  end

  # Glue all to_be_glued stickers
  def glue_all
    @user.user_stickers.to_be_glued.find_each do |us|
      if @user.user_stickers.glued.exists?(sticker_id: us.sticker_id)
        # Already have it glued — becomes a duplicate
        us.update!(state: :duplicate)
      else
        us.update!(state: :glued)
      end
    end

    redirect_back fallback_location: user_path(@user), notice: I18n.t("user_stickers.glue_all.success")
  end

  # Add or remove duplicate copies
  def update
    user_sticker = @user.user_stickers.find(params[:id])

    # Glue a to_be_glued sticker
    if params[:state] == "glued" && user_sticker.state == "to_be_glued"
      if @user.user_stickers.glued.exists?(sticker_id: user_sticker.sticker_id)
        user_sticker.update!(state: :duplicate)
      else
        user_sticker.update!(state: :glued)
      end
      return render json: { id: user_sticker.id, state: user_sticker.state, copies: duplicates_count(user_sticker.sticker) }
    end

    # Add or remove duplicate copies
    target_copies = params[:copies].to_i
    current_copies = @user.user_stickers.duplicates.where(sticker_id: user_sticker.sticker_id).count

    if target_copies > current_copies
      (target_copies - current_copies).times do
        @user.user_stickers.create!(sticker_id: user_sticker.sticker_id, state: :duplicate)
      end
    elsif target_copies < current_copies
      @user.user_stickers.duplicates
        .where(sticker_id: user_sticker.sticker_id)
        .limit(current_copies - target_copies)
        .each(&:discard!)
    end

    render json: { id: user_sticker.id, state: user_sticker.state, copies: target_copies }
  end

  # Unglue a sticker (destructive — soft delete)
  def destroy
    user_sticker = @user.user_stickers.find(params[:id])
    user_sticker.discard!

    head :no_content
  end

  private

  def require_owner
    @user = User.find_by!(slug: params[:user_slug])
    head :forbidden unless @user == current_user
  end

  def duplicates_count(sticker)
    @user.user_stickers.duplicates.where(sticker_id: sticker.id).count
  end
end
