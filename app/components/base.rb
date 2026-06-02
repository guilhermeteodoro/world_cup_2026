# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include Components
  include RubyUI

  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::StylesheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptIncludeTag
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::FormAuthenticityToken
  include Phlex::Rails::Helpers::ImagePath
  include Phlex::Rails::Helpers::T

  register_element :turbo_frame, tag: "turbo-frame"

  register_value_helper :current_user

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end
