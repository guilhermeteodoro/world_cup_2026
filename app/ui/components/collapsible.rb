# frozen_string_literal: true

module UI
  module Components
    # Declarative collapsible with optional sessionStorage persistence.
    #
    # Usage:
    #   render UI::Components::Collapsible.new(open: true, persist_key: "my-key") do |c|
    #     c.trigger(class: "cursor-pointer") do
    #       "Click to toggle"
    #     end
    #     c.content do
    #       "Hidden content"
    #     end
    #   end
    class Collapsible < Phlex::HTML
      def initialize(open: true, persist_key: nil, **attrs)
        @open = open
        @persist_key = persist_key
        @attrs = attrs
      end

      def view_template
        div(**wrapper_attrs) { yield self }
      end

      def trigger(**attrs, &block)
        attrs[:data] = (attrs[:data] || {}).merge(
          action: "click->ui-state#toggle",
          ui_state_target: "trigger"
        )
        div(**attrs, &block)
      end

      def content(**attrs, &block)
        attrs[:data] = (attrs[:data] || {}).merge(ui_state_target: "content")
        # When persist_key is set, always render hidden to avoid FOUC —
        # the controller will show it on connect if stored state is open.
        hidden = @persist_key ? true : !@open
        attrs[:class] = [ attrs[:class], ("hidden" if hidden) ].compact.join(" ").presence
        div(**attrs, &block)
      end

      def icon(**attrs, &block)
        attrs[:data] = (attrs[:data] || {}).merge(ui_state_target: "icon")
        attrs[:class] = [ attrs[:class], "transition-transform duration-200 inline-block" ].compact.join(" ")
        # Same pessimistic approach: start collapsed when persisted
        default_open = @persist_key ? false : @open
        attrs[:style] = default_open ? "transform:rotate(0deg)" : "transform:rotate(-90deg)"
        span(**attrs, &block)
      end

      private

      def wrapper_attrs
        data = {
          controller: "ui-state",
          ui_state_open_value: @open
        }
        data[:ui_state_key_value] = @persist_key if @persist_key

        @attrs[:data] = @attrs[:data] ? data.merge(@attrs[:data]) : data
        @attrs
      end
    end
  end
end
