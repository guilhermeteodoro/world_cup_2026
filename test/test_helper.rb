# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Load seeds once for the test suite (sticker catalog)
    setup do
      unless Sticker.any?
        Rails.application.load_seed
      end
    end

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
