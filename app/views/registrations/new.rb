# frozen_string_literal: true

class Views::Registrations::New < Views::Base
  def initialize(email: nil)
    @email = email
  end

  def view_template
    h1(class: "text-2xl font-bold text-gray-900 mb-6") { t("registrations.new.title") }

    form(action: registration_path, method: "post", data: { controller: "import-form" }) do
      authenticity_token_tag

      div(class: "mb-6") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { t("registrations.new.name_label") }
        input(
          type: "text", name: "name", required: true,
          class: "w-full border border-gray-300 rounded-lg p-3",
          placeholder: t("registrations.new.name_placeholder")
        )
      end

      div(class: "mb-6") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { t("registrations.new.email_label") }
        input(
          type: "email", name: "email", required: true,
          value: @email,
          class: "w-full border border-gray-300 rounded-lg p-3",
          placeholder: t("registrations.new.email_placeholder")
        )
      end

      render_import_fields

      div(class: "mt-6") do
        button(type: "submit", class: "bg-green-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-700") do
          t("registrations.new.submit")
        end
      end
    end
  end

  private

  def render_import_fields
    div(class: "mb-6") do
      label(class: "block text-sm font-medium text-gray-700 mb-2") { t("registrations.new.import_method_label") }
      div(class: "flex gap-4") do
        label(class: "flex items-center gap-2 cursor-pointer") do
          input(type: "radio", name: "import_method", value: "dump",
                checked: true, data: { action: "import-form#toggle" })
          span { t("registrations.new.import_dump") }
        end
        label(class: "flex items-center gap-2 cursor-pointer") do
          input(type: "radio", name: "import_method", value: "manual",
                data: { action: "import-form#toggle" })
          span { t("registrations.new.import_manual") }
        end
      end
    end

    div(data: { import_form_target: "dump" }) do
      label(class: "block text-sm font-medium text-gray-700 mb-1") { t("registrations.new.dump_label") }
      textarea(
        name: "dump", rows: 4,
        class: "w-full border border-gray-300 rounded-lg p-3 font-mono text-sm",
        placeholder: t("registrations.new.dump_placeholder")
      )
    end

    div(class: "hidden", data: { import_form_target: "manual" }) do
      div(class: "mb-4") do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { t("registrations.new.missing_label") }
        textarea(
          name: "missing_text", rows: 6,
          class: "w-full border border-gray-300 rounded-lg p-3 font-mono text-sm",
          placeholder: t("registrations.new.missing_placeholder")
        )
      end
      div do
        label(class: "block text-sm font-medium text-gray-700 mb-1") { t("registrations.new.duplicates_label") }
        textarea(
          name: "duplicates_text", rows: 6,
          class: "w-full border border-gray-300 rounded-lg p-3 font-mono text-sm",
          placeholder: t("registrations.new.duplicates_placeholder")
        )
      end
    end
  end

  def authenticity_token_tag
    input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
  end
end
