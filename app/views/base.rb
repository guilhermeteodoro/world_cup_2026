# frozen_string_literal: true

class Views::Base < Components::Base
  def around_template
    render Components::Layout.new(title: page_title, current_user: current_user) do
      super
    end
  end

  def page_title
    t("app_name")
  end
end
