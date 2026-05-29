# frozen_string_literal: true

class ApplicationController < ActionController::Base
  layout false

  before_action :set_locale

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    accept_language = request.env["HTTP_ACCEPT_LANGUAGE"]
    return nil unless accept_language

    preferred = accept_language.scan(/[a-z]{2}(?:-[A-Z]{2})?/).find do |lang|
      I18n.available_locales.map(&:to_s).include?(lang)
    end
    preferred&.to_sym
  end
end
