# frozen_string_literal: true

class UI::Components::Collapsible < Phlex::HTML
  def initialize(open: true, persist_key: nil, **attrs)
    @open = open
    @persist_key = persist_key
    @attrs = attrs
  end

  def view_template(&)
    div(**wrapper_attrs, &)
  end

  private

  def wrapper_attrs
    data = {
      controller: "collapsible",
      collapsible_open_value: @open
    }
    data[:collapsible_key_value] = @persist_key if @persist_key

    @attrs[:data] = @attrs[:data] ? data.merge(@attrs[:data]) : data
    @attrs
  end
end
