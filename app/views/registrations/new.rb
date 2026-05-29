# frozen_string_literal: true

class Views::Registrations::New < Views::Base
  def initialize(email: nil)
    @email = email
  end

  def view_template
    h1(class: "text-2xl font-bold text-gray-900 mb-6") { "Register your collection" }

    form(action: registration_path, method: "post", data: { controller: "import-form" }) do
      authenticity_token_tag

      div(class: "mb-6") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { "Your name" }
        input(
          type: "text", name: "name", required: true,
          class: "w-full border border-gray-300 rounded-lg p-3",
          placeholder: "e.g. Gui"
        )
      end

      div(class: "mb-6") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { "Your email" }
        input(
          type: "email", name: "email", required: true,
          value: @email,
          class: "w-full border border-gray-300 rounded-lg p-3",
          placeholder: "e.g. gui@example.com"
        )
      end

      render_import_fields

      div(class: "mt-6") do
        button(type: "submit", class: "bg-green-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-700") do
          "Create my collection"
        end
      end
    end
  end

  private

  def render_import_fields
    # Import method selector
    div(class: "mb-6") do
      label(class: "block text-sm font-medium text-gray-700 mb-2") { "Import method" }
      div(class: "flex gap-4") do
        label(class: "flex items-center gap-2 cursor-pointer") do
          input(type: "radio", name: "import_method", value: "dump",
                checked: true, data: { action: "import-form#toggle" })
          span { "Sticker Album 2026 app export" }
        end
        label(class: "flex items-center gap-2 cursor-pointer") do
          input(type: "radio", name: "import_method", value: "manual",
                data: { action: "import-form#toggle" })
          span { "Manual (missing + duplicates)" }
        end
      end
    end

    # Dump input
    div(data: { import_form_target: "dump" }) do
      label(class: "block text-sm font-medium text-gray-700 mb-1") { "Paste your dump" }
      textarea(
        name: "dump",
        rows: 4,
        class: "w-full border border-gray-300 rounded-lg p-3 font-mono text-sm",
        placeholder: "SA26|1|2-3,6,9-13,...|10:1,38:3,..."
      )
    end

    # Manual inputs
    div(class: "hidden", data: { import_form_target: "manual" }) do
      div(class: "mb-4") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { "Paste your missing stickers" }
        textarea(
          name: "missing_text",
          rows: 6,
          class: "w-full border border-gray-300 rounded-lg p-3 font-mono text-sm",
          placeholder: "FWC: 00, 3, 4, 6, 7\nBRA: 2, 3, 4, 6, 7, 8..."
        )
      end
      div do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { "Paste your duplicates" }
        textarea(
          name: "duplicates_text",
          rows: 6,
          class: "w-full border border-gray-300 rounded-lg p-3 font-mono text-sm",
          placeholder: "FWC: 9(1x), 10(1x)\nMEX: 4(3x), 5(1x)..."
        )
      end
    end
  end

  def authenticity_token_tag
    input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
  end
end
