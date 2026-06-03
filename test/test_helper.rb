# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Load the sticker catalog once for the entire test suite.
    # The catalog is immutable (994 stickers, 49 countries) and shared
    # across all tests via transactional rollback.
    Rails.application.load_seed unless Sticker.any?

    def create_user(name: "Test", email: "test@example.com", dump: nil)
      user = User.create!(name: name, email: email)
      if dump
        parsed = DumpParser.new(dump).call
        CollectionImporter.new(user, parsed).call
      end
      user
    end

    def sample_dump
      File.read(Rails.root.join("gui.txt")).strip
    end
  end
end

module ComponentTestHelper
  def render(component)
    view_context.render(component)
  end

  def render_document(component)
    html = render(component)
    Nokogiri::HTML5(html)
  end

  private

  def view_context
    @view_context ||= test_controller.view_context
  end

  def test_controller
    ctrl = ApplicationController.new
    ctrl.request = ActionDispatch::TestRequest.create
    ctrl
  end
end
