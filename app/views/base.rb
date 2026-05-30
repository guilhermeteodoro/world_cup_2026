# frozen_string_literal: true

class Views::Base < Components::Base
  def around_template
    render Components::Layout.new(title: page_title) do
      super
    end
  end

  def page_title
    t("app_name")
  end
end
