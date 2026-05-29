# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user

  def show
    @is_owner = current_user&.id == @user.id
    @trade_result = if current_user && !@is_owner
      TradeComparer.new(current_user, @user).call
    end

    render Views::Users::Show.new(
      user: @user,
      is_owner: @is_owner,
      trade_result: @trade_result,
      current_user: current_user
    )
  end

  def edit
    unless current_user&.id == @user.id
      redirect_to user_path(@user)
      return
    end

    render Views::Users::Edit.new(user: @user)
  end

  def update
    unless current_user&.id == @user.id
      redirect_to user_path(@user)
      return
    end

    if @user.update(user_params)
      redirect_to user_path(@user), notice: t("users.edit.success")
    else
      flash.now[:error] = @user.errors.full_messages.join(", ")
      render Views::Users::Edit.new(user: @user), status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by!(slug: params[:slug])
  end

  def user_params
    params.permit(:name, :email).transform_values(&:strip)
  end
end
