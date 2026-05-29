# frozen_string_literal: true

class RegistrationsController < ApplicationController
  before_action :redirect_if_logged_in

  def new
    render Views::Registrations::New.new(email: params[:email])
  end

  def create
    if User.exists?(email: params[:email]&.downcase&.strip)
      redirect_to new_session_path(email: params[:email]&.strip), alert: t("registrations.create.existing_email")
      return
    end

    user = User.new(name: params[:name], email: params[:email]&.downcase&.strip)

    parsed_data = parse_sticker_data
    unless parsed_data
      flash.now[:error] ||= t("registrations.create.parse_error")
      render Views::Registrations::New.new(email: params[:email]), status: :unprocessable_entity
      return
    end

    if user.save
      CollectionImporter.new(user, parsed_data).call
      session[:user_id] = user.id
      redirect_to user_path(user), notice: t("registrations.create.success", name: user.name)
    else
      flash.now[:error] = user.errors.full_messages.join(", ")
      render Views::Registrations::New.new(email: params[:email]), status: :unprocessable_entity
    end
  end

  private

  def redirect_if_logged_in
    redirect_to user_path(current_user) if current_user
  end

  def parse_sticker_data
    case params[:import_method]
    when "dump"
      DumpParser.new(params[:dump]).call
    when "manual"
      ManualParser.new(
        missing_text: params[:missing_text],
        duplicates_text: params[:duplicates_text]
      ).call
    end
  rescue DumpParser::ParseError, ManualParser::ParseError => e
    flash.now[:error] = e.message
    nil
  end
end
