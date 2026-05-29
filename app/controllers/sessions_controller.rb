# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new]

  def new
    render Views::Sessions::New.new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase&.strip)

    if user
      session[:user_id] = user.id
      if user.user_stickers.any?
        redirect_to user_path(user), notice: t("sessions.create.welcome_back", name: user.name)
      else
        redirect_to edit_user_collection_path(user), notice: t("sessions.create.welcome_import")
      end
    else
      redirect_to new_registration_path(email: params[:email]&.strip), notice: t("sessions.create.not_found")
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: t("sessions.destroy.success")
  end

  private

  def redirect_if_logged_in
    redirect_to user_path(current_user) if current_user
  end
end
