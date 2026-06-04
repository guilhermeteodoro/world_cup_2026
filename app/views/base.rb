# frozen_string_literal: true

class Views::Base < UI::Base
  register_value_helper :current_user

  def around_template
    render UI::Layouts::Application.new(title: page_title, current_user: current_user) do
      super
    end
  end

  def page_title
    t("app_name")
  end
end
