# frozen_string_literal: true

class CollectionsController < ApplicationController
  before_action :require_owner

  def edit
    render Views::Collections::Edit.new(current_user: current_user)
  end

  def update
    parsed_data = parse_sticker_data
    unless parsed_data
      flash.now[:error] ||= t("collections.edit.parse_error")
      render Views::Collections::Edit.new(current_user: current_user), status: :unprocessable_entity
      return
    end

    CollectionImporter.new(current_user, parsed_data).call
    redirect_to user_path(current_user), notice: t("collections.edit.success")
  end

  private

  def require_owner
    redirect_to root_path unless current_user.present?
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
