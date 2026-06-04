# frozen_string_literal: true

class Views::LoggedIn < Views::Base
  def initialize(current_user:)
    @current_user = current_user
  end

  def view_template
    div(class: "pt-6 pb-2 px-2") do
      div(class: "mb-6") do
        div(class: "flex items-top gap-2 mb-2 space-between") do
          div(class: "grow-1") do
            render render_title
          end

          div(class: "grow-0") do
            render UI::Fragments::UserMenu.new(user: @current_user) if @current_user && !@hide_user_menu
          end
        end
      end

      render_content
    end
  end

  private

    def render_title = nil
    def render_content = nil
end
