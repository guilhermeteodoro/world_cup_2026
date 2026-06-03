# frozen_string_literal: true

class DiffsController < ApplicationController
  def show
    render Views::Diffs::Show.new(current_user: current_user)
  end

  def create
    parsed_a = StickerListParser.new(params[:list_a]).call
    parsed_b = StickerListParser.new(params[:list_b]).call

    stickers_a = parsed_a[:stickers]
    stickers_b = parsed_b[:stickers]

    ids_a = stickers_a.map(&:id).to_set
    ids_b = stickers_b.map(&:id).to_set

    only_in_a = stickers_a.reject { |s| ids_b.include?(s.id) }
    only_in_b = stickers_b.reject { |s| ids_a.include?(s.id) }
    errors = (parsed_a[:errors] + parsed_b[:errors]).uniq

    render Views::Diffs::Show.new(
      current_user: current_user,
      list_a: params[:list_a],
      list_b: params[:list_b],
      only_in_a: only_in_a,
      only_in_b: only_in_b,
      errors: errors
    )
  end
end
