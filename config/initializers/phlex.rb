# frozen_string_literal: true

module Views
end

module UI
  extend Phlex::Kit

  module Components
    extend Phlex::Kit
  end

  module Fragments
    extend Phlex::Kit
  end

  module Layouts
    extend Phlex::Kit
  end
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/views"), namespace: Views
)

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/ui"), namespace: UI
)
