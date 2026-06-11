# frozen_string_literal: true

class Views::AnonymousTrades::New < Views::LoggedIn
  def initialize(current_user:)
    @current_user = current_user
  end

  def page_title
    t(".title")
  end

  def render_title
    Heading(level: 2) { t(".title") }
  end

  def render_content
    p(class: "text-muted-foreground mb-6") { t(".description") }

    form(action: anonymous_trades_path, method: "post") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

      div(class: "space-y-6") do
        # Given stickers
        div do
          label(class: "block text-sm font-medium mb-2") { t(".given_label") }
          textarea(
            name: "given_sticker_ids[]",
            class: "w-full h-24 border rounded p-2 text-sm font-mono",
            placeholder: t(".given_placeholder"),
            data: { controller: "sticker-input" }
          )
          p(class: "text-xs text-muted-foreground mt-1") { t(".given_help") }
        end

        # Received stickers
        div do
          label(class: "block text-sm font-medium mb-2") { t(".received_label") }
          textarea(
            name: "received_sticker_ids[]",
            class: "w-full h-24 border rounded p-2 text-sm font-mono",
            placeholder: t(".received_placeholder"),
            data: { controller: "sticker-input" }
          )
          p(class: "text-xs text-muted-foreground mt-1") { t(".received_help") }
        end

        Button(type: :submit, variant: :primary) { t(".submit") }
      end
    end
  end
end
