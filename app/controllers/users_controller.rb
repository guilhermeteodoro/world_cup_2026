# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :redirect_unlogged, except: :show

  def show
    @user = User.find_by!(slug: params[:slug])

    @is_owner = current_user&.id == @user.id
    @trade_result = if current_user && !@is_owner
      TradeComparer.new(current_user, @user).call
    end

    @trade_clipboard_text = if @trade_result
      render_to_string("trades/comparison", formats: [ :text ], locals: {
        trade_result: @trade_result,
        current_user: current_user,
        user: @user
      })
    end

    render Views::Users::Show.new(
      user: @user,
      is_owner: @is_owner,
      trade_result: @trade_result,
      trade_clipboard_text: @trade_clipboard_text,
      current_user: current_user
    )
  end

  def edit
    render Views::Users::Edit.new(current_user: current_user)
  end

  def update
    if current_user.update(user_params)
      redirect_to user_path(current_user), notice: t("users.edit.success")
    else
      flash.now[:error] = current_user.errors.full_messages.join(", ")
      render Views::Users::Edit.new(user: current_user), status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email).transform_values(&:strip)
  end

  def redirect_unlogged
    redirect_to root_path unless current_user.present?
  end
end
